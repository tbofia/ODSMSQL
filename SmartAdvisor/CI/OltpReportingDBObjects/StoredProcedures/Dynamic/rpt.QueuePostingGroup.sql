IF OBJECT_ID('rpt.QueuePostingGroup') IS NOT NULL
    DROP PROCEDURE rpt.QueuePostingGroup
GO

CREATE PROCEDURE rpt.QueuePostingGroup
    (
      @PostingGroupId INT ,
      @ChildDBSnapshotName VARCHAR(100) ,
	  @ChildDBCTVersion BIGINT ,
	  @ChildDBSiteInfoHistory INT,
	  @CoreDBSnapshotName VARCHAR(100) ,
	  @CoreDBCTVersion BIGINT ,
	  @CoreDBSiteInfoHistory INT,
      @DBSnapshotServer VARCHAR(100) ,
      @SADBVersion VARCHAR(20) ,
	  @SAFSVersion VARCHAR(20) ,
      @SnapshotCreateDate DATETIME2 ,
      @DataExtractTypeId TINYINT = 0 
    )
AS
BEGIN
	-- DECLARE @PostingGroupId INT = 1,@ChildDBCTVersion BIGINT = 0,@ChildDBSiteInfoHistory INT = 0,@ChildDBSnapshotName VARCHAR(100) ='', @CoreDBCTVersion BIGINT =0,@CoreDBSiteInfoHistory INT = 0,@CoreDBSnapshotName VARCHAR(100) ='', @DBSnapshotServer VARCHAR(100) ='', @SADBVersion VARCHAR(20) ='8.08.0083.8300', @SAFSVersion VARCHAR(20)='8.08.0083.8300' ,  @SnapshotCreateDate DATETIME2 =GETDATE(),  @DataExtractTypeId TINYINT = 0 
    SET NOCOUNT ON;

    DECLARE @PostingGroupAuditId INT,
		@OdsVersion VARCHAR(10),
		@IsFullExtract BIT,
		@FullLoadVersion VARCHAR(20),
		@IsFullExtractDifferential BIT,
		@LatestODSVersion VARCHAR(20)

-- When AppVersion is NULL or empty string , let's set this to '0.0'  (when no
-- value exists for AppVersion, SSIS is passing an empty string). 

    IF @SADBVersion = '' OR @SADBVersion IS NULL
        SET @SADBVersion = '0.0';

    IF @SAFSVersion = '' OR @SAFSVersion IS NULL
        SET @SAFSVersion = '0.0';

-- Let's also store the version of the ODS. We'll pass this information along in the control files.
	SELECT TOP 1
		@OdsVersion = AppVersion
	FROM    rpt.AppVersion
	ORDER BY AppVersionId DESC;

