:setvar JOBNAME "$(ESCAPE_SQUOTE(JOBNAME))"
:setvar JOBID "$(ESCAPE_SQUOTE(JOBID))"

DECLARE @DatabaseName VARCHAR(100) = DB_NAME();

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Failover' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Failover'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ETL: PrePPOBillInfo Endnotes', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'Failover', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'PrePPOBillInfo_Endnotes Initialize Tables', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE  @ReportId INT
		,@SourceDatabaseName VARCHAR(50)

SELECT   @ReportId = ReportID
		,@SourceDatabaseName = SourceDatabaseName
FROM adm.ReportJob
WHERE ReportJobName = ''$(ESCAPE_SQUOTE(JOBNAME))''

-- Initialize Tracking
EXEC adm.Mnt_TrackCustomerReport @ReportId,NULL,0,@SourceDatabaseName,NULL,NULL;', 
		@database_name=@DatabaseName, 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'PrePPOBillInfo_Endnotes Output', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @ReportId INT
	,@ReportType INT = 1
	,@ReportName VARCHAR(255)
	,@SQLScript NVARCHAR(MAX)
	,@TrackingTable VARCHAR(255)
	,@SourceDatabaseName VARCHAR(50)
	,@RunDate DATETIME
	,@IsMonthly INT
	,@StartDate DATETIME
	,@EndDate DATETIME
	,@RunType INT
	,@if_Date DATETIME
	,@CustomerListType INT -- Set to 0 When Want to Run for ALL Customers in single loop, -1 for Active Customers, Or specify active customerid
	,@OdsCustomerId INT; DECLARE  @CustomerList TABLE (CustomerId INT);
	
SELECT   @ReportId = ReportID
		,@RunType = RunType
		,@IsMonthly = IsMonthly
		,@if_Date = SnapshotDate
		,@SourceDatabaseName = SourceDatabaseName
		,@CustomerListType = CustomerListType
FROM adm.ReportJob
WHERE ReportJobName = ''$(ESCAPE_SQUOTE(JOBNAME))'';

SET @RunDate =(SELECT  ISNULL(ParameterValue,GETDATE()) FROM adm.ReportParameters WHERE ReportId = @ReportId AND ParameterName = ''RunDate'')
SET @EndDate = EOMONTH(DATEADD(MONTH,-1,@RunDate))
SET @StartDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, @RunDate) -@IsMonthly, 0)

-- Get Customer List
INSERT INTO @CustomerList EXEC adm.Mnt_GetCustomerList @ReportId,@ReportType,@SourceDatabaseName,@CustomerListType;
	
DECLARE db_customer_cursor CURSOR FOR 
SELECT CustomerId FROM @CustomerList

OPEN db_customer_cursor   
FETCH NEXT FROM db_customer_cursor INTO @OdsCustomerId

WHILE @@FETCH_STATUS = 0   
BEGIN 
-- Track Start Of Customer
EXEC adm.Mnt_TrackCustomerReport @ReportId,@ReportType,1,@SourceDatabaseName,@OdsCustomerId,0;

EXEC dbo.PrePPOBillInfo_Endnotes @SourceDatabaseName,@if_Date,@RunType,@OdsCustomerId,@ReportType

-- Track End Of Customer
EXEC adm.Mnt_TrackCustomerReport @ReportId,@ReportType,1,@SourceDatabaseName,@OdsCustomerId,1;

FETCH NEXT FROM db_customer_cursor INTO @OdsCustomerId

END

CLOSE db_customer_cursor 
DEALLOCATE db_customer_cursor', 
		@database_name=@DatabaseName, 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'PrePPOBillInfo_Endnotes Report_CloseTrackingSendNotification', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE  @LastStepStatus INT
		,@ReportId INT
		,@SourceDatabaseName VARCHAR(50)
		,@Email_Param VARCHAR(255);

SELECT   @ReportId = ReportID
		,@Email_Param = EmailTo
		,@SourceDatabaseName = SourceDatabaseName
FROM adm.ReportJob
WHERE ReportJobName = ''$(ESCAPE_SQUOTE(JOBNAME))''	

-- Get Status Of Last step for current Run
SELECT TOP 1 @LastStepStatus = H.run_status
FROM msdb.dbo.sysjobactivity A
INNER JOIN msdb.dbo.sysjobhistory H
	ON A.job_id = H.job_id
	AND A.last_executed_step_id = H.step_id
WHERE A.job_id = $(ESCAPE_SQUOTE(JOBID))
AND A.stop_execution_date IS NULL -- Job is still running
AND CAST(run_date AS VARCHAR(8)) >= CONVERT(VARCHAR(10),run_requested_date,112)
ORDER BY H.instance_id DESC

-- Close Job Tracking
EXEC adm.Mnt_TrackCustomerReport @ReportId,NULL,2,@SourceDatabaseName,NULL,NULL,@LastStepStatus;

EXEC adm.Mnt_SendReportNotification @ReportId,@SourceDatabaseName,@Email_Param;', 
		@database_name=@DatabaseName, 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_update_jobstep @job_id=@jobId,
		@step_id=1, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=3
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_jobstep @job_id=@jobId,
		@step_id=2, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=3
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback


EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


