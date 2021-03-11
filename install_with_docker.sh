#!/bin/bash

if ! command -v psql &> /dev/null
then
    echo "psql could not be found!"
    exit 1
fi

if ! command -v docker &> /dev/null
then
    echo "docker could not be found!"
    exit 1
fi

if ! command -v pg_isready &> /dev/null
then
    echo "pg_isready could not be found!"
    exit 1
fi

# Create the docker image
docker run --name shbf-postgres -p 5433:5432 -e POSTGRES_PASSWORD=shbf -d postgres:13.2

until pg_isready -d postgres -h localhost -p 5433 -t 15 2>/dev/null; do
  sleep 2
done

PGPASSWORD=shbf psql -h localhost -p 5433 -U postgres postgres -c "CREATE DATABASE shbf;"
PGPASSWORD=shbf psql -h localhost -p 5433 -U postgres postgres -c "CREATE ROLE shbf WITH LOGIN SUPERUSER PASSWORD 'shbf';"

cd ddl
PGPASSWORD=shbf psql -h localhost -p 5433 -U shbf shbf -f install.sql

cd ../sql
PGPASSWORD=shbf psql -h localhost -p 5433 -U shbf shbf -f install.sql

echo ""
echo "You can now connect with: \"psql -h localhost -p 5433 -U shbf shbf\" (password: shbf)"
echo ""
