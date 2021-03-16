--
-- Documentation:
--
-- * Creates the main database. This script is mainly meant for docker
--
CREATE DATABASE shbf;
CREATE ROLE shbf WITH LOGIN SUPERUSER PASSWORD 'shbf'