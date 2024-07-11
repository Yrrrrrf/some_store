from functools import reduce
import os
from dotenv import load_dotenv

from sqlalchemy import create_engine
from sqlalchemy.sql import text


load_dotenv()  # * Load environment variables from .env file


DB_NAME = os.getenv('DB_NAME', 'academic_hub')  # Default to academic_hub if DB_NAME is not set
DB_HOST = os.getenv('DB_HOST', 'localhost')  # Default to 127.0.0.1 if DB_HOST is not set
DB_OWNER = os.getenv('DB_OWNER_ADMIN', 'academic_hub_owner')  # Default to academic_hub_owner if DB_OWNER is not set
DB_OWNER_PWORD = os.getenv('DB_OWNER_PWORD', 'academic_password')  # Default to academic_password if DB_OWNER_PWORD is not set

engine = create_engine(f'postgresql://{DB_OWNER}:{DB_OWNER_PWORD}@{DB_HOST}/{DB_NAME}')


# * Get passwords from environment variables
def _get_admin_credentials(admin_type: str) -> tuple[str, str]:
    return os.getenv(f"{admin_type}_ADMIN"), os.getenv(f"{admin_type}_PWORD")


db_owner, db_owner_password = _get_admin_credentials("DB_OWNER")
infrastructure_admin, infrastructure_admin_password = _get_admin_credentials("INFRASTRUCTURE")
school_admin, school_admin_password = _get_admin_credentials("SCHOOL")
library_admin, library_admin_password = _get_admin_credentials("LIBRARY")

placeholders: dict = {  # placeholders for the SQL files
    "infrastructure_admin": infrastructure_admin,
    "infra_password": infrastructure_admin_password,
    "school_admin": school_admin,
    "school_password": school_admin_password,
    "library_admin": library_admin,
    "library_password": library_admin_password,
}
# print(f"\n\033[95mPlaceholders\033[0m: {placeholders}")

# * Load the SQL files
def _filter_views(excluded_words: list[str], files: list[str]) -> list[str]:
    return [f for f in files if not any(word in f for word in excluded_words)]

sql_files_name: list[str] = _filter_views(
    ["views", "triggers",],  # ignore views and triggers
    [f for f in os.listdir("sql") if f.endswith(".sql")]  # '*.sql'
)

def _replace_placeholders(file_content: str, placeholders: list[tuple[str, str]]) -> str:
    return reduce(lambda content, pv: content.replace(*pv), placeholders, file_content)

sql_files_content: list[str] = [  # Get the content of the SQL files
    _replace_placeholders(  # replace the placeholders in the SQL files
        open(f"sql/{file}", "r").read(),
        placeholders.items()
    ) for file in sql_files_name  # ignore the first file (00_create_db.sql)
]

# print(sql_files_content[1])

sql_files: list[tuple[str, str]] = zip(sql_files_name, sql_files_content)
next(sql_files)  # remove the first element of the zip object
print(sql_files_content[1])

with engine.connect() as conn:
    print(f"\n\033[95mConnected\033[0m to \033[3m{DB_NAME}\033[0m as \033[3m{DB_OWNER}\033[0m") 

    for file, file_content in sql_files:
        if file_content:
            conn.execute(text(file_content))
            print(f"\t\033[92mExecuted\033[0m {file}...")

    conn.commit()  # commit all changes (since we are using a connection)
    print("\n\t\033[92mCommitted\033[0m all changes")

    conn.close()  # close the connection & cleanup
    print("\033[95mClosed\033[0m the connection to the database.")
