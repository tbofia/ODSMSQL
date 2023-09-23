IF OBJECT_ID('rpt.QueuePostingGroup') IS NOT NULL
    DROP PROCEDURE rpt.QueuePostingGroup
GO

CREATE PROCEDURE rpt.QueuePostingGroup
    (
      @PostingGroupId INT ,
      @CurrentCTVersion BIGINT ,
      @DBSnapshotName VARCHAR(100) ,
      @DBSnapshotServer VARCHAR(100) ,
      @DPAppVersion VARCHAR(10) ,
      @SnapshotCreateDate DATETIME2 ,
      @CurrentDPAppVersionId INT ,
      @CurrentMmedStaticDataVersionId INT ,
      @DataExtractTypeId TINYINT = 0 ,
      @DMAppVersion VARCHAR(10) = NULL ,
      @CurrentDMAppVersionId INT = NULL,
	  @NumberOfProcessesNeedReconciliation INT = 0
    )
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PostingGroupAuditId INT,
		@AcsOdsVersion VARCHAR(10),
		@IsFullExtract BIT,
		@FullLoadVersion VARCHAR(20),
		@IsFullExtractDifferential BIT,
		@LatestODSVersion VARCHAR(20),
		@ChangeTrackingRetentionPeriod INT,
		@DaysSinceLastLoad INT = 0,
		@LastLoadedVersion VARCHAR(20) = '0.0.0.0';

-- Get Change Tracking Retention period
    SELECT  @ChangeTrackingRetentionPeriod = ct.retention_period 
	FROM    sys.change_tracking_databases ct
	WHERE   ct.database_id = DB_ID() AND ct.retention_period_units_desc = 'DAYS' 

-- Get Days since last successful load
   SELECT TOP 1 @DaysSinceLastLoad = DATEDIFF(DAY,SnapshotCreateDate,GETDATE()), @LastLoadedVersion = AcsOdsVersion FROM rpt.PostingGroupAudit WHERE Status = 'FI' ORDER BY PostingGroupAuditId Desc

   IF @DaysSinceLastLoad >= @ChangeTrackingRetentionPeriod
   BEGIN 
		SET @NumberOfProcessesNeedReconciliation = 0
		SET @DataExtractTypeId = 2
   END	
	
-- Reset DataExtractTtype to snapshot load if We need to do snapshot (i.e.  There are Processes that need recon)
	IF @NumberOfProcessesNeedReconciliation <> 0
		SET @DataExtractTypeId = 2

-- Let's also store the version of the ODS. We'll pass this information along in the control files.
	SELECT TOP 1
		@AcsOdsVersion = AppVersion
	FROM    rpt.AppVersion
	ORDER BY AppVersionId DESC;

-- If the last version loaded is less than lastest ODS version and we are trying to run and we are trying to do and incremental load let's overrride

	IF CAST('/' + REPLACE(@LastLoadedVersion,'.','.1') + '/' AS HIERARCHYID) < CAST('/' + REPLACE(@AcsOdsVersion,'.','.1') + '/' AS HIERARCHYID) AND (@DataExtractTypeId = 0 OR @NumberOfProcessesNeedReconciliation <> 0 OR @DaysSinceLastLoad >= @ChangeTrackingRetentionPeriod)
		SET @DataExtractTypeId = 1

-- When AppVersion is NULL or empty string , let's set this to '0.0'  (when no
-- value exists for AppVersion, SSIS is passing an empty string).  We're doing this
-- because we have rpt.ProcessStep records associated with version 0.0 of DemandManager
-- that will produce empty files if DemandManager doesn't exist.

    IF @DPAppVersion = '' OR @DPAppVersion IS NULL
        SET @DPAppVersion = '0.0';

    IF @DMAppVersion = '' OR @DMAppVersion IS NULL
        SET @DMAppVersion = '0.0';

-- Get Top 2 level version numbers
	SELECT @LatestODSVersion = rpt.GetSubstringUpToNthOccurence(@AcsOdsVersion,'.',2)

    BEGIN TRY

        BEGIN TRANSACTION

		SELECT @IsFullExtract = IsFullExtract,
			   @FullLoadVersion = FullLoadVersion,
			   @IsFullExtractDifferential = ISNULL(IsFullLoadDifferential, 0)
		FROM rpt.DataExtractType 
		WHERE DataExtractTypeId = @DataExtractTypeId;

		-- Let's make sure we have a valid DataExtractTypeId
		IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR ('DataExtractTypeId is invalid!', 16, 1);
			SELECT  0 AS PostingGroupAuditId;
			ROLLBACK TRANSACTION
            RETURN;
        END
