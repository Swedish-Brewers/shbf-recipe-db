FROM postgres:13.2

COPY db /shbf/db
COPY ddl /shbf/ddl
COPY sql /shbf/sql
COPY docker-install.sh /docker-entrypoint-initdb.d
