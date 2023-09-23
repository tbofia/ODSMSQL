IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'adm.Mnt_GetCustomerList') AND type in (N'P', N'PC'))
DROP PROCEDURE adm.Mnt_GetCustomerList
GO

CREATE PROCEDURE adm.Mnt_GetCustomerList(
 @ReportId INT = 0 
,@ReportType INT = 0
,@SourceDatabaseName VARCHAR(50) = 'AcsOds'
,@CustomerListType INT = 0
)
AS
BEGIN
-- DECLARE @ReportId INT = 1 ,@ReportType INT = 1,@SourceDatabaseName VARCHAR(50) = 'AcsOds',@CustomerListType INT = -1
DECLARE  @ReportName VARCHAR(255)
		,@SQLScript NVARCHAR(MAX)
		,@TrackingTable VARCHAR(255);
		
-- Get report Name
SET @SQLScript = 'SELECT @ReportName = RTRIM(LTRIM(REPLACE(REPLACE(ReportJobName,''RPT:'',''''),''ETL:'',''''))) FROM adm.ReportJob WHERE ReportID = '+CAST(@ReportId AS VARCHAR(3));
EXEC sp_executesql @SQLScript,N'@ReportName VARCHAR(255) out',@ReportName out;

-- Get Tracking table Name
SELECT @TrackingTable = TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE='BASE TABLE'
	AND TABLE_NAME LIKE REPLACE(@ReportName,' ','_')+'_Tracking%';

-- Get List of customers to run for by crossing against tracking table	
SET @SQLScript = 
'SELECT DISTINCT C.CustomerId
 FROM '+@SourceDatabaseName+'.adm.Customer C
 INNER JOIN rpt.CustomerReportSubscription I
	ON C.CustomerId = I.CustomerId
	AND I.ReportId = '+CAST(@ReportId AS VARCHAR(5))+'
	AND I.IsActive = 1
 LEFT OUTER JOIN stg.'+@TrackingTable+' T 
	ON C.CustomerId = T.OdsCustomerId 
	AND T.ReportTypeId = '+CAST(@ReportType AS CHAR(2))+'
 WHERE C.UseForReporting = 1 
 AND(T.IsCustomerDone IS NULL OR T.IsCustomerDone = 0)
 AND C.CustomerId = CASE WHEN '+CAST(@CustomerListType AS VARCHAR(5))+' = -1 THEN C.CustomerId ELSE '+CAST(@CustomerListType AS VARCHAR(5))+' END
 '+CASE WHEN @CustomerListType = -1 THEN 'AND C.CustomerId <> 0' ELSE '' END;
 
EXEC(@SQLScript);

END
GO

 
 IF OBJECT_ID('adm.Mnt_SendReportNotification', 'P') IS NOT NULL
    DROP PROCEDURE adm.Mnt_SendReportNotification
GO
CREATE PROCEDURE adm.Mnt_SendReportNotification(
@ReportId INT = 0,
@SourceDatabaseName VARCHAR(50)='AcsOds',
@recipients_param VARCHAR(100))
AS
BEGIN
-- DECLARE @ReportId INT = 1,@ReportType INT = 1,@SourceDatabaseName VARCHAR(50)='AcsOds',@recipients_param VARCHAR(100) = 'theodore.bofia@mitchell.com';
DECLARE  @ReportName VARCHAR(255)
		,@spooling_job_name VARCHAR(255)
		,@CustomerName VARCHAR(255)
		,@NoOfCustomersUsedforReporting INT
		,@NoOfCustomersInReport INT
		,@SQLScript NVARCHAR(MAX)
		,@TrackingTable VARCHAR(255)
		,@OutputTableName VARCHAR(255)
		,@FilterDateColumnName VARCHAR(255)
		,@LastRunDate VARCHAR(100)
		,@LastRunDuration VARCHAR(20)
		,@Status INT = -1
		,@EmailSubject VARCHAR(255)
		,@Header1Text VARCHAR(255);

DECLARE  @SummaryTable AS TABLE (
		 OdsCustomerId INT
		,CustomerName VARCHAR(255)  
		,IsActive INT      
		,NumberOfRecords INT
		,FilterDateCutOff DATETIME
		,LastRunDate DATETIME);

-- Set Status text

DECLARE @tableHTML  NVARCHAR(MAX);
DECLARE @EmailHeader VARCHAR(1000) = 
	N'	<B><H1><font FONT FACE="VERDANA" SIZE=4 color="#154360">Header1Text</font></H1></B>
		<H2><font face="VERDANA" size= 2 color = "000080">Header2Text</font></H2> 
		<H3><font face="VERDANA" size= 2 color = "000080">Header3Text</font></H3>
		<H4><font face="VERDANA" size= 1 color = "000080">Header4Text</font></H4> '
