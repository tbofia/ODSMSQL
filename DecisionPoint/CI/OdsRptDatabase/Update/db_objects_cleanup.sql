IF OBJECT_ID('adm.Customer', 'U') IS NOT NULL
DROP TABLE adm.Customer
GO

-- Drop All Reporting Jobs
DECLARE  @ReportJobName VARCHAR(255)
		,@SQLScript VARCHAR(255);

DECLARE db_job_list_cursor CURSOR FOR 
SELECT ReportJobName FROM adm.ReportJob

OPEN db_job_list_cursor 
FETCH NEXT FROM db_job_list_cursor INTO @ReportJobName

WHILE @@FETCH_STATUS = 0   
BEGIN 

SET @SQLScript = '
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'''+@ReportJobName+''')'+'
EXEC msdb.dbo.sp_delete_job  @job_name = N'''+@ReportJobName+''''
EXEC (@SQLScript);

FETCH NEXT FROM db_job_list_cursor INTO @ReportJobName

END

CLOSE db_job_list_cursor
DEALLOCATE db_job_list_cursor
GO
