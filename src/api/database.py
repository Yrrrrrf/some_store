# database.py

from typing import Dict, List, Tuple as PyTuple, Type, Any, Optional
from sqlalchemy import *
from sqlalchemy.orm import sessionmaker, declarative_base, Session
from sqlalchemy.ext.declarative import declared_attr
from pydantic import BaseModel, create_model
from dotenv import load_dotenv
import os

from datetime import date, time, datetime

# Load environment variables
load_dotenv()


# Database connection
class DatabaseManager:
    """Manages database connection and session creation."""

    def __init__(self):
        self.db_url: str = self._get_db_url()
        self.engine: Engine = create_engine(self.db_url)
        self.SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=self.engine)

    @staticmethod
    def _get_db_url() -> str:
        """Construct database URL from environment variables."""
        db_user: str = os.getenv("DB_USER", "some_store_owner")
        db_password: str = os.getenv("DB_PASSWORD", "store_password")
        db_host: str = os.getenv("DB_HOST", "localhost")
        db_name: str = os.getenv("DB_NAME", "some_store")
        return f"postgresql://{db_user}:{db_password}@{db_host}/{db_name}"
        # return f"postgresql://some_store_owner:store_password@localhost/some_store"

    def get_db(self):
        """Yield a database session."""
        db: Session = self.SessionLocal()
        try:
            yield db
        finally:
            db.close()


# Model generation
Base = declarative_base()

class ModelGenerator:
    """Generates SQLAlchemy and Pydantic models from database metadata."""

    SQL_TYPE_MAPPING = {
        'character varying': (String, str),
        'boolean': (Boolean, bool),
        'integer': (Integer, int),
        'numeric': (Numeric, float),
        'bigint': (BigInteger, int),
        'text': (Text, str),
        'varchar': (String, str),
        'date': (Date, date),
        'time': (Time, time),
        'timestamp': (DateTime, datetime),
        'datetime': (DateTime, datetime),
        'jsonb': (JSON, dict),
        'string_type': (String, str),
    }

    @classmethod
    def generate_sqlalchemy_model(
        cls, 
        table_name: str, 
        columns: List[PyTuple[str, str]], 
        primary_keys: List[str], 
        schema: str
    ) -> Type[Base]:
        """Generate SQLAlchemy model class from table metadata."""
        attrs = {
            '__tablename__': table_name,
            '__table_args__': {'schema': schema}
        }

        print(f"\t\tSQLAlchemy Model")
        for column_name, column_type in columns:
            print(f"\t\t\tColumn: {column_name}: {column_type}")
            column_class, _ = cls.SQL_TYPE_MAPPING.get(column_type, (String, str))
            attrs[column_name] = Column(column_class, primary_key=column_name in primary_keys)

        return type(table_name.capitalize(), (Base,), attrs)

    @classmethod
    def generate_pydantic_model(
        cls, 
        db: Session,
        table: str, 
        schema: str = ''
    ) -> Type[BaseModel]:
        """Generate Pydantic model from table metadata."""
        query = """
            SELECT column_name, data_type 
            FROM information_schema.columns
            WHERE table_name = :table
        """
        if schema:
            query = query + " AND table_schema = :schema"
        columns = db.execute(text(query), {'schema': schema, 'table': table}).fetchall()

        fields = {}
        print(f"\t\tPydantic Model")
        for column_name, column_type in columns:
            print(f"\t\t\tColumn: {column_name}: {column_type}")
            _, pydantic_type = cls.SQL_TYPE_MAPPING.get(column_type, (str, str))
            fields[column_name] = (Optional[pydantic_type], None)

        return create_model(f"{table}Pydantic", **fields)


class ViewModelGenerator(ModelGenerator):
    """Generates SQLAlchemy and Pydantic models for views."""

    @classmethod
    def generate_sqlalchemy_view_model(
        cls, 
        table_name: str,
        columns: List[PyTuple[str, str]], 
        schema: str
    ) -> Type[Base]:
        """Generate SQLAlchemy model class for a view."""
        attrs = {
            '__tablename__': table_name,
            '__table_args__': {'schema': schema}
        }

        print(f"\t\tSQLAlchemy Model")
        primary_keys = []
        for column_name, column_type in columns:
            print(f"\t\t\tColumn: {column_name}: {column_type}")
            column_class, _ = cls.SQL_TYPE_MAPPING.get(column_type, str)
            column = Column(column_class)
            attrs[column_name] = column
            primary_keys.append(column)

        attrs['__mapper_args__'] = {'primary_key': primary_keys}

        return type(table_name.capitalize(), (Base,), attrs)

# Model generation functions
def generate_models(
    engine: Engine, 
    schemas: List[str]
) -> Dict[str, PyTuple[Type[Base], Type[BaseModel]]]:
    """Generate SQLAlchemy and Pydantic models for tables in specified schemas."""
    combined_models = {}
    metadata = MetaData()

    print(f"Generating Table Models")

    for schema in schemas:
        print(f"Schema: {schema.capitalize()}")
        metadata.reflect(bind=engine, schema=schema, extend_existing=True)

        for table_name, table in metadata.tables.items():
            if table.schema == schema:
                table_name = table_name.split('.')[-1]
                print(f"\tTable: {table_name}")
                columns = [(col.name, col.type.__class__.__name__.lower()) for col in table.columns]
                primary_keys = [col.name for col in table.columns if col.primary_key]
                sqlalchemy_model = ModelGenerator.generate_sqlalchemy_model(table_name, columns, primary_keys, schema)
                pydantic_model = ModelGenerator.generate_pydantic_model(engine.connect(), table_name, schema)
                combined_models[table_name] = (sqlalchemy_model, pydantic_model)

    return combined_models

def generate_views(
    engine: Engine, 
    schemas: List[str]
) -> Dict[str, PyTuple[Type[Base], Type[BaseModel]]]:
    """Generate SQLAlchemy and Pydantic models for views in specified schemas."""
    combined_models = {}
    metadata = MetaData()
    metadata.reflect(bind=engine, views=True, extend_existing=True)

    print(f"Generating View Models")

    for schema in schemas:
        print(f"Schema: {schema.capitalize()}")
        for table_name, table in metadata.tables.items():
            if table_name.startswith('report_'):
                table_name = table_name.split('.')[-1]
                print(f"\tView: {table_name}")

                columns = [(col.name, col.type.__class__.__name__.lower()) for col in table.columns]
                sqlalchemy_model = ViewModelGenerator.generate_sqlalchemy_view_model(table_name, columns, schema)
                pydantic_model = ViewModelGenerator.generate_pydantic_model(engine.connect(), table_name, schema)
                combined_models[table_name] = (sqlalchemy_model, pydantic_model)

    return combined_models


# * Database Initialization
db_manager = DatabaseManager()

# * Generate models and views
store_models = generate_models(db_manager.engine, ['store'])
store_views = generate_views(db_manager.engine, ['store'])

# Combine all models (uncomment if needed)
# all_models = {**store_models, **public_views}
