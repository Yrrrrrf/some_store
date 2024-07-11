from dotenv import load_dotenv
from crud_forge.db import DatabaseManager
from crud_forge.generators.models import generate_models, generate_views

import os

# Load environment variables
load_dotenv()

# * Database Configuration
DB_NAME = os.getenv("DB_NAME")
DB_HOST = os.getenv("DB_HOST")
DB_OWNER_ADMIN = os.getenv("DB_OWNER_ADMIN")
DB_OWNER_PWORD = os.getenv("DB_OWNER_PWORD")

url: str = f"postgresql://{DB_OWNER_ADMIN}:{DB_OWNER_PWORD}@{DB_HOST}/{DB_NAME}"

# * Database Initialization
db_manager = DatabaseManager(url)

# * Generate models and views
store_models = generate_models(db_manager.engine, ['store'])
store_views = generate_views(db_manager.engine, ['store'])
