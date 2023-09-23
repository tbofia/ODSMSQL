:setvar JOBNAME "$(ESCAPE_SQUOTE(JOBNAME))"
:setvar JOBID "$(ESCAPE_SQUOTE(JOBID))"

IF EXISTS(SELECT * FROM msdb..sysjobs WHERE name = N'ETL: Ods Dataload')
EXEC msdb.dbo.sp_delete_job @job_name=N'ETL: Ods Dataload', @delete_unused_schedule=1

DECLARE @DatabaseName VARCHAR(100) = DB_NAME();
DECLARE  @ServerName VARCHAR(255) = '"\"$(servername_)\""'
		,@SSISPackagePath VARCHAR(MAX) = '"\"\SSISDB\DP_ODSLoad\DP ODS Loading Project\DP_ODSLoad_Master.dtsx\""'
		,@Command VARCHAR(MAX);

SET @Command = N'/ISSERVER '+@SSISPackagePath+' /SERVER '+@ServerName+
				'/Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 '+
				'/Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E'

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Failover' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Failover'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ETL: Ods Dataload', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'', 
		@category_name=N'Failover', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Insert Record Start of Job', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=5, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @JobName VARCHAR(MAX);
SET @JobName =  ''$(ESCAPE_SQUOTE(JOBNAME))''

INSERT INTO adm.LoadStatus VALUES(@JobName,''S'',NULL,GETDATE(),NULL)', 
		@database_name=@DatabaseName, 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Balance On Processes', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=5, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N' EXEC adm.Etl_ProcessLoadGroupBalancing', 
		@database_name=@DatabaseName, 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Entry Point: Master Package', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=5, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=@Command,
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Send Notification', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=5, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DEClARE  @Rundate VARCHAR(10) = CONVERT(VARCHAR(10),GETDATE(),101) 
		,@ReportURL VARCHAR(MAX) = ''''
		,@Email_Param VARCHAR(255) = ''CSGProviderAnalytics@mitchell.com;CorpITBITeam@mitchell.com''

IF DATEPART(HH,GETDATE()) >= 8		
EXEC adm.Mnt_SendNotification @Rundate,@ReportURL,@Email_Param;', 
		@database_name=@DatabaseName, 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update Job Run Status]    Script Date: 3/22/2019 11:22:53 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update Job Run Status', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE  @LastStepStatus INT
		,@LastRunId INT
		,@StartDate DATETIME
		,@NoOfCustomers INT;

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

SELECT TOP 1 @LastRunId = JobRunId,@StartDate = StartDate FROM adm.LoadStatus ORDER BY JobRunId DESC;

SELECT @NoOfCustomers = COUNT(DISTINCT CustomerId) FROM adm.PostingGroupAudit WHERE CreateDate >= @StartDate

UPDATE adm.LoadStatus
	SET  Status = CASE WHEN @LastStepStatus IS NULL THEN ''Err'' ELSE ''FI'' END
		,NoOfCustomers = @NoOfCustomers
		,EndDate = GETDATE()
WHERE JobRunId = @LastRunId', 
		@database_name=@DatabaseName, 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Kick Off Snowflake Replication Incremental Load]    Script Date: 10/12/2020 4:27:51 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Kick Off Snowflake Replication Incremental Load', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF CAST(GETDATE() AS TIME) >= ''08:00:00''
BEGIN
	DECLARE @NumTries INT = 0
	WHILE @NumTries < 5
	BEGIN 
		IF EXISTS(SELECT 1	
					FROM sys.dm_hadr_database_replica_states AS drs
					INNER JOIN sys.availability_databases_cluster AS adc 
						ON drs.group_id = adc.group_id AND 
						drs.group_database_id = adc.group_database_id
					WHERE adc.database_name = ''AcsOds''
					AND drs.synchronization_state_desc = ''SYNCHRONIZED'')
			BEGIN
				EXEC dbo.sp_start_job N''SnowFlake Replication: Incremental Load''
				BREAK;
			END
		ELSE 
			BEGIN
			SET @NumTries = @NumTries + 1
			WAITFOR DELAY ''00:01:00''
			END
	END
END
GO', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Ods Daily Load', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20181112, 
		@active_end_date=99991231, 
		@active_start_time=30000, 
		@active_end_time=85959, 
		@schedule_uid=N'9202c8db-715b-4e44-a095-e41e5b6197f4'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


