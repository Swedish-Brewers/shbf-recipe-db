--
-- Documentation:
--
-- * Roles to create in the database
--

DO $$
BEGIN

    IF NOT EXISTS
    (
        SELECT FROM pg_catalog.pg_roles WHERE rolname = 'shbf_writer'
    )
    THEN
        CREATE ROLE shbf_writer WITH NOLOGIN;
    END IF;

    IF NOT EXISTS
    (
        SELECT FROM pg_catalog.pg_roles WHERE rolname = 'shbf_reader'
    )
    THEN
        CREATE ROLE shbf_reader WITH NOLOGIN;
    END IF;

    IF NOT EXISTS
    (
        SELECT FROM pg_catalog.pg_roles WHERE rolname = 'shbf_api'
    )
    THEN
        CREATE ROLE shbf_api WITH LOGIN;
        GRANT shbf_reader TO shbf_api;
    END IF;

    IF NOT EXISTS
    (
        SELECT FROM pg_catalog.pg_roles WHERE rolname = 'shbf_import'
    )
    THEN
        CREATE ROLE shbf_import WITH LOGIN;
        GRANT shbf_writer TO shbf_import;
    END IF;

END
$$;
