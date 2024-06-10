<h1 align="center">
    <img src="./assets/icons/diary.png" alt="Academic Hub Icon" width="128">
    <div align="center">Academic Hub</div>
</h1>

[<img alt="github" src="https://img.shields.io/badge/github-Yrrrrrf%2Facademic__hub-58A6FF?style=for-the-badge&logo=github" height="24">](https://github.com/Yrrrrrf/academic_hub)

[//]: # ([<img alt="documentation" src="https://img.shields.io/badge/documentation-100%25-66c2a5?style=for-the-badge&logo=read-the-docs&labelColor=555555" height="24">]&#40;#documentation-section&#41;)

Academic Hub is a comprehensive platform designed to manage academic resources and data, including library inventory, academic user information (students, teachers, etc.), grade history, and more. The system is built on a relational database, supporting various academic operations and providing detailed reports for educational institutions.

## Setup

### Prerequisites

Install the [PostgreSQL](https://www.postgresql.org/download/) database server and used files inside the [sql](./sql) folder to create the database schema and populate it with sample data.

Use the latest version of [Python](https://www.python.org/downloads/).

Use [npm](https://www.npmjs.com/get-npm) to run the frontend application.

### Installation

Install the required packages using the following command:
```bash
# using pip
pip install -r requirements.txt  # using pip
# using conda or mamba
conda install --file requirements.txt  # using conda
mamba install --file requirements.txt  # using mamba
```

Install the `npm` package manager and the `svelte` framework to run the frontend application.
```bash
cd hub  # change to the frontend directory (svelte app)
npm install  # install the required packages
```

Create the [.env](./.env) file in the root directory and **add the following environment variables** to configure private database credentials:
```bash
# * Database (PostgreSQL)
DB_NAME = "academic_hub"
DB_HOST = "localhost"
DB_PORT = "5432"
DB_OWNER = "postgres"
DB_OWNER_PASSWORD = "fire"

# * Authentication main settings
SECRET_KEY = "some_secret_key"
ALGORITHM = "HS256"
ACCESS_TOKEN_TIME = 30

# * db admins credentials
# these users are the ones that will be used to connect to the database (have access to only some schemas to manage an specific part of the system)
INFRASTRUCTURE_ADMIN = "infrastructure_admin"
INFRASTRUCTURE_PWORD = "some_new_infra_password"

SCHOOL_ADMIN = "school_admin"
SCHOOL_PWORD = "some_new_school_password"

LIBRARY_ADMIN = "library_admin"
LIBRARY_PWORD = "some_new_library_password"
```

Execute the [00_create_db.sql](./sql/00_create_db.sql) file with a superuser to create the database to create the database.

Once created the database. Use the [setup.py](./src/setup.py) script to create the database schemas and populate it with sample data using the following command:
```bash
python src/setup.py
```


## Database Schema

![db entity relationship diagram](./assets/static/db_erd.png)

## Running the Application

- Run the API server using the following command:
```bash
uvicorn src.main:app --reload --host 127.0.0.1 --port 8000
# or 
python src/main.py  # run the API server (this way doesn't support live reload)
```
- Look for the API documentation at [port/docs#/](http://127.0.0.1:8000/docs#/)

- Excecute the frontend application using the following command:
```bash
cd hub  # change to the frontend directory (svelte app)
npm run dev  # run the frontend application
```
- Access the frontend application at [port 5173](http://localhost:5173/)

## [License](./LICENSE)

This project is licensed under the terms of the MIT license.
