from datetime import date, datetime, time
from dotenv import load_dotenv
from fastapi import Depends
from fastapi.encoders import ENCODERS_BY_TYPE
from pydantic import BaseModel, create_model
from sqlalchemy import Engine, create_engine, MetaData, Column, Boolean, Integer, Numeric, Text, String, Date, Time, DateTime, JSON, text
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
) -> Type[Base]:  # Generate SQLAlchemy model class from table metadata  # type: ignore
    attrs = {
        '__tablename__': table_name,
        '__table_args__': {'schema': schema}
    }

    if not primary_keys:
        # Assign a surrogate primary key if there are no primary keys
        attrs['id'] = Column(Integer, primary_key=True, autoincrement=True)

    for column_name, column_type in columns:
        column_class, _ = SQL_TYPE_MAPPING.get(column_type, (String, str))  # Default to String if type not found
        column_kwargs: dict[str, Any] = {'primary_key': column_name in primary_keys}  # Set PK flag
        attrs[column_name] = Column(column_name, column_class, **column_kwargs)  # Add column to model

    model_class = type(table_name.capitalize(), (Base,), attrs)
    print(f"Generated SQLAlchemy model class for table '{table_name}' in schema '{schema}': {model_class.__dict__}")
    return model_class

def create_models_from_metadata(
    engine,
    schema: str,
) -> Dict[str, Type[Base]]:  # Create SQLAlchemy models from database metadata  # type: ignore
    metadata = MetaData()
    metadata.reflect(bind=engine, schema=schema, extend_existing=True)

    models: Dict[str, Type[Base]] = {}  # * Dict to store generated models  # type: ignore
    for table_name, table in metadata.tables.items():
        if table.schema == schema:
            columns = [(col.name, col.type.__class__.__name__.lower()) for col in table.columns]
            primary_keys = [col.name for col in table.columns if col.primary_key]
            model_class = generate_sqlalchemy_model_class(table_name.split('.')[-1], columns, primary_keys, schema)
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
    print(f"\nColumns for table '{table}': {columns}")

    fields: Dict[str, Tuple[Optional[Type[Any]], Any]] = {}
    for col in columns:
        column_name, _, column_type = col
        _, pydantic_type = SQL_TYPE_MAPPING.get(column_type, (_, str))  # Default to str if type not found
        fields[column_name] = (Optional[pydantic_type], None)  # Set field type and default value
        print(f"\tColumn {column_name:^16} {column_type:>24} -> {pydantic_type}")  # Log field type mapping
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
        print(f"\nModels for schema '{schema}':")
        [print(f"\t{name}: {model.__table__.columns.keys()}") for name, model in models.items()]

    for name, model in all_models.items():  # Generate Pydantic models for each SQLAlchemy model
        pydantic_model = create_pydantic_model(next(get_db()), model.__tablename__, model.__tablename__, 'store')
        combined_models[name] = (model, pydantic_model)  # Store SQLAlchemy and Pydantic models together
        print(f"\nPydantic model for table '{name}': {pydantic_model.model_fields}")
    return combined_models

all_models: Dict[str, Tuple[Type[Base], Type[BaseModel]]] = generate_models(engine, ['store'])  # Generate models for 'store' schema  # type: ignore


# def create_models_from_views(
#     engine: Engine,
#     schema: str = 'public',
# ) -> Dict[str, Type[Base]]:  # Create SQLAlchemy models from database views  # type: ignore
#     models: Dict[str, Type[Base]] = {}  # * Dict to store generated models  # type: ignore
#     view_query = text("""
#         SELECT table_name
#         FROM information_schema.views
#         WHERE table_schema = :schema
#     """)

#     column_query = text("""
#         SELECT column_name, data_type
#         FROM information_schema.columns
#         WHERE table_name = :view_name
#     """)

#     # connect to the database
#     conn = engine.connect()
#     view_names = conn.execute(view_query, {'schema': schema}).fetchall()
#     print(f"\n\nViews in schema '{schema}': {view_names}")

#     for view_name_tuple in view_names:
#         view_name = view_name_tuple[0]

#         columns = conn.execute(column_query, {'schema': schema, 'view_name': view_name}).fetchall()
#         if columns:
#             print(f"Columns for view '{view_name}': {columns}")
#             column_details = [(col[0], col[1]) for col in columns]


#             primary_keys = []  # Views generally do not have primary keys
#             model_class = generate_sqlalchemy_model_class(view_name, column_details, primary_keys, schema)
#             models[view_name] = model_class
#             print(f"Generated model for view {view_name} with columns {column_details}")
    
#     conn.close()
#     return models

