from datetime import date, datetime, time
from re import T
from dotenv import load_dotenv
from fastapi import Depends
from fastapi.background import P
from pydantic import BaseModel, create_model
from sqlalchemy import Engine, create_engine, MetaData, Column, Boolean, Integer, Numeric, Text, String, Date, Time, DateTime, JSON, text
from sqlalchemy.orm import sessionmaker, Session, declarative_base, DeclarativeMeta
from sqlalchemy.ext.declarative import declared_attr
from typing import Type, Any, Dict, List, Optional, Tuple
# Load environment variables from .env file
load_dotenv()

# Database URL
db_url: str = f"postgresql://postgres:fire@localhost/some_store"
engine = create_engine(db_url)

def get_db():
    """
    Yields a database session.
    """
    db: Session = sessionmaker(autocommit=False, autoflush=False, bind=engine)()
    try:
        yield db
    finally:
        db.close()

Base = declarative_base()

# Unified mapping of SQL types to SQLAlchemy and Pydantic types
SQL_TYPE_MAPPING = {
    'boolean': (Boolean, bool),
    'integer': (Integer, int),
    'numeric': (Numeric, float),
    'bigint': (Integer, int),
    'text': (Text, str),
    'varchar': (String, str),
    'character varying': (String, str),
    'date': (Date, date),
    'time': (Time, time),
    'timestamp': (DateTime, datetime),
    'datetime': (DateTime, datetime),
    'jsonb': (JSON, dict),
    'string_type': (String, str),
    'text': (String, str),
}

def generate_sqlalchemy_model_class(
    table_name: str, 
    columns: List[Tuple[str, str]], 
    primary_keys: List[str], 
    schema: str, 
) -> Type[Base]:  # Generate SQLAlchemy model class from table metadata  # type: ignore
    attrs = {
        '__tablename__': table_name,
        '__table_args__': {'schema': schema}
    }

    for column_name, column_type in columns:
        column_class, _ = SQL_TYPE_MAPPING.get(column_type, (String, str))  # Default to String if type not found
        print(f"\tColumn {column_name:^16} {column_type:>24} -> {column_class.__name__}")  # Log column type mapping
        # column_kwargs: dict[str, Any] = {'primary_key': column_name in primary_keys} if not is_view else {}
        column_kwargs: dict[str, Any] = {'primary_key': column_name in primary_keys}
        attrs[column_name] = Column(column_class, **column_kwargs)  # Add column to model

    print(f"\tPrimary keys: {primary_keys}")
    print(f"\tAttributes: {attrs}")
    model_class = type(table_name.capitalize(), (Base,), attrs)
    print(f"Generated SQLAlchemy model class for table '{table_name}' in schema '{schema}': {model_class.__dict__}")
    return model_class

def create_models_from_metadata(
    engine,
    schema: str,
) -> Dict[str, Type[Base]]:  # Create SQLAlchemy models from database metadata  # type: ignore
    metadata = MetaData()
    metadata.reflect(bind=engine, schema=schema, views=True, extend_existing=True)

    models: Dict[str, Type[Base]] = {}  # * Dict to store generated models  # type: ignore
    for table_name, table in metadata.tables.items():
        if table.schema == schema:
            columns = [(col.name, col.type.__class__.__name__.lower()) for col in table.columns]
            primary_keys = [col.name for col in table.columns if col.primary_key]
            model_class = generate_sqlalchemy_model_class(table_name.split('.')[-1], columns, primary_keys, schema)
            models[table_name] = model_class
            # todo: CHECK THIS LINE...
            # print(f"Generated {'view' if is_view else 'table'} model {table_name} w/ columns {[print(f'\t{col}') for col in columns]} and primary keys {primary_keys}")
    return models

def create_pydantic_model(db: Session, table: str, model_name: str, schema: str = '') -> Type[BaseModel]:
    query = """
        SELECT column_name, data_type 
        FROM information_schema.columns
        WHERE table_name = :table
    """
    if schema:
        query += " AND table_schema = :schema"
    query = text(query)
    columns = db.execute(query, {'schema': schema, 'table': table}).fetchall()

    print(f"Pydantic model '{model_name}' for table '{table}' in schema '{schema}':")

    fields: Dict[str, Tuple[Optional[Type[Any]], Any]] = {}
    for col in columns:
        column_name, column_type = col
        _, pydantic_type = SQL_TYPE_MAPPING.get(column_type, (str, str))  # Default to str if type not found
        fields[column_name] = (Optional[pydantic_type], None)  # Set field type and default value if any
        print(f"\t\tColumn {column_name:^16} {column_type:>24} -> {pydantic_type}")  # Log field type mapping

    return create_model(model_name, **fields)




