@ECHO OFF

ECHO "CREATING DYNAMIC STORED PROCEDURES..."

type  dynamic\*.sql > spdyn.sql
type  dynamic\after\*.sql >> spdyn.sql

