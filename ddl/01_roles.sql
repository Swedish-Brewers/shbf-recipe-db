--
-- Documentation:
--
-- * Roles to create in the database
--

DO
$do$
BEGIN
    IF NOT EXISTS
    (
        SELECT FROM pg_catalog.pg_roles WHERE rolname = 'shbf_writer'
    )
    THEN
        CREATE ROLE shbf_writer WITH NOLOGIN;
    END IF;
END
$do$;

DO
$do$
BEGIN
    IF NOT EXISTS
    (
        SELECT FROM pg_catalog.pg_roles WHERE rolname = 'shbf_reader'
    )
    THEN
        CREATE ROLE shbf_reader WITH NOLOGIN;
    END IF;
END
$do$;

DO
$do$
BEGIN
    IF NOT EXISTS
    (
        SELECT FROM pg_catalog.pg_roles WHERE rolname = 'shbf_api'
    )
    THEN
        CREATE ROLE shbf_api WITH LOGIN;
    END IF;
END
$do$;