DECLARE @EmailFooter VARCHAR(1000) =N'<br><FONT FACE="VERDANA" SIZE=1 COLOR="BLUE">***************** This is an auto generated mail. Please do not reply *****************</FONT>';
DECLARE @EmailStyle VARCHAR(MAX) = '<style type="text/css">  #box-table  {  font-family:"Palatino Linotype", "Lucida Sans Unicode", "Lucida Grande", Sans-Serif;  font-size: 12px; }  #box-table th  {  font-family:"VERDANA"  font-size: 13px;  font-weight: normal;  background: "#8E44AD";  color: #fff;    text-align: "left"; }  #box-table td  {  color: black;  }  tr:nth-child(odd) { background-color:#CCCCCC; }  tr:nth-child(even) { background-color:#FFFFFF; }   </style>';

-- Get report Name
SET @SQLScript = 'SELECT @ReportName = RTRIM(LTRIM(REPLACE(REPLACE(ReportJobName,''RPT:'',''''),''ETL:'',''''))) FROM adm.ReportJob WHERE ReportID = '+CAST(@ReportId AS VARCHAR(3));
EXEC sp_executesql @SQLScript,N'@ReportName VARCHAR(255) out',@ReportName out;

--Get Customer Report is being run for
SET	@SQLScript = '
SELECT @CustomerName = CASE WHEN C.CustomerName = ''All'' THEN ''ALL Customers'' ELSE C.CustomerName END
FROM adm.ReportJob R
INNER JOIN '+@SourceDatabaseName+'.adm.Customer C
ON CASE WHEN R.CustomerListType = -1 THEN 0 ELSE R.CustomerListType END = C.CustomerId
WHERE R.ReportId = '+CAST(@ReportId AS VARCHAR(2))

EXEC sp_executesql @SQLScript
				,N'@CustomerName VARCHAR(255) OUT'
				,@CustomerName OUT;

-- Get Tracking table Name
SELECT @TrackingTable = TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE='BASE TABLE'
	AND TABLE_NAME LIKE REPLACE(@ReportName,' ','_')+'_Tracking%';

-- Read Tracking table data
SET @SQLScript = '
SELECT @LastRunDate = CONVERT(DATE,RIGHT('''+@TrackingTable+''',8))
      ,@LastRunDuration =   RIGHT(''0'' + CAST(DATEDIFF(SS,MIN(StartTime),MAX(EndTime)) / 3600 AS VARCHAR),2) + '':'' +
							RIGHT(''0'' + CAST((DATEDIFF(SS,MIN(StartTime),MAX(EndTime)) / 60) % 60 AS VARCHAR),2) + '':'' +
							RIGHT(''0'' + CAST(DATEDIFF(SS,MIN(StartTime),MAX(EndTime)) % 60 AS VARCHAR),2)
      ,@Status = IsJobDone
FROM stg.'+@TrackingTable+'
GROUP BY IsJobDone';
EXEC sp_executesql @SQLScript
				,N'@LastRunDate VARCHAR(100) OUT,@LastRunDuration VARCHAR(20) OUT,@Status INT OUT'
				,@LastRunDate OUT,@LastRunDuration OUT,@Status OUT;

SET @EmailSubject = 'STATUS UPDATE:RPT:'+ISNULL(@ReportName,'Invalid Report')+' for '+ ISNULL(@CustomerName,'Invalid Customer');
SET @Header1Text = CASE @Status WHEN 1 THEN 'Job Status: Run Completed Successfully.' WHEN 0 THEN 'Job Status: <font color = "red">Run failed...</font>' ELSE 'Job Status: NA' END;

				
-- Get Summary information from input tables
SET @OutputTableName  = (SELECT TOP 1 TargetSchemaName+'.'+TargetTableName FROM adm.Process WHERE ReportId = @ReportId AND IsReportedOn = 1 ORDER BY ProcessId DESC)
SET @FilterDateColumnName  = (SELECT TOP 1 FilterDateColumnName FROM adm.Process WHERE ReportId = @ReportId AND IsReportedOn = 1 ORDER By ProcessId DESC)

SET	@SQLScript = '
SELECT I.OdsCustomerId
	  ,C.CustomerName
	  ,C.IsActive
      ,COUNT(I.OdsCustomerId) NumberOfRecords
	  ,MAX('+@FilterDateColumnName+') FilterDateCutOff
      ,MAX(RunDate) LastRunDate

FROM '+@SourceDatabaseName+'.adm.Customer C 
LEFT OUTER JOIN '+@OutputTableName+' I
ON I.OdsCustomerId = C.CustomerId
WHERE C.UseforReporting = 1 AND C.CustomerId <> 0
GROUP BY I.OdsCustomerId, C.CustomerName,C.IsActive'

INSERT INTO @SummaryTable EXEC (@SQLScript);

-- Get number of customers expected
SET	@SQLScript = 'SELECT @NoOfCustomersUsedforReporting  = COUNT(1) FROM '+@SourceDatabaseName+'.adm.Customer WHERE UseForReporting = 1 AND CustomerId <> 0'
EXEC sp_executesql @SQLScript
				,N'@NoOfCustomersUsedforReporting INT OUT'
				,@NoOfCustomersUsedforReporting OUT
