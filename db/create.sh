#!/bin/sh

PGHOST=dbhost.example.com

DATABASE="corylus"
DB_TEST=${DATABASE}_test

psql template1 -c "create database ${DATABASE} WITH ENCODING='UTF8' template=template0;"
psql template1 -c "create database ${DB_TEST} WITH ENCODING='UTF8' template=template0;"
psql ${DATABASE} < countries.sql
psql ${DB_TEST} < countries.sql
psql ${DATABASE} < tables.sql
psql ${DB_TEST} < tables.sql