# def generate_models_for_views(
#     engine,
#     schemas: List[str] = ['public']
# ) -> Dict[str, Tuple[Type[Base], Type[BaseModel]]]:  # type: ignore
#     all_view_models: Dict[str, Type[Base]] = {}  # * Dict to store all generated models  # type: ignore

#     for schema in schemas:  # Generate models for each schema
#         view_models = create_models_from_views(engine, schema)
#         all_view_models.update(view_models)
#         print(f"\nView models for schema '{schema}':")
#         [print(f"\t{name}: {model.__table__.columns.keys()}") for name, model in view_models.items()]

#     for name, model in all_view_models.items():
#         pydantic_model = create_pydantic_model(next(get_db()), model.__tablename__, model.__tablename__, 'public')
#         all_view_models[name] = (model, pydantic_model)
#         # print(f"\nPydantic model for view '{name}': {pydantic_model.model_fields}")

#     return all_view_models

# # all_view_models: Dict[str, Tuple[Type[Base], Type[BaseModel]]] = {}
# all_view_models: Dict[str, Tuple[Type[Base], Type[BaseModel]]] = generate_models_for_views(engine, ['public'])  # Generate models for 'public' schema  # type: ignore










# def generate_sqlalchemy_model_class_for_views(
#     view_name: str, 
#     columns: List[Tuple[str, str]], 
#     schema: str, 
#     base=Base
# ) -> Type[Base]:  # Generate SQLAlchemy model class for views without primary keys  # type: ignore
#     attrs = {
#         '__tablename__': view_name,
#         '__table_args__': {'schema': schema}
#     }

#     for column_name, column_type in columns:
#         column_class, _ = SQL_TYPE_MAPPING.get(column_type, (String, str))  # Default to String if type not found
#         attrs[column_name] = Column(column_name, column_class)  # Add column to model

#     model_class = type(view_name.capitalize(), (base,), attrs)
#     print(f"Generated SQLAlchemy model class for view '{view_name}' in schema '{schema}': {model_class.__dict__}")
#     return model_class

# def create_models_from_views(
#     engine: Engine,
#     schema: str = 'public',
# ) -> Dict[str, Type[Base]]:  # Create SQLAlchemy models from database views  # type: ignore
#     models: Dict[str, Type[Base]] = {}  # * Dict to store generated models  # type: ignore
#     view_query = text("""
#         SELECT table_name
#         FROM information_schema.views
#         WHERE table_schema = :schema
#     """)

#     column_query = text("""
#         SELECT column_name, data_type
#         FROM information_schema.columns
#         WHERE table_schema = :schema AND table_name = :view_name
#     """)

#     # connect to the database
#     conn = engine.connect()
#     view_names = conn.execute(view_query, {'schema': schema}).fetchall()
#     print(f"\n\nViews in schema '{schema}': {view_names}")

#     for view_name_tuple in view_names:
#         view_name = view_name_tuple[0]

#         columns = conn.execute(column_query, {'schema': schema, 'view_name': view_name}).fetchall()
#         if columns:
#             print(f"Columns for view '{view_name}': {columns}")
#             column_details = [(col[0], col[1]) for col in columns]

#             model_class = generate_sqlalchemy_model_class_for_views(view_name, column_details, schema)
#             models[view_name] = model_class
#             print(f"Generated model for view {view_name} with columns {column_details}")
    
#     conn.close()
#     return models


# def generate_models_for_views(
#     engine,
#     schemas: List[str] = ['public']
# ) -> Dict[str, Tuple[Type[Base], Type[BaseModel]]]:  # type: ignore
#     all_view_models: Dict[str, Type[Base]] = {}  # * Dict to store all generated models  # type: ignore

#     for schema in schemas:  # Generate models for each schema
#         view_models = create_models_from_views(engine, schema)
#         all_view_models.update(view_models)
#         print(f"\nView models for schema '{schema}':")
#         [print(f"\t{name}: {model.__table__.columns.keys()}") for name, model in view_models.items()]

#     combined_models: Dict[str, Tuple[Type[Base], Type[BaseModel]]] = {}

#     for name, model in all_view_models.items():
#         pydantic_model = create_pydantic_model(next(get_db()), model.__tablename__, model.__tablename__, 'public')
#         combined_models[name] = (model, pydantic_model)
#         print(f"\nPydantic model for view '{name}': {pydantic_model.__dict__}")

#     return combined_models

# # Generate models for 'public' schema views
# all_view_models: Dict[str, Tuple[Type[Base], Type[BaseModel]]] = generate_models_for_views(engine, ['public'])  # type: ignore