SELECT @NoOfCustomersInReport = COUNT(1) FROM @SummaryTable WHERE OdsCustomerId IS NOT NULL
	
SET @tableHTML = @EmailStyle + @EmailHeader+
    N'<table>' +
    N'<tr>'+
		N'<th>Customer Name &nbsp</th>' +
		N'<th>Active &nbsp</th>' +
		N'<th>No. of Records Loaded &nbsp</th>' +
		N'<th>'+@FilterDateColumnName+' Cutoff &nbsp</th>' +
		N'<th>Last RunDate &nbsp</th>
    </tr>' +
    CAST ( ( SELECT td = CustomerName,'',
					td = CASE WHEN IsActive = 1 THEN 'Y' ELSE 'N' END,'',
                    td = NumberOfRecords,'',
					td = FORMAT(FilterDateCutOff,'MM/dd/yyyy'),'',
                    td = FORMAT(LastRunDate,'hh.mm tt , dd MMMM yyyy')
              FROM @SummaryTable
              ORDER BY CustomerName
              FOR XML PATH('tr'), TYPE 
    ) AS NVARCHAR(MAX) ) +
    N'</table>'+
@EmailFooter;

SET @tableHTML = REPLACE(@tableHTML,'<table>','<table id="box-table">');
SET @tableHTML = REPLACE(@tableHTML,'<tr>','<tr BGCOLOR="#E8DAEF">');        
SET @tableHTML = REPLACE(@tableHTML,'Header1Text',@Header1Text); 
SET @tableHTML = REPLACE(@tableHTML,'<font FONT FACE="VERDANA" SIZE=4 color="000080">','<font FONT FACE="VERDANA" SIZE=4 color="006400">')
SET @tableHTML = REPLACE(@tableHTML,'Header2Text','Run Duration: '+ISNULL(@LastRunDuration,'NA'));
SET @tableHTML = REPLACE(@tableHTML,'Header3Text','Run Date: '+ISNULL(@LastRunDate,'NA'));	
SET @tableHTML = REPLACE(@tableHTML,'Header4Text','No. Of Customers used for Reporting: <font size  = 2><b><i>'+CAST(@NoOfCustomersUsedforReporting AS VARCHAR(5))+'</i></b></font>. No. of Customers with data: <font size  = 2><b><i>'+CAST(@NoOfCustomersInReport AS VARCHAR(5))+'</i></b></font>');
	
EXEC msdb.dbo.sp_send_dbmail @recipients= @recipients_param,
@subject = @EmailSubject,
@body = @tableHTML,
@body_format = 'HTML' ;

-- Clean up Tracking if job was completed Succesfully
SET @SQLScript = 'DROP TABLE stg.'+@TrackingTable
IF (@Status = 1)
EXEC (@SQLScript);

-- Start Spooling for next Job
SELECT @spooling_job_name = ReportJobName FROM adm.ReportJob WHERE ReportId = 0
EXEC msdb.dbo.sp_start_job @job_name = @spooling_job_name;

END


GO


IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'adm.Mnt_StartReportJob') AND type IN (N'P',N'PC'))
DROP PROCEDURE adm.Mnt_StartReportJob
GO

CREATE PROCEDURE adm.Mnt_StartReportJob(
@SourceDatabaseName VARCHAR(50)='AcsOds')
AS
BEGIN
-- DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds'
DECLARE  @Job_Name VARCHAR(255)
		,@IsDataAvailable INT
		,@SQLQuery NVARCHAR(MAX);

SET @SQLQuery = '
WITH cte_CustomersNotLoadedDaily AS(
SELECT PGA.CustomerId
	,MAX(SnapshotCreateDate) LastLoadedSnapshot
FROM '+@SourceDatabaseName+'.adm.PostingGroupAudit PGA
INNER JOIN '+@SourceDatabaseName+'.adm.Customer C
ON PGA.CustomerId = C.CustomerId
WHERE C.IsLoadedDaily = 0
AND C.UseForReporting = 1
AND PGA.Status = ''FI''
GROUP BY PGA.CustomerId)
-- Count Total Cunstomer and Also Count customers with Most Recent snapshot in current month, numbers should be equal to proceed
SELECT @IsDataAvailable = 1 
FROM cte_CustomersNotLoadedDaily
HAVING COUNT(CustomerId) = COUNT(CASE WHEN MONTH(LastLoadedSnapshot) = MONTH(GETDATE()) AND YEAR(LastLoadedSnapshot) = YEAR(GETDATE()) THEN CustomerId END)'

EXEC sp_executesql  @SQLQuery,N'@IsDataAvailable INT OUT',@IsDataAvailable OUT;

