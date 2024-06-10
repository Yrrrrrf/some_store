-- -- In postgresql, database creation is outside the scope of SQL scripts run within a database connection.

-- Create a new user with a specified username and password
DO
$$
BEGIN
    IF NOT EXISTS (
        SELECT
        FROM   pg_catalog.pg_roles
        WHERE  rolname = 'some_store_owner') THEN

        CREATE ROLE some_store_owner LOGIN PASSWORD 'store_password';
    END IF;
END
$$;

-- Drop the database if it exists
DROP DATABASE IF EXISTS some_store;

-- Create the database and assign ownership to the new user
CREATE DATABASE some_store
    WITH OWNER = some_store_owner  -- owner of the database
    -- or avoid all of this giving the ownership to the user that will be used to connect to the database...
    ENCODING = 'UTF8'  -- character encoding
    LOCALE_PROVIDER = 'libc'  -- locale provider (libc or icu), it is used to determine the locale settings for the database
    CONNECTION LIMIT = -1  -- maximum number of concurrent connections to the database (-1 means no limit)
    IS_TEMPLATE = False;  -- whether this database can be cloned as a template for creating new databases


-- Grant all privileges on the database to the new user
GRANT ALL PRIVILEGES ON DATABASE some_store TO some_store_owner;

-- Grant all privileges on all schemas to the new user
GRANT ALL PRIVILEGES ON SCHEMA public TO some_store_owner;

-- Grant all privileges on all tables, sequences, and functions in all schemas to the new user
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO some_store_owner;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO some_store_owner;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO some_store_owner;

-- Ensure default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO some_store_owner;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO some_store_owner;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON FUNCTIONS TO some_store_owner;
