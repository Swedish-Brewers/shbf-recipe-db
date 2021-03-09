#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: ./install.sh <db-name>"
    exit 1
fi

cd ddl
psql ${1} -f install.sql

cd ../sql
psql ${1} -f install.sql
