-- ACADEMIC HUB DATABASE SCHEMA


DO $$
DECLARE
    schemas TEXT[] := ARRAY[  -- List of all schema names
        'store'
--         'infrastructure_management',  -- infrastructure management schema
--         'library_management',  -- library management schema
--         'school_management'  -- school management schema
--         'payment_management'
        ];
    schema_name TEXT;
BEGIN
    FOREACH schema_name IN ARRAY schemas LOOP
        EXECUTE format('DROP SCHEMA IF EXISTS %I CASCADE', schema_name);
        EXECUTE format('CREATE SCHEMA IF NOT EXISTS %I', schema_name);
    END LOOP;
END $$;

SET search_path TO auth;  -- Set search path first

-- Create the role that will be used to manage one specific schema (some admin role)
CREATE OR REPLACE FUNCTION create_and_grant_role(
    role_name TEXT,
    role_password TEXT,
    schema_names TEXT[] -- array of schema names
) RETURNS VOID AS $$
DECLARE  -- Declare variables (for dynamic SQL)
    schema_name TEXT;  -- Variable to store schema name
BEGIN
    -- Create role if it does not exist
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = role_name) THEN
        EXECUTE format('CREATE ROLE %I WITH LOGIN PASSWORD %L', role_name, role_password);
        RAISE NOTICE 'Role % created successfully.', role_name;
    ELSE RAISE NOTICE 'Role % already exists.', role_name;
    END IF;

    FOREACH schema_name IN ARRAY schema_names LOOP  -- Loop through each schema and grant privileges
        -- Grant usage and create privileges on schema
        EXECUTE format('GRANT USAGE, CREATE ON SCHEMA %I TO %I', schema_name, role_name);
        EXECUTE format('GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA %I TO %I', schema_name, role_name);
        EXECUTE format('GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA %I TO %I', schema_name, role_name);
        -- Grant default privileges on schema (for future tables and sequences)
        EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT ALL PRIVILEGES ON SEQUENCES TO %I', schema_name, role_name);
        EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT ALL PRIVILEGES ON SEQUENCES TO %I', schema_name, role_name);
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Create roles and grant privileges to them...

SELECT create_and_grant_role(
    'store_owner',
    'store_password',
    ARRAY['public', 'store']
);

SELECT create_and_grant_role(
    'school_admin',
    'school_password',
    ARRAY['public', 'infrastructure_management',  'school_management']
);

SELECT create_and_grant_role(
    'library_admin',
    'library_password',
    ARRAY['public', 'infrastructure_management', 'library_management']
);

-- SELECT create_and_grant_role(
--     'payment_admin',
--     'some_payment_password',
--     ARRAY['public', 'payment_management']
-- );

-- SELECT create_and_grant_role(
--     'security_admin',
--     'some_security_password',
-- --     ARRAY['public', 'security_management']
-- );


-- todo: Fix the error that do not allow to grant privileges to the roles!
-- The error only happens when using this file as executable script for src/setup.py
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public, infrastructure_management TO infrastructure_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public, infrastructure_management TO infrastructure_admin;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public, infrastructure_management, school_management TO school_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public, infrastructure_management, school_management TO school_admin;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public, infrastructure_management, library_management TO library_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public, infrastructure_management, library_management TO library_admin;

