-- File: 00_complete_db_setup.sql
-- Description: This script creates the 'some_store' database, its owner role,
--              and sets up the schema, permissions, and extensions.
-- Note: This script should be run by a PostgreSQL superuser.

-- Step 1: Create the database and role
DO $$
DECLARE
    db_name TEXT := 'some_store';
    db_owner TEXT := 'some_store_owner';
    db_owner_password TEXT := 'store_password';
BEGIN
    -- Create a new user with a specified username and password
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = db_owner) THEN
        EXECUTE format('CREATE ROLE %I LOGIN PASSWORD %L', db_owner, db_owner_password);
        RAISE NOTICE 'Role % created successfully', db_owner;
    ELSE
        RAISE NOTICE 'Role % already exists', db_owner;
    END IF;

    -- Attempt to drop the database if it exists
    BEGIN
        EXECUTE format('DROP DATABASE IF EXISTS %I', db_name);
        RAISE NOTICE 'Database % dropped (if it existed)', db_name;
    EXCEPTION
        WHEN object_in_use THEN
            RAISE EXCEPTION 'Could not drop database % because it is in use', db_name;
    END;

    -- Create the database and assign ownership to the new user
    BEGIN
        EXECUTE format('
            CREATE DATABASE %I
            WITH
            OWNER = %I
            ENCODING = ''UTF8''
            LC_COLLATE = ''en_US.UTF-8''
            LC_CTYPE = ''en_US.UTF-8''
            TEMPLATE = template0
            TABLESPACE = pg_default
            CONNECTION LIMIT = -1
            IS_TEMPLATE = False
        ', db_name, db_owner);

        RAISE NOTICE 'Database % created successfully with owner %', db_name, db_owner;
    EXCEPTION
        WHEN duplicate_database THEN
            RAISE EXCEPTION 'Database % already exists', db_name;
    END;
END $$;

-- Step 2: Connect to the new database and set it up
\c some_store

DO $$
BEGIN
    -- Create the 'store' schema
    CREATE SCHEMA IF NOT EXISTS store;

    -- Grant privileges
    EXECUTE format('GRANT ALL PRIVILEGES ON DATABASE %I TO %I', 'some_store', 'some_store_owner');
    EXECUTE format('GRANT ALL PRIVILEGES ON SCHEMA public, store TO %I', 'some_store_owner');
    EXECUTE format('GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public, store TO %I', 'some_store_owner');
    EXECUTE format('GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public, store TO %I', 'some_store_owner');
    EXECUTE format('GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public, store TO %I', 'some_store_owner');

    -- Ensure default privileges for future objects
    EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA public, store GRANT ALL PRIVILEGES ON TABLES TO %I', 'some_store_owner');
    EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA public, store GRANT ALL PRIVILEGES ON SEQUENCES TO %I', 'some_store_owner');
    EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA public, store GRANT ALL PRIVILEGES ON FUNCTIONS TO %I', 'some_store_owner');

    RAISE NOTICE 'All privileges granted to some_store_owner on database some_store';

    -- Set default schema search path
    EXECUTE 'ALTER DATABASE some_store SET search_path TO store, public';

    -- Enable some useful extensions
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    CREATE EXTENSION IF NOT EXISTS "pgcrypto";

    RAISE NOTICE 'Database setup completed successfully.';
END $$;