def generate_models(
    engine: Engine,
    schemas: List[str]
) -> Dict[str, Tuple[Type[Base], Type[BaseModel]]]:  # type: ignore
    all_models: Dict[str, Type[Base]] = {}  # * Dict to store all generated models  # type: ignore
    combined_models: Dict[str, Tuple[Type[Base], Type[BaseModel]]] = {}  # * Dict to store SQLAlchemy and Pydantic models  # type: ignore

    for schema in schemas:  # Generate models for each schema
        models = create_models_from_metadata(engine, schema)
        all_models.update(models)

        for name, model in all_models.items():  # Generate Pydantic models for each SQLAlchemy model
            pydantic_model = create_pydantic_model(next(get_db()), model.__tablename__, model.__tablename__, schema)
            combined_models[name] = (model, pydantic_model)  # Store SQLAlchemy and Pydantic models together

    return combined_models

store_models: Dict[str, Tuple[Type[Base], Type[BaseModel]]] = generate_models(engine, ['store'])  # Generate models for 'store' schema  # type: ignore


class ViewBase:
    @declared_attr
    def __tablename__(cls):
        return cls.__name__.lower()
    
    __table_args__ = {'extend_existing': True}

# * Same as 'generate_sqlalchemy_model_class' but for views
# * but it creates tables that don't have primary keys
def generate_sqlalchemy_view_class(
    table_name: str,
    columns: List[Tuple[str, str]],
    schema: str,
) -> Type[Base]:  # Generate SQLAlchemy view class from table metadata  # type: ignore
    attrs = {
        '__tablename__': table_name,
        '__table_args__': {'schema': schema}
    }

    primary_keys = []

    for column_name, column_type in columns:
        column_class, _ = SQL_TYPE_MAPPING.get(column_type, str)
        print(f"\tColumn {column_name:^16} {column_type:>24} -> {column_class.__name__}")
        column_kwargs: dict[str, Any] = {}
        column = Column(column_class, **column_kwargs)
        attrs[column_name] = column
        primary_keys.append(column)

    # Add primary keys to mapper args to bypass the primary key requirement
    attrs['__mapper_args__'] = {'primary_key': primary_keys}

    model_class = type(table_name.capitalize(), (ViewBase, Base), attrs)
    print(f"Generated SQLAlchemy view class for table '{table_name}' in schema '{schema}': {model_class.__dict__}")
    return model_class

def create_views_from_metadata(
    engine,
    schema: str,
) -> Dict[str, Type[Base]]:  # Create SQLAlchemy view classes from database metadata  # type: ignore
    metadata = MetaData()
    metadata.reflect(bind=engine, schema=schema, views=True, extend_existing=True)

    models: Dict[str, Type[Base]] = {}  # * Dict to store generated models  # type: ignore
    for table_name, table in metadata.tables.items():
        if table.schema == schema:  # get only the tables from the specified schema
            models[table_name] = generate_sqlalchemy_view_class(
                table_name=table_name.split('.')[-1], 
                columns=[(col.name, col.type.__class__.__name__.lower()) for col in table.columns], 
                schema=schema
            )
    return models

def create_pydantic_view_class(
        db: Session,
        table: str,
        model_name: str,
        schema: str = ''
) -> Type[BaseModel]:
    query = """
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_name = :table
    """
    if schema:
        query += " AND table_schema = :schema"
    query = text(query)
    columns = db.execute(query, {'schema': schema, 'table': table}).fetchall()

    print(f"Pydantic model '{model_name}' for table '{table}' in schema '{schema}':")

    fields: Dict[str, Tuple[Optional[Type[Any]], Any]] = {}
    for column_name, column_type in columns:
        # column_name: str = column_name.replace('_', ' ').title().replace(' ', '')
        _, pydantic_type = SQL_TYPE_MAPPING.get(column_type, (str, str))
        fields[column_name] = (Optional[pydantic_type], None)
        print(f"\tColumn {column_name:^16} {column_type:>24} -> {pydantic_type}")

    model = create_model(model_name, **fields)
    print(f"Pydantic model '{model_name}' for table '{table}' in schema '{schema}': {model.__fields__}")

    return model


def generate_views(
    engine: Engine,
    schemas: List[str]
) -> Dict[str, Tuple[Type[Base], Type[BaseModel]]]:  # Generate SQLAlchemy and Pydantic models for views  # type: ignore
    all_models: Dict[str, Type[Base]] = {}  # * Dict to store all generated models  # type: ignore
    combined_models: Dict[str, Tuple[Type[Base], Type[BaseModel]]] = {}  # * Dict to store SQLAlchemy and Pydantic models  # type: ignore

    for schema in schemas:
        models = create_views_from_metadata(engine, schema)
        all_models.update(models)

        print(f"\nPydantic models '{schema}' schema:")
        for name, model in all_models.items():
            pydantic_model: Type[BaseModel] = create_pydantic_view_class(next(get_db()), model.__tablename__, model.__tablename__, schema)
            combined_models[name] = (model, pydantic_model)

    return combined_models


public_views: Dict[str, Tuple[Type[Base], Type[BaseModel]]] = generate_views(engine, ['public'])  # Generate models for 'store' schema  # type: ignore


all_models: Dict[str, Tuple[Type[Base], Type[BaseModel]]] = {  # Combine all models  # type: ignore
    # **store_models,
    # **public_models
}