-- If this is full load and there are no processes with the latest version then dont log any posting groups 
		IF @DataExtractTypeId = 1 AND @FullLoadVersion = '0.0' AND NOT EXISTS (SELECT TOP 1 ProcessId FROM rpt.Process WHERE MinODSVersion = @LatestODSVersion)
		BEGIN
			SELECT  0 AS PostingGroupAuditId;
			ROLLBACK TRANSACTION
			RETURN;
		END

        INSERT  INTO rpt.PostingGroupAudit
                ( PostingGroupId ,
                  DataExtractTypeId ,
                  Status ,
                  CurrentCTVersion ,
                  CurrentDPAppVersionId ,
                  CurrentMmedStaticDataVersionId ,
                  DBSnapshotName ,
                  DBSnapshotServer ,
                  DPAppVersion ,
                  SnapshotCreateDate ,
                  CreateDate ,
                  LastChangeDate ,
				  AcsOdsVersion ,
				  DMAppVersion ,
				  CurrentDMAppVersionId
			    )
                SELECT  @PostingGroupId ,
                        @DataExtractTypeId ,
                        '01' ,
                        @CurrentCTVersion ,
                        @CurrentDPAppVersionId ,
                        @CurrentMmedStaticDataVersionId ,
                        @DBSnapshotName ,
                        @DBSnapshotServer ,
                        @DPAppVersion ,
                        @SnapshotCreateDate ,
                        GETDATE() ,
                        GETDATE() ,
						@AcsOdsVersion,
						@DMAppVersion ,
						@CurrentDMAppVersionId;

        SET @PostingGroupAuditId = SCOPE_IDENTITY();

        INSERT  INTO rpt.ProcessAudit
                ( PostingGroupAuditId ,
                  ProcessId ,
                  STATUS ,
                  QueueDate ,
                  CreateDate ,
                  LastChangeDate
			    )
                SELECT  @PostingGroupAuditId ,
                        p.ProcessId ,
                        '01' ,
                        GETDATE() ,
                        GETDATE() ,
                        GETDATE()
                FROM    rpt.PostingGroup g
                INNER JOIN rpt.PostingGroupProcess p ON g.PostingGroupid = p.PostingGroupId
				INNER JOIN rpt.Process p2 ON p.ProcessId = p2.ProcessId AND p2.IsActive = 1
				LEFT OUTER JOIN rpt.CustomerReconciliation pr ON p.ProcessId = pr.ProcessId
                WHERE   g.PostingGroupId = @PostingGroupId
						AND (
							(@DataExtractTypeId = 1 AND ((@FullLoadVersion = '0.0' AND p2.MinODSVersion = @LatestODSVersion) 
														OR (@FullLoadVersion <> '0.0' AND @IsFullExtractDifferential = 1 AND CAST('/' + REPLACE(p2.MinODSVersion,'.','.1') + '/' AS HIERARCHYID) >= CAST('/' + REPLACE(@FullLoadVersion,'.','.1') + '/' AS HIERARCHYID))
														OR (@FullLoadVersion <> '0.0' AND @IsFullExtractDifferential = 0 AND p2.MinODSVersion = @FullLoadVersion)))
							OR
							(@DataExtractTypeId = 2 AND @NumberOfProcessesNeedReconciliation > 0 AND pr.ProcessId IS NOT NULL)
							OR
							(@DataExtractTypeId = 2 AND @NumberOfProcessesNeedReconciliation = 0)
							OR 
							@DataExtractTypeId = 0
						)
                ORDER BY p.Priority ,
                        p.ProcessId;                
				    	
        INSERT  INTO rpt.ProcessStepAudit
                ( ProcessAuditId ,
                  ProcessStepId ,
                  PreviousCheckpoint ,
                  CurrentCheckpoint ,
                  CreateDate ,
                  LastChangeDate
			    )
                SELECT  pa.ProcessAuditId ,
                        ec.ProcessStepId ,
                        ISNULL(cp.PreviousCheckpoint, 0) ,
						/** Current Checkpoint Logic **/
						-- If someone kicks off a full extract, and it isn't the initial extract, let's keep the old checkpoint.
						-- This way, the next incremental extract will include all changes since the last incremental.
                        CASE WHEN @IsFullExtract = 1
                                  AND ISNULL(cp.PreviousCheckpoint, 0) > 0 THEN ISNULL(cp.PreviousCheckpoint, 0)
						-- If the minimum application version is '0.0', then we want to keep the old checkpoint (which should be 0).
						-- These records will just dump out empty files, so we don't want to move forward until the customer upgrades
						-- to a supported version of the application (this doesn't apply to DP, which would just bomb out).
							 WHEN ec.MinAppVersion = '0.0' THEN ISNULL(cp.PreviousCheckpoint, 0)
						-- We've got several checkpoint types:
						-- 1) rpt.Process.IsSnapshot = 0: Change Tracking
						-- 2) rpt.Process.IsSnapshot = 1 AND rpt.Process.IsHimStatic = 0 AND rpt.Process.ProductKey = 'DemandManager' : DMAppVersionId
						-- 3) rpt.Process.IsSnapshot = 1 AND rpt.Process.IsHimStatic = 0 AND rpt.Process.ProductKey = 'DecisionPoint' : DPAppVersionId
						-- 4) rpt.Process.IsSnapshot = 1 AND rpt.Process.IsHimStatic = 1: MmedStaticDataVersionId
                             WHEN p.IsSnapshot = 0 THEN @CurrentCTVersion
                             WHEN p.IsSnapshot = 1
                                  AND p.IsHimStatic = 0 
								  AND p.ProductKey = 'DemandManager' THEN @CurrentDMAppVersionId
                             WHEN p.IsSnapshot = 1
                                  AND p.IsHimStatic = 0 
								  AND p.ProductKey = 'DecisionPoint'  THEN @CurrentDPAppVersionId
                             WHEN p.IsSnapshot = 1
                                  AND p.IsHimStatic = 1 THEN @CurrentMmedStaticDataVersionId
                             ELSE NULL
                        END ,
                        GETDATE() ,
                        GETDATE()
                FROM    rpt.ProcessAudit pa
                        INNER JOIN rpt.Process p ON pa.ProcessId = p.ProcessId
						-- Let's use the HIERARCHYID data type to compare application versions.
                        INNER JOIN ( SELECT ec1.ProcessId ,
                                            MAX(CAST('/' + ec1.MinAppVersion + '/' AS HIERARCHYID)) AS MinAppVersion
                                     FROM   rpt.ProcessStep ec1
									 INNER JOIN rpt.Process p1 ON ec1.ProcessId = p1.ProcessId
									 -- We want to get the greatest (relative to supported AppVersion) from ProcessStep records
									 -- that's less than or equal to our current product version.
									 WHERE CAST('/' + ec1.MinAppVersion + '/' AS HIERARCHYID) <= CAST('/' + CASE WHEN p1.ProductKey = 'DemandManager' THEN @DMAppVersion -- DemandManager AppVersion
																												WHEN p1.ProductKey = 'DecisionPoint' THEN @DPAppVersion -- DecisionPoint AppVersion
																											END + '/' AS HIERARCHYID)
                                     GROUP BY ec1.ProcessId ) a ON p.ProcessId = a.ProcessId
                        INNER JOIN rpt.ProcessStep ec ON a.ProcessId = ec.ProcessId
                                                         AND a.MinAppVersion = CAST('/' + ec.MinAppVersion + '/' AS HIERARCHYID)
                        LEFT OUTER JOIN rpt.ProcessCheckpoint cp ON p.ProcessId = cp.ProcessId
                WHERE   pa.PostingGroupAuditId = @PostingGroupAuditId
                ORDER BY ec.Priority ,
                        pa.ProcessAuditId;       

-- Let's make sure we've retrieved some ETL steps.
        IF @@ROWCOUNT = 0
            RAISERROR ('Insert into rpt.ProcessStep failed.  Are you sure the AppVersion is correct?', 16, 1) WITH LOG

        SELECT  @PostingGroupAuditId AS PostingGroupAuditId;

        COMMIT TRANSACTION

    END TRY

    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION

        DECLARE @ErrMsg NVARCHAR(4000) ,
            @ErrSeverity INT

        SELECT  @ErrMsg = ERROR_MESSAGE() ,
                @ErrSeverity = ERROR_SEVERITY()

        RAISERROR (@ErrMsg, @ErrSeverity, 1) WITH LOG

        RETURN
    END CATCH

END
GO
