
/*Set the database where you want to update existing Full and Incremental SQL statements*/
USE MMedical_Safeco

/*Set the table name and column name of New Column*/
DECLARE @TableName VARCHAR(50) = 'CLAIMANT'
DECLARE @ColumnName VARCHAR(50) = 'SetPreAllocation'

/*Now we are going to add the column to existing queries in ProcessStep table*/
UPDATE rpt.ProcessStep
SET IncrementalSql=REPLACE(IncrementalSql,'ct.SYS_CHANGE_OPERATION','NULL AS '+ @TableName + '.' + @ColumnName +' ,'+ CHAR(13) + CHAR(10) +'ct.SYS_CHANGE_OPERATION')
FROM rpt.ProcessStep ps
JOIN rpt.Process p ON ps.ProcessId=p.ProcessId
WHERE p.BaseFileName = @TableName
AND MinAppVersion <> (SELECT TOP 1 LEFT(AppVersion,3) FROM dbo.AppVersion ORDER BY AppVersionId DESC)

UPDATE rpt.ProcessStep
SET FullSql=REPLACE(FullSql,'''I''','NULL AS '+ @TableName + '.' + @ColumnName +' ,' + CHAR(13) + CHAR(10) + '''I''')
FROM rpt.ProcessStep ps
JOIN rpt.Process p ON ps.ProcessId=p.ProcessId
WHERE p.BaseFileName = @TableName
AND MinAppVersion <> (SELECT TOP 1 left(AppVersion,3) FROM dbo.AppVersion ORDER BY AppVersionId DESC)

