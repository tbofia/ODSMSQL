-- remove the rows affected message 
SET NOCOUNT ON;

-- This script is using environment variables to determine database to run for.
SELECT 'bcp '+TABLE_CATALOG+'.'+TABLE_SCHEMA+'.'+TABLE_NAME+' format nul -f '+'$(formatfilespath_)'+'$(odsversion_)'+'\'+TABLE_NAME+'.fmt -c -T -t ^' +REPLACE(P.FileColumnDelimiter,'^','^^')+' /S '+'$(server_)'
FROM $(database_).INFORMATION_SCHEMA.Tables I 
INNER JOIN $(database_).adm.Process P 
	ON P.TargetTableName = I.TABLE_NAME 
WHERE TABLE_SCHEMA = 'stg' 
	AND TABLE_TYPE = 'BASE TABLE'
