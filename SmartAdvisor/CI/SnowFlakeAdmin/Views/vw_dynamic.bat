@ECHO OFF

ECHO "CREATING DYNAMIC VIEWS..."

If Exist vwdyn.sql Del /s vwdyn.sql

For /R Dynamic\ %%G IN (*.sql) do type "%%G" >> vwdyn.sql