-- Get Top 2 level version numbers
	SELECT @LatestODSVersion = rpt.GetSubstringUpToNthOccurence(@OdsVersion,'.',2)

    BEGIN TRY

        BEGIN TRANSACTION

		SELECT @IsFullExtract = IsFullExtract ,
			   @FullLoadVersion = FullLoadVersion,
			   @IsFullExtractDifferential = ISNULL(IsFullLoadDifferential, 0)
		FROM rpt.DataExtractType 
		WHERE DataExtractTypeId = @DataExtractTypeId;

		-- Let's make sure we have a valid DataExtractTypeId
		IF @@ROWCOUNT = 0
        BEGIN
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
                  ChildDBCTVersion ,
                  ChildDBSnapshotName ,
				  ChildDBSiteInfoHistory,
				  CoreDBCTVersion,
                  CoreDBSnapshotName ,
				  CoreDBSiteInfoHistory,
				  DBSnapshotServer ,
				  SADBVersion ,
				  SAFSVersion ,
                  SnapshotCreateDate ,
                  CreateDate ,
                  LastChangeDate ,
				  OdsVersion 
			    )
                SELECT  @PostingGroupId ,
                        @DataExtractTypeId ,
                        '01' ,
                        @ChildDBCTVersion ,
                        @ChildDBSnapshotName ,
						@ChildDBSiteInfoHistory,
						@CoreDBCTVersion,
						@CoreDBSnapshotName,
						@CoreDBSiteInfoHistory,
                        @DBSnapshotServer ,
						@SADBVersion ,
						@SAFSVersion ,
                        @SnapshotCreateDate ,
                        GETDATE() ,
                        GETDATE() ,
						@OdsVersion

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
						INNER JOIN rpt.Process p2 ON p.ProcessId = p2.ProcessId
                WHERE   g.PostingGroupId = @PostingGroupId
						AND (
							(@DataExtractTypeId = 1 AND ((@FullLoadVersion = '0.0' AND p2.MinODSVersion = @LatestODSVersion) 
														OR (@FullLoadVersion <> '0.0' AND @IsFullExtractDifferential = 1 AND CAST('/' + REPLACE(p2.MinODSVersion,'.','.1') + '/' AS HIERARCHYID) >= CAST('/' + REPLACE(@FullLoadVersion,'.','.1') + '/' AS HIERARCHYID))
														OR (@FullLoadVersion <> '0.0' AND @IsFullExtractDifferential = 0 AND p2.MinODSVersion = @FullLoadVersion)))
							OR
							@DataExtractTypeId <> 1
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
						-- to a supported version of the application.
							 WHEN ec.MinAppVersion = '0.0' THEN ISNULL(cp.PreviousCheckpoint, 0)
						-- We've got several checkpoint types:
						-- 1) rpt.Process.IsSnapshot = 0: Change Tracking
						-- 2) rpt.Process.IsSnapshot = 1: Snapshots either Core Snapshots or Child Database Snapshots
                             WHEN p.IsSnapshot = 0 AND p.IsHimStatic = 0 THEN @ChildDBCTVersion
							 WHEN p.IsSnapshot = 0 AND p.IsHimStatic = 1 THEN @CoreDBCTVersion
                             WHEN p.IsSnapshot = 1
                                  AND p.IsHimStatic = 0 
								  AND p.ProductKey = 'SmartAdvisor' THEN @ChildDBSiteInfoHistory
                             WHEN p.IsSnapshot = 1
                                  AND p.IsHimStatic = 1 THEN @CoreDBSiteInfoHistory
                             ELSE NULL
                        END ,
                        GETDATE() ,
                        GETDATE()
                FROM    rpt.ProcessAudit pa
                        INNER JOIN rpt.Process p ON pa.ProcessId = p.ProcessId
						-- Let's use the HIERARCHYID data type to compare application versions.
                        INNER JOIN ( SELECT ec1.ProcessId ,
                                            MAX(CAST('/' + REPLACE(ec1.MinAppVersion,'.','.1') + '/' AS HIERARCHYID)) AS MinAppVersion
                                     FROM   rpt.ProcessStep ec1
									 INNER JOIN rpt.Process p1 ON ec1.ProcessId = p1.ProcessId
									 -- We want to get the greatest (relative to supported AppVersion) from ProcessStep records
									 -- that's less than or equal to our current product version.
									 WHERE CAST('/' + REPLACE(ec1.MinAppVersion,'.','.1') + '/' AS HIERARCHYID) <= CAST('/' + CASE WHEN p1.ProductKey = 'SmartAdvisor' THEN REPLACE(@SADBVersion,'.','.1')
																											END + '/' AS HIERARCHYID)
                                     GROUP BY ec1.ProcessId ) a ON p.ProcessId = a.ProcessId
                        INNER JOIN rpt.ProcessStep ec ON a.ProcessId = ec.ProcessId
                                                         AND a.MinAppVersion = CAST('/' + REPLACE(ec.MinAppVersion,'.','.1') + '/' AS HIERARCHYID)
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

        
    END CATCH
RETURN
END
GO
