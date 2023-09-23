/*Set the table name and column name of New Column*/
DECLARE @TableName VARCHAR(50) = 'prf_Profile'
DECLARE @ColumnName VARCHAR(50) = 'AssistantCoSurgeonModifiers'
DECLARE @AppVersion VARCHAR(10) = '10.1'


/*Now we are going to add the column to existing queries in ProcessStep table*/
UPDATE rpt.ProcessStep
SET IncrementalSql=REPLACE(IncrementalSql,''+@TableName+'.'+@ColumnName+'','NULL AS '+@ColumnName+'')
FROM rpt.ProcessStep ps
JOIN rpt.Process p ON ps.ProcessId=p.ProcessId
WHERE p.BaseFileName = @TableName
AND  CAST('/' + REPLACE(MinAppVersion,'.','.1') + '/' AS HIERARCHYID) >= CAST('/' + REPLACE(@AppVersion,'.','.1') + '/' AS HIERARCHYID) 
AND IncrementalSql NOT LIKE '%NULL AS '+@ColumnName+'%'

UPDATE rpt.ProcessStep
SET FullSql=REPLACE(FullSql,''+@TableName+'.'+@ColumnName+'','NULL AS '+@ColumnName+'')
FROM rpt.ProcessStep ps
JOIN rpt.Process p ON ps.ProcessId=p.ProcessId
WHERE p.BaseFileName = @TableName
AND  CAST('/' + REPLACE(MinAppVersion,'.','.1') + '/' AS HIERARCHYID) >= CAST('/' + REPLACE(@AppVersion,'.','.1') + '/' AS HIERARCHYID) 
AND Fullsql NOT LIKE '%NULL AS '+@ColumnName+'%'


