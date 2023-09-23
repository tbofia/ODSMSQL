@ECHO OFF

ECHO "CREATING STATIC TABLE SCRIPTS"

If Exist tblstat.sql Del /s tblstat.sql

For /R Static\ %%G IN (*.sql) do type "%%G" >> tblstat.sql

