--
-- Documentation:
--
-- * Grants for all schemas
--

-- DATA SCHEMA
GRANT ALL ON SCHEMA data TO shbf_writer;
GRANT USAGE ON SCHEMA data TO shbf_reader;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA data TO shbf_writer;
GRANT SELECT ON ALL TABLES IN SCHEMA data TO shbf_reader;

-- FUNCTIONS SCHEMA
GRANT ALL ON SCHEMA functions TO shbf_writer;
GRANT USAGE ON SCHEMA functions TO shbf_reader;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA functions TO shbf_writer;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA functions TO shbf_reader;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA functions FROM PUBLIC;
