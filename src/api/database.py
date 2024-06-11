from datetime import date, datetime, time
from dotenv import load_dotenv
from fastapi.encoders import ENCODERS_BY_TYPE
from pydantic import BaseModel, create_model
from sqlalchemy import create_engine, MetaData, Column, Boolean, Integer, Numeric, Text, String, Date, Time, DateTime, JSON, text
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.ext.declarative import declarative_base
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
    # print(f"Connecting to database at {db_url}")
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
    'string_type': (String, str)
}

def generate_sqlalchemy_model_class(
    table_name: str, 
    columns: List[Tuple[str, str]], 
    primary_keys: List[str], 
    schema: str, 
    base=Base
) -> Type[Base]:  # Generate SQLAlchemy model class from table metadata  # type: ignore
    attrs = {
        '__tablename__': table_name,
        '__table_args__': {'schema': schema}
    }

    for column_name, column_type in columns:
        column_class, _ = SQL_TYPE_MAPPING.get(column_type, (String, str))  # Default to String if type not found
        column_kwargs: dict[str, Any] = {'primary_key': column_name in primary_keys}  # Set PK flag
        attrs[column_name] = Column(column_name, column_class, **column_kwargs)  # Add column to model

    model_class = type(table_name.capitalize(), (base,), attrs)
    print(f"Generated SQLAlchemy model class for table '{table_name}' in schema '{schema}': {model_class.__dict__}")
    return model_class

def create_models_from_metadata(
    engine,
    schema: str,
    base=Base
) -> Dict[str, Type[Base]]:  # Create SQLAlchemy models from database metadata  # type: ignore
    metadata = MetaData()
    metadata.reflect(bind=engine, schema=schema, extend_existing=True)

    models: Dict[str, Type[Base]] = {}  # * Dict to store generated models  # type: ignore
    for table_name, table in metadata.tables.items():
        if table.schema == schema:
            columns = [(col.name, col.type.__class__.__name__.lower()) for col in table.columns]
            primary_keys = [col.name for col in table.columns if col.primary_key]
            model_class = generate_sqlalchemy_model_class(table_name.split('.')[-1], columns, primary_keys, schema, base)
            models[table_name] = model_class
            print(f"Generated model for table {table_name} with columns {columns} and primary keys {primary_keys}")
    return models

def create_pydantic_model(db: Session, table: str, model_name: str, schema: str = '') -> Type[BaseModel]:
    query = """
        SELECT column_name, is_nullable, data_type 
        FROM information_schema.columns
        WHERE table_name = :table
    """
    if schema:
        query += " AND table_schema = :schema"
    query = text(query)
    columns = db.execute(query, {'schema': schema, 'table': table}).fetchall()

    fields: Dict[str, Tuple[Optional[Type[Any]], Any]] = {}
    for col in columns:
        column_name, _, column_type = col
        _, pydantic_type = SQL_TYPE_MAPPING.get(column_type, (_, str))  # Default to str if type not found
        fields[column_name] = (Optional[pydantic_type], None)  # Set field type and default value
        print(f"\tColumn {column_name:^16} {column_type:>24} -> {pydantic_type}")  # Log field type mapping
    return create_model(model_name, **fields)


def generate_models(
    engine,
    schemas: List[str] = ['store']
) -> Dict[str, Tuple[Type[Base], Type[BaseModel]]]:  # type: ignore
    all_models: Dict[str, Type[Base]] = {}  # * Dict to store all generated models  # type: ignore
    combined_models: Dict[str, Tuple[Type[Base], Type[BaseModel]]] = {}  # * Dict to store SQLAlchemy and Pydantic models  # type: ignore

    for schema in schemas:  # Generate models for each schema
        models = create_models_from_metadata(engine, schema)
        all_models.update(models)
        print(f"\nModels for schema '{schema}':")
        [print(f"\t{name}: {model.__table__.columns.keys()}") for name, model in models.items()]

    for name, model in all_models.items():  # Generate Pydantic models for each SQLAlchemy model
        pydantic_model = create_pydantic_model(next(get_db()), model.__tablename__, model.__tablename__, 'store')
        combined_models[name] = (model, pydantic_model)  # Store SQLAlchemy and Pydantic models together
        print(f"\nPydantic model for table '{name}': {pydantic_model.model_fields}")
    return combined_models

all_models: Dict[str, Tuple[Type[Base], Type[BaseModel]]] = generate_models(engine, ['store'])  # Generate models for 'store' schema  # type: ignore
