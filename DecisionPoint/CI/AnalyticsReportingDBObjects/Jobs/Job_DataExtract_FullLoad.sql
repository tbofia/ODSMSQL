DECLARE  @ServerName VARCHAR(255) = '"\"$(servername_)\""'
		,@DatabaseName VARCHAR(255) = '"\"'+DB_NAME()+'\""'
		,@DataExtractTypeId INT = 1
		,@OutputPath VARCHAR(MAX) = '"\"\\Prod44NAS\OdsFileExtracts\""'
		,@SSISPackagePath VARCHAR(MAX) = '"\"\MSDB\Data File Extracts\""'
		,@Command VARCHAR(MAX);

DECLARE @JobName VARCHAR(MAX);
SET @JobName = N'DW Data Extracts - '+DB_NAME()+' - Full Load'
SET @Command = N'/DTS '+@SSISPackagePath+
				'/SERVER $(servername_) /CHECKPOINTING OFF'+
				'/SET "\"\Package.Variables[User::SourceDatabase].Value\"";'+@DatabaseName+
				'/SET "\"\Package.Variables[User::SourceServer].Value\"";'+@ServerName+
				'/SET "\"\Package.Variables[User::DataExtractTypeId].Value\"";'+CAST(@DataExtractTypeId AS VARCHAR(3))+
				'/SET "\"\Package.Variables[User::OutputPath].Value\"";'+@OutputPath+' /REPORTING E'


IF NOT EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = @JobName)
BEGIN
	BEGIN TRANSACTION
	DECLARE @ReturnCode INT
	SELECT @ReturnCode = 0

	IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Failover' AND category_class=1)
	BEGIN
	EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Failover'
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

	END

	DECLARE @jobId BINARY(16)
	EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=@JobName, 
			@enabled=1, 
			@notify_level_eventlog=0, 
			@notify_level_email=0, 
			@notify_level_netsend=0, 
			@notify_level_page=0, 
			@delete_level=0, 
			@description=N'This Job Dumps Full Data from Tables in rpt.Process into flat files', 
			@category_name=N'Failover', 
			@owner_login_name=N'sa', @job_id = @jobId OUTPUT
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Data File Extracts', 
			@step_id=1, 
			@cmdexec_success_code=0, 
			@on_success_action=1, 
			@on_success_step_id=0, 
			@on_fail_action=2, 
			@on_fail_step_id=0, 
			@retry_attempts=0, 
			@retry_interval=0, 
			@os_run_priority=0, @subsystem=N'SSIS', 
			@command=@Command,
			@database_name=N'master', 
			@flags=0
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	COMMIT TRANSACTION
	GOTO EndSave
	QuitWithRollback:
		IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
	EndSave:

END

GO


