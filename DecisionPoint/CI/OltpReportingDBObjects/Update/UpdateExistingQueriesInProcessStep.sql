/*Set the table name and column name of New Column*/
DECLARE @TableName VARCHAR(50) = 'prf_Profile'
DECLARE @ColumnName VARCHAR(50) = 'ModifierExempted'
DECLARE @AppVersion VARCHAR(10) = '10.4'

/*Now we are going to add the column to existing queries in ProcessStep table*/
UPDATE rpt.ProcessStep
SET IncrementalSql=REPLACE(IncrementalSql,'ct.SYS_CHANGE_OPERATION',' NULL AS ' + @ColumnName +' ,'+ CHAR(13) + CHAR(10) +'ct.SYS_CHANGE_OPERATION')
FROM rpt.ProcessStep ps
JOIN rpt.Process p ON ps.ProcessId=p.ProcessId
WHERE p.BaseFileName = @TableName
AND  CAST('/' + REPLACE(MinAppVersion,'.','.1') + '/' AS HIERARCHYID) < CAST('/' + REPLACE(@AppVersion,'.','.1') + '/' AS HIERARCHYID) 
AND IncrementalSql NOT LIKE '%'+@ColumnName+'%'

UPDATE rpt.ProcessStep
SET FullSql=REPLACE(FullSql,'''I''',' NULL AS '+ @ColumnName +' ,' + CHAR(13) + CHAR(10) + '''I''')
FROM rpt.ProcessStep ps
JOIN rpt.Process p ON ps.ProcessId=p.ProcessId
WHERE p.BaseFileName = @TableName
AND  CAST('/' + REPLACE(MinAppVersion,'.','.1') + '/' AS HIERARCHYID) < CAST('/' + REPLACE(@AppVersion,'.','.1') + '/' AS HIERARCHYID) 
AND FullSql NOT LIKE '%'+@ColumnName+'%'

/*Now we are going to add the column to existing queries in ProcessStep table*/
UPDATE rpt.ProcessStep
SET IncrementalSql=REPLACE(IncrementalSql,'ct.SYS_CHANGE_OPERATION',' '+@TableName+'.'+@ColumnName +' ,'+ CHAR(13) + CHAR(10) +'ct.SYS_CHANGE_OPERATION')
FROM rpt.ProcessStep ps
JOIN rpt.Process p ON ps.ProcessId=p.ProcessId
WHERE p.BaseFileName = @TableName
AND  CAST('/' + REPLACE(MinAppVersion,'.','.1') + '/' AS HIERARCHYID) >= CAST('/' + REPLACE(@AppVersion,'.','.1') + '/' AS HIERARCHYID) 
AND IncrementalSql NOT LIKE '%'+@ColumnName+'%'

UPDATE rpt.ProcessStep
SET FullSql=REPLACE(FullSql,'''I''',' '+@TableName+'.'+@ColumnName +' ,' + CHAR(13) + CHAR(10) + '''I''')
FROM rpt.ProcessStep ps
JOIN rpt.Process p ON ps.ProcessId=p.ProcessId
WHERE p.BaseFileName = @TableName
AND  CAST('/' + REPLACE(MinAppVersion,'.','.1') + '/' AS HIERARCHYID) >= CAST('/' + REPLACE(@AppVersion,'.','.1') + '/' AS HIERARCHYID) 
AND FullSql NOT LIKE '%'+@ColumnName+'%'


