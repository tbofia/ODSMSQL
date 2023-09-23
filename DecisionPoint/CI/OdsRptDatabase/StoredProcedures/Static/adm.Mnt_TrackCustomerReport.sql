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


