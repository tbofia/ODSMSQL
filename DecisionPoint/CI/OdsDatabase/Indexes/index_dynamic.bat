@ECHO OFF

ECHO "CREATING DYNAMIC INDEXES..."


If Exist idxdyn.sql Del /s idxdyn.sql

For /R Dynamic\ %%G IN (*.sql) do type "%%G" >> idxdyn.sql