-- This will return a prioritized list of jobs based on the last time they were run.
;WITH cte_ReportJobList AS(
SELECT R.ReportId
	  ,R.ReportJobName
      ,R.Priority
      ,R.IsDaily*DATEDIFF(DAY,ISNULL(A.Job_LastUpdate,0),GETDATE()) IsDaily
      ,R.IsWeekly*DATEDIFF(WEEK,ISNULL(A.Job_LastUpdate,0),GETDATE())*CASE WHEN DATEPART(WEEKDAY,GETDATE()) >= R.RunWeekDay THEN 1 ELSE 0 END IsWeekly
      ,R.IsMonthly*DATEDIFF(MONTH,ISNULL(A.Job_LastUpdate,0),GETDATE()) IsMonthly
      ,R.IsQuarterly*(DATEDIFF(MONTH,(SELECT QuarterStart FROM dbo.GetQrtStartEndDates(ISNULL(A.Job_LastUpdate,0),0)),EOMONTH(GETDATE()))-3) IsQuarterly
FROM adm.ReportJob R
LEFT OUTER JOIN (SELECT ReportID, MAX(Job_LastUpdate) Job_LastUpdate
				 FROM adm.ReportJobAudit
				 WHERE JobStatus = 1
				 GROUP BY ReportID) A
ON R.ReportID = A.ReportID
WHERE R.Enabled = 1)
-- This will be used to make sure the job can be re-tried only 5 times
,cte_ConsecutiveRuns AS(
SELECT ReportID,COUNT(1) AS NumberOfRuns, SUM(JobStatus) ConsecutiveRuns
FROM (SELECT ReportId
	  ,JobStatus
	  ,ROW_NUMBER() OVER(PARTITION BY ReportID ORDER BY Job_StartDate DESC) LastRuns
	  FROM adm.ReportJobAudit) RA
WHERE RA.LastRuns <= 5
GROUP BY ReportID)
-- Get Highest priority Report Job name.
SELECT TOP 1 @Job_Name = ReportJobName
FROM cte_ReportJobList L
LEFT OUTER JOIN cte_ConsecutiveRuns C
ON L.ReportId = C.ReportId
WHERE (IsDaily+IsWeekly+IsMonthly+(IsQuarterly*ISNULL(@IsDataAvailable,0)) > 0)
	AND (ISNULL(C.ConsecutiveRuns,1) > 0 OR NumberOfRuns < 5)
ORDER BY Priority;

IF @Job_Name IS NOT NULL
	EXEC msdb.dbo.sp_start_job @Job_Name = @Job_Name;

END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'adm.Mnt_TrackCustomerReport') AND type in (N'P', N'PC'))
DROP PROCEDURE adm.Mnt_TrackCustomerReport
GO

CREATE PROCEDURE adm.Mnt_TrackCustomerReport(
@ReportId INT,
@ReportTypeId INT = 0,
@ReportStep INT = 0, -- 0 Start, 1 Running, 2 End.
@SourceDatabaseName VARCHAR(50)='AcsOds',
@OdsCustomerId INT = 0,
@CustomerStep INT = 0,
@LastStepStatus INT = 0 -- 0 Start, 1 End.
)
AS
BEGIN
-- DECLARE @ReportId INT = 1,@ReportTypeId INT = 1,@ReportStep INT = 2,@SourceDatabaseName VARCHAR(50)='AcsOds',@OdsCustomerId INT = 0,@CustomerStep INT = 1
DECLARE  @ReportName VARCHAR(255)
		,@SQLScript NVARCHAR(MAX)
		,@TrackingTable VARCHAR(255)
		,@StartTime DATETIME
		,@JobStatus INT = @LastStepStatus;

-- Get report Name
SET @SQLScript = 'SELECT @ReportName = RTRIM(LTRIM(REPLACE(REPLACE(ReportJobName,''RPT:'',''''),''ETL:'',''''))) FROM adm.ReportJob WHERE ReportID = '+CAST(@ReportId AS VARCHAR(3));
EXEC sp_executesql @SQLScript,N'@ReportName VARCHAR(255) out',@ReportName out;

-- Get Tracking table Name
SELECT @TrackingTable = TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE='BASE TABLE'
	AND TABLE_NAME LIKE REPLACE(@ReportName,' ','_')+'_Tracking%';

-- Start Report Audit
IF @ReportStep = 0
INSERT INTO adm.ReportJobAudit(
       ReportID
      ,JobStatus
      ,Job_StartDate
      ,Job_LastUpdate)
VALUES (@ReportId,0,GETDATE(),GETDATE());
	
-- 0.1 Start of Report Job Check if Status table still exists from previous runs.	
IF (@ReportStep = 0 AND @TrackingTable IS NULL)
BEGIN
SET @SQLScript = 
'CREATE TABLE stg.'+REPLACE(@ReportName,' ','_')+'_Tracking_'+CONVERT(VARCHAR(10),GETDATE(),112)+'(
	 ReportId INT NOT NULL
	,ReportTypeId INT NOT NULL
	,OdsCustomerId INT NOT NULL
	,StartTime DATETIME NULL
	,EndTime DATETIME NULL
	,IsCustomerDone INT
	,IsJobDone INT);'
