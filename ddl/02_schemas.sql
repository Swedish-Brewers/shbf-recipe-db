-- Drop the public schema
DROP SCHEMA IF EXISTS public CASCADE;

-- Create the schemas
CREATE SCHEMA IF NOT EXISTS data AUTHORIZATION shbf_writer;
COMMENT ON SCHEMA data IS 'All tables and data for all of recipes.';

CREATE SCHEMA IF NOT EXISTS functions AUTHORIZATION shbf_writer;
COMMENT ON SCHEMA functions IS 'All functions that will query/use the data schema.';
