#!/bin/bash

cd /shbf

cd db
psql -f install.sql

cd ../ddl
psql shbf -f install.sql

cd ../sql
psql shbf -f install.sql
