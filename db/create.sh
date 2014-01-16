#!/bin/sh

PGHOST=dbhost.example.com

DATABASE="corylus"

psql template1 -c "create database ${DATABASE} WITH ENCODING='UTF8' template=template0;"
psql template1 -c "create database ${DB_TEST} WITH ENCODING='UTF8' template=template0;"
psql ${DATABASE} < countries.sql
psql ${DATABASE} < tables.sql
psql ${DATABASE} < initial_values.sql
