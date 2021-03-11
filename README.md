# shbf-recipe-db
PostgreSQL database for shbf-recipe web

## Installation (Quick and dirty)
Create a database called shbf in your postgres installation

    CREATE DATABASE <db-name>;

Create a user that's your local user

    CREATE ROLE <whatever-local-username-you-have> WITH LOGIN SUPERUSER;

Perhaps you need to check pg_hba.conf depending on your distro/os.

Lastly, from the base directory

    ./install.sh <db-name>

## Installation (Docker)

Run the install script

    ./install_with_docker.sh
