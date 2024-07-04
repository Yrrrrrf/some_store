-- File: 01_set_schemas.sql
-- ... [Previous parts of the file remain unchanged] ...

-- Function to add new role and grant privileges on specified schemas
-- This function allows easy addition of new roles with privileges on multiple existing schemas
CREATE OR REPLACE FUNCTION add_schema_and_role(
    p_role_name TEXT,         -- Name of the new role
    p_schema_names TEXT[]     -- Array of schema names to grant privileges on
) RETURNS VOID AS $$
DECLARE
    schema_name TEXT;
BEGIN
    -- Create role
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = p_role_name) THEN
        EXECUTE format('CREATE ROLE %I WITH LOGIN PASSWORD %L', p_role_name, p_role_name || '_password');
        RAISE NOTICE 'Role % created', p_role_name;
    ELSE
        RAISE NOTICE 'Role % already exists', p_role_name;
    END IF;

    -- Grant privileges on specified schemas
    FOREACH schema_name IN ARRAY p_schema_names
    LOOP
        -- Check if schema exists
        IF NOT EXISTS (SELECT FROM information_schema.schemata WHERE schema_name = schema_name) THEN
            RAISE EXCEPTION 'Schema % does not exist', schema_name;
        END IF;

        -- Grant privileges on the schema
        EXECUTE format('GRANT USAGE, CREATE ON SCHEMA %I TO %I', schema_name, p_role_name);
        EXECUTE format('GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA %I TO %I', schema_name, p_role_name);
        EXECUTE format('GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA %I TO %I', schema_name, p_role_name);
        EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT ALL PRIVILEGES ON TABLES TO %I', schema_name, p_role_name);
        EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT ALL PRIVILEGES ON SEQUENCES TO %I', schema_name, p_role_name);
        EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT ALL PRIVILEGES ON FUNCTIONS TO %I', schema_name, p_role_name);

        RAISE NOTICE 'Privileges granted to % on schema %', p_role_name, schema_name;
    END LOOP;

    -- Grant public schema access
    EXECUTE format('GRANT USAGE, CREATE ON SCHEMA public TO %I', p_role_name);
    EXECUTE format('GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO %I', p_role_name);
    EXECUTE format('GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO %I', p_role_name);
    EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO %I', p_role_name);
    EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO %I', p_role_name);
    EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON FUNCTIONS TO %I', p_role_name);

    RAISE NOTICE 'Public schema privileges granted to %', p_role_name;

    RAISE NOTICE 'Role % created and granted privileges on specified schemas', p_role_name;
END;
$$ LANGUAGE plpgsql;

-- Example usage of the improved add_schema_and_role function
-- To add a new role with privileges on multiple schemas, use:
-- SELECT add_schema_and_role('new_role', ARRAY['schema1', 'schema2', 'schema3']);

-- Note: Ensure that the schemas exist before calling this function.
-- You may want to create schemas separately before using this function.

-- Function to create a new schema (if needed)
CREATE OR REPLACE FUNCTION create_schema_if_not_exists(
    p_schema_name TEXT
) RETURNS VOID AS $$
BEGIN
    IF NOT EXISTS (SELECT FROM information_schema.schemata WHERE schema_name = p_schema_name) THEN
        EXECUTE format('CREATE SCHEMA %I', p_schema_name);
        RAISE NOTICE 'Schema % created', p_schema_name;
    ELSE
        RAISE NOTICE 'Schema % already exists', p_schema_name;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Example of creating schemas and then adding a role with privileges
SELECT create_schema_if_not_exists('store');
-- SELECT create_schema_if_not_exists('some_other_schema');
-- SELECT create_schema_if_not_exists('another_schema');
-- SELECT add_schema_and_role('new_role', ARRAY['store', 'some_other_schema', 'another_schema']);