BEGIN TRY 
EXEC(@SQLScript)
END TRY
BEGIN CATCH
PRINT 'Could Not Create table stg.'+REPLACE(@ReportName,' ','_')+'_Tracking_'+CONVERT(VARCHAR(10),GETDATE(),112)+'. Make sure you have the right permissions.'
END CATCH
END

-- 0.2 Start of a new Customer or Incompleted Customer.
ELSE IF (@ReportStep = 1 AND @CustomerStep = 0)
BEGIN
SET @SQLScript = 'SELECT @StartTime = StartTime FROM stg.'+@TrackingTable+
				' WHERE OdsCustomerId =  '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ReportId = '+CAST(@ReportId AS VARCHAR(3))+' AND ReportTypeId = '+CAST(@ReportTypeId AS VARCHAR(3));
EXEC sp_executesql @SQLScript,N'@StartTime DATETIME out',@StartTime out;
	IF (@StartTime IS NULL) -- This is a New Customer that started.
	BEGIN
	SET @SQLScript = 'INSERT INTO stg.'+@TrackingTable+'(ReportId,ReportTypeId,OdsCustomerId,StartTime,IsCustomerDone,IsJobDone)'+CHAR(13)+CHAR(10)+ 
					 'VALUES('+CAST(@ReportId AS VARCHAR(3))+','+CAST(@ReportTypeId AS VARCHAR(3))+','+CAST(@OdsCustomerId AS VARCHAR(3))+','''+CONVERT(VARCHAR(50),GETDATE(),121)+''',0,0);'
	EXEC(@SQLScript)				  
	END
	ELSE -- This is a Customer that did not complete and got restarted.
	BEGIN
	SET @SQLScript = 'UPDATE stg.'+@TrackingTable+' SET StartTime = '''+CONVERT(VARCHAR(50),GETDATE(),121)+ ''' WHERE OdsCustomerId =  '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ReportId = '+CAST(@ReportId AS VARCHAR(3))+' AND ReportTypeId = '+CAST(@ReportTypeId AS VARCHAR(3));
	EXEC(@SQLScript)
	END 
END

-- 0.3 End of Customer Run
ELSE IF (@ReportStep = 1 AND @CustomerStep = 1)
BEGIN
SET @SQLScript = 'UPDATE stg.'+@TrackingTable+' SET EndTime = '''+CONVERT(VARCHAR(50),GETDATE(),121)+''',IsCustomerDone = 1 WHERE OdsCustomerId =  '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ReportId = '+CAST(@ReportId AS VARCHAR(3))+' AND ReportTypeId = '+CAST(@ReportTypeId AS VARCHAR(3));
EXEC(@SQLScript)
END

-- 0.4 End of Report Job Check all customers have run
ELSE IF (@ReportStep = 2)
BEGIN
	IF (@JobStatus = 1)
	BEGIN
		SET @SQLScript = 'UPDATE stg.'+@TrackingTable+' SET IsJobDone = 1';
		EXEC(@SQLScript);
	END

	UPDATE adm.ReportJobAudit
	SET  JobStatus = @JobStatus
		,Job_LastUpdate = GETDATE()
	WHERE ReportJobAuditId = (SELECT MAX(ReportJobAuditId) FROM adm.ReportJobAudit WHERE ReportId = @ReportId);
END
 
END
GO


IF OBJECT_ID('adm.Rpt_CreateUnpartitionedTableIndexes', 'P') IS NOT NULL
    DROP PROCEDURE adm.Rpt_CreateUnpartitionedTableIndexes
GO

CREATE PROCEDURE adm.Rpt_CreateUnpartitionedTableIndexes (
@CustomerId INT,
@ProcessId INT, 
@returnstatus INT OUTPUT)
AS
BEGIN
-- DECLARE @CustomerId INT = 9,@returnstatus INT;

DECLARE  @SQLScript VARCHAR(MAX)
		,@StagingSchemaName CHAR(3) = 'stg'
		,@TargetSchemaName CHAR(3) = (SELECT TargetSchemaName FROM adm.Process WHERE ProcessId = @ProcessId)	
		,@TargetTableName VARCHAR(255) = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId);
		
-- Get Index Key Columns
;WITH Ods_IndexColumns AS(
SELECT IC2.object_id,
      IC2.index_id,
      STUFF(( SELECT ',' + C.name + CASE WHEN MAX(CONVERT(INT, IC1.is_descending_key)) = 1 THEN ' DESC' ELSE ' ASC' END
              FROM   sys.index_columns IC1
              INNER  JOIN sys.columns C
                  ON  C.object_id = IC1.object_id
                  AND C.column_id = IC1.column_id
                  AND IC1.is_included_column = 0
              WHERE  IC1.object_id = IC2.object_id  AND IC1.index_id = IC2.index_id
              GROUP BY IC1.object_id,C.name, index_id
              ORDER BY  MAX(IC1.key_ordinal) 
              FOR XML PATH('')),1,1,'') KeyColumns,
      STUFF(( SELECT ',' + C.name
			  FROM   sys.index_columns IC1
			  INNER  JOIN sys.columns C
				  ON  C.object_id = IC1.object_id
				  AND C.column_id = IC1.column_id
				  AND IC1.is_included_column = 1
			  WHERE  IC1.object_id = IC2.object_id  AND IC1.index_id = IC2.index_id
			  GROUP BY IC1.object_id,C.name,index_id 
			  FOR XML PATH('')),1,1,'') IncludedColumns
FROM   sys.index_columns IC2 
GROUP BY IC2.object_id,IC2.index_id)
-- Build Index script or Primary key constraint.
SELECT @SQLScript =  COALESCE(@SQLScript+CHAR(13)+CHAR(10)+'','')+
	 CASE WHEN I.is_primary_key = 1 
		  THEN 'ALTER TABLE '+@StagingSchemaName + '.' + @TargetTableName+'_Unpartitioned'+' ADD CONSTRAINT '+I.name
		  ELSE 'CREATE ' END+
	 CASE WHEN I.is_primary_key <> 1 AND I.is_unique = 1 THEN ' UNIQUE '   ELSE ''  END +
	 CASE WHEN I.is_primary_key = 1 THEN ' PRIMARY KEY ' ELSE '' END+
	 I.type_desc COLLATE DATABASE_DEFAULT + CASE WHEN I.is_primary_key <> 1 THEN ' INDEX ' ELSE '' END +
	 CASE WHEN I.is_primary_key <> 1 THEN  I.name + ' ON ' ELSE '' END+
	 CASE WHEN I.is_primary_key <> 1 THEN  @StagingSchemaName + '.' + @TargetTableName+'_Unpartitioned'  ELSE '' END+ 
	   ' ('+IC.KeyColumns+')  ' +
	   ISNULL(' INCLUDE(' + IC.IncludedColumns + ') ', '')+
	   'WITH (DATA_COMPRESSION = PAGE);'+CHAR(13)+CHAR(10)

FROM   sys.indexes I
INNER JOIN sys.tables T
ON  T.object_id = I.object_id
INNER JOIN Ods_IndexColumns IC
	ON I.object_id = IC.object_id
	AND I.index_id = IC.index_id

WHERE T.name = @TargetTableName
	AND SCHEMA_NAME(T.schema_id) = @TargetSchemaName
	AND I.type <> 0
ORDER BY I.Index_id

-- Execute Script to build indexes aligned with target table
BEGIN TRY
EXEC(@SQLScript)
SET @returnstatus = 0
END TRY
BEGIN CATCH
PRINT 'Indexes Could Not be built...Make sure table exists and no indexes have been created on it.'
SET @returnstatus = 1
END CATCH

END
GO
IF OBJECT_ID('adm.Rpt_CreateUnpartitionedTableSchema', 'P') IS NOT NULL
    DROP PROCEDURE adm.Rpt_CreateUnpartitionedTableSchema
GO

CREATE PROCEDURE adm.Rpt_CreateUnpartitionedTableSchema (
@CustomerId INT,
@ProcessId INT, 
@SwitchOut INT = 0,
@returnstatus INT OUTPUT)
AS
BEGIN
-- DECLARE @CustomerId INT = 19,@SwitchOut INT = 0,@returnstatus INT;

DECLARE  @SQLScript VARCHAR(MAX) = 'CREATE TABLE '
		,@SrcColumnList VARCHAR(MAX)
		,@StagingSchemaName CHAR(3) = 'stg'
		,@TargetSchemaName CHAR(3) = (SELECT TargetSchemaName FROM adm.Process WHERE ProcessId = @ProcessId)
		,@TargetTableName VARCHAR(255) = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId);

-- Build Column definitions for the table.
SELECT @SrcColumnList =  COALESCE(@srcColumnList+CHAR(13)+CHAR(10)+CHAR(9)+',','')
+ COLUMN_NAME +' '
+ DATA_TYPE 
+ CASE WHEN DATA_TYPE = 'decimal' THEN '('+CAST(NUMERIC_PRECISION AS VARCHAR(5))+','+CAST(NUMERIC_SCALE AS VARCHAR(5))+')' ELSE '' END
+ CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1 THEN ' (MAX)' WHEN  CHARACTER_MAXIMUM_LENGTH IS NOT NULL THEN ' ('+CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(10))+')' ELSE '' END
+ CASE WHEN IS_NULLABLE = 'YES' THEN ' NULL' ELSE ' NOT NULL' END
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = @TargetSchemaName
AND TABLE_NAME = @TargetTableName
ORDER BY ORDINAL_POSITION;

-- Put it together and add check constraint for customer use only.
SET @SQLScript = @SQLScript + @StagingSchemaName +'.'+@TargetTableName+'_Unpartitioned'+' ('+CHAR(13)+CHAR(10)+CHAR(9)
+@SrcColumnList+')WITH (DATA_COMPRESSION = PAGE);'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+

-- Only Add check constraint if table will be used for switching into main table.
CASE WHEN @SwitchOut = 0 THEN
'ALTER TABLE '+ @StagingSchemaName +'.'+@TargetTableName+'_Unpartitioned'+CHAR(13)+CHAR(10)+
'ADD CONSTRAINT CK_'+@TargetTableName+'_CustomerPartitionCheck CHECK (OdsCustomerId = '+CAST(@CustomerId AS VARCHAR(5))+');'
ELSE '' END;

BEGIN TRY
EXEC(@SQLScript)
SET @returnstatus = 0
END TRY
BEGIN CATCH
PRINT 'Could not create table...Make sure table doesn''t exists.'
SET @returnstatus = 1
END CATCH

END
GO
IF OBJECT_ID('adm.Rpt_RecreateTableIndexes', 'P') IS NOT NULL
    DROP PROCEDURE adm.Rpt_RecreateTableIndexes
GO

CREATE PROCEDURE adm.Rpt_RecreateTableIndexes (
@ProcessId INT)
AS
BEGIN

DECLARE @IndexScript NVARCHAR(MAX)

SELECT @IndexScript = IndexScript FROM adm.Process WHERE ProcessId = @ProcessId
IF @IndexScript IS NOT NULL OR @IndexScript <> ''
BEGIN
	EXEC(@IndexScript);

	UPDATE adm.Process
	SET IndexScript = NULL
	WHERE  ProcessId = @ProcessId
END
END 

GO


IF OBJECT_ID('adm.Rpt_ScriptAndSaveTableIndexes', 'P') IS NOT NULL
    DROP PROCEDURE adm.Rpt_ScriptAndSaveTableIndexes
GO

CREATE PROCEDURE adm.Rpt_ScriptAndSaveTableIndexes (
@ProcessId INT)
AS
BEGIN
-- DECLARE @ReportId INT=1,@ReportType INT=1

DECLARE  @SQLScript VARCHAR(MAX)
		,@DropIdxScript VARCHAR(MAX)
		,@TargetSchemaName CHAR(3) = (SELECT TargetSchemaName FROM adm.Process WHERE ProcessId = @ProcessId)	
		,@TargetTableName VARCHAR(255) = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId);
		
-- Get Index Key Columns
;WITH Ods_IndexColumns AS(
SELECT IC2.object_id,
      IC2.index_id,
      STUFF(( SELECT ',' + C.name + CASE WHEN MAX(CONVERT(INT, IC1.is_descending_key)) = 1 THEN ' DESC' ELSE ' ASC' END
              FROM   sys.index_columns IC1
              INNER  JOIN sys.columns C
                  ON  C.object_id = IC1.object_id
                  AND C.column_id = IC1.column_id
                  AND IC1.is_included_column = 0
              WHERE  IC1.object_id = IC2.object_id  AND IC1.index_id = IC2.index_id
              GROUP BY IC1.object_id,C.name, index_id
              ORDER BY  MAX(IC1.key_ordinal) 
              FOR XML PATH('')),1,1,'') KeyColumns,
      STUFF(( SELECT ',' + C.name
			  FROM   sys.index_columns IC1
			  INNER  JOIN sys.columns C
				  ON  C.object_id = IC1.object_id
				  AND C.column_id = IC1.column_id
				  AND IC1.is_included_column = 1
			  WHERE  IC1.object_id = IC2.object_id  AND IC1.index_id = IC2.index_id
			  GROUP BY IC1.object_id,C.name,index_id 
			  FOR XML PATH('')),1,1,'') IncludedColumns
FROM   sys.index_columns IC2 
GROUP BY IC2.object_id,IC2.index_id)
-- Build Index script or Primary key constraint.
SELECT @SQLScript =  COALESCE(@SQLScript+CHAR(13)+CHAR(10)+'','')+
	 CASE WHEN I.is_primary_key = 1 
		  THEN 'ALTER TABLE '+@TargetSchemaName + '.' + @TargetTableName+' ADD CONSTRAINT '+I.name
		  ELSE 'CREATE ' END+
	 CASE WHEN I.is_primary_key <> 1 AND I.is_unique = 1 THEN ' UNIQUE '   ELSE ''  END +
	 CASE WHEN I.is_primary_key = 1 THEN ' PRIMARY KEY ' ELSE '' END+
	 I.type_desc COLLATE DATABASE_DEFAULT + CASE WHEN I.is_primary_key <> 1 THEN ' INDEX ' ELSE '' END +
	 CASE WHEN I.is_primary_key <> 1 THEN  I.name + ' ON ' ELSE '' END+
	 CASE WHEN I.is_primary_key <> 1 THEN  @TargetSchemaName + '.' + @TargetTableName  ELSE '' END+ 
	   ' ('+IC.KeyColumns+')  ' +
	   ISNULL(' INCLUDE(' + IC.IncludedColumns + ') ', '')+
	   'WITH (DATA_COMPRESSION = PAGE);'+CHAR(13)+CHAR(10)
	,@DropIdxScript = COALESCE(@DropIdxScript+CHAR(13)+CHAR(10)+'','')+ 
		'DROP INDEX '+ I.name+' ON '+ @TargetSchemaName + '.' + @TargetTableName+';'+CHAR(13)+CHAR(10)

FROM   sys.indexes I
INNER JOIN sys.tables T
ON  T.object_id = I.object_id
INNER JOIN Ods_IndexColumns IC
	ON I.object_id = IC.object_id
	AND I.index_id = IC.index_id

WHERE T.name = @TargetTableName
	AND SCHEMA_NAME(T.schema_id) = @TargetSchemaName
	AND I.type <> 0
ORDER BY I.Index_id

-- Execute Script to build indexes aligned with target table
BEGIN TRY
UPDATE adm.Process
SET IndexScript = CASE WHEN @SQLScript <> '' AND @SQLScript IS NOT NULL THEN @SQLScript ELSE IndexScript END
WHERE ProcessId = @ProcessId;

EXEC(@DropIdxScript);

END TRY
BEGIN CATCH
PRINT 'Indexes Could Not be Scripted Or Dropped...Make sure table exists and indexes have been created on it.'
END CATCH

END
GO
IF OBJECT_ID('adm.Rpt_SwitchUnpartitionedTable', 'P') IS NOT NULL
    DROP PROCEDURE adm.Rpt_SwitchUnpartitionedTable
GO

CREATE PROCEDURE adm.Rpt_SwitchUnpartitionedTable (
@CustomerId INT,
@ProcessId INT, 
@TargetNameExtension VARCHAR(100) = '',
@SwitchOut INT = 0,
@returnstatus INT OUTPUT)
AS
BEGIN

-- DECLARE @ProcessId INT = 19,@CustomerId INT = 69,@TargetNameExtension VARCHAR(100) = '_',@returnstatus INT,@SwitchOut INT = 0;

DECLARE  @SQLScript VARCHAR(MAX) = ''
		,@StagingSchemaName CHAR(3) = 'stg'
		,@TargetSchemaName CHAR(3) = (SELECT TargetSchemaName FROM adm.Process WHERE ProcessId = @ProcessId)	
		,@TargetTableName VARCHAR(255) = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId);
-- Check switch direction and switch accordingly
IF @SwitchOut = 0
	BEGIN
	-- Make sure check constraint exists before you switch in.
	SET @SQLScript = @SQLScript +
	'IF NOT EXISTS (SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS'+CHAR(13)+CHAR(10)+
	'WHERE CONSTRAINT_NAME = ''CK_'+@TargetTableName+'_CustomerPartitionCheck'''+CHAR(13)+CHAR(10)+
	'AND CONSTRAINT_SCHEMA = '''+@StagingSchemaName+''')'+CHAR(13)+CHAR(10)+
	'ALTER TABLE '+ @StagingSchemaName +'.'+@TargetTableName+'_Unpartitioned'+CHAR(13)+CHAR(10)+
	'ADD CONSTRAINT CK_'+@TargetTableName+'_CustomerPartitionCheck CHECK (OdsCustomerId = '+CAST(@CustomerId AS VARCHAR(5))+');'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
					  
	SET @SQLScript = @SQLScript+
	'ALTER TABLE '+@StagingSchemaName+'.'+@TargetTableName+'_Unpartitioned'+ 
	' SWITCH TO '+@TargetSchemaName+'.'+@TargetTableName+@TargetNameExtension+' PARTITION '+CAST(@CustomerId AS VARCHAR(5))+';'+CHAR(13)+CHAR(10)+
	'DROP TABLE '+@StagingSchemaName+'.'+@TargetTableName+'_Unpartitioned'+'';
	END
ELSE 
	SET @SQLScript = 'ALTER TABLE '+@TargetSchemaName+'.'+@TargetTableName+@TargetNameExtension+ 
	' SWITCH PARTITION '+CAST(@CustomerId AS VARCHAR(5))+' TO '+@StagingSchemaName+'.'+@TargetTableName+'_Unpartitioned'+';'+CHAR(13)+CHAR(10)
	
-- If Indexes were successfully built, switch Partitions

BEGIN TRY
EXEC(@SQLScript)
SET @returnstatus = 0
END TRY
BEGIN CATCH
PRINT 'Could Not Switch Partitions...'
SET @returnstatus = 1
END CATCH

END

GO
