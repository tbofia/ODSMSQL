IF OBJECT_ID('rpt.AppVersion', 'U') IS NULL
BEGIN

    CREATE TABLE rpt.AppVersion
        (
            AppVersionId INT IDENTITY(1, 1) ,
            AppVersion VARCHAR(10) NULL ,
            AppVersionDate DATETIME2(7) NULL
        );

    ALTER TABLE rpt.AppVersion ADD 
    CONSTRAINT PK_AppVersion PRIMARY KEY CLUSTERED (AppVersionId);

END
GO

IF OBJECT_ID('rpt.PostingGroupAudit', 'U') IS NULL
BEGIN
    CREATE TABLE rpt.PostingGroupAudit
        (
            PostingGroupAuditId INT IDENTITY(1, 1) ,
            PostingGroupId TINYINT NOT NULL ,
            DataExtractTypeId TINYINT NOT NULL ,
            Status VARCHAR(2) NOT NULL ,
            ChildDBCTVersion BIGINT NULL ,
            ChildDBSnapshotName VARCHAR(100) NOT NULL ,
			ChildDBSiteInfoHistory INT NULL,
			CoreDBCTVersion BIGINT NULL ,
			CoreDBSnapshotName VARCHAR(100) NOT NULL ,
			CoreDBSiteInfoHistory INT NULL,
            DBSnapshotServer VARCHAR(100) NOT NULL ,
            SADBVersion VARCHAR(20) NULL ,
			SAFSVersion VARCHAR(20) NULL ,
            SnapshotCreateDate DATETIME2(7) NOT NULL ,
            SnapshotDropDate DATETIME2(7) NULL ,
            CreateDate DATETIME2(7) NOT NULL ,
            LastChangeDate DATETIME2(7) NOT NULL ,
			OdsVersion VARCHAR(10) NOT NULL CONSTRAINT DF_PostingGroupAudit_OdsVersion DEFAULT ('1.0.0.0') ,
        );

    ALTER TABLE rpt.PostingGroupAudit ADD 
    CONSTRAINT PK_PostingGroupAudit PRIMARY KEY CLUSTERED (PostingGroupAuditId);
END
GO
IF OBJECT_ID('rpt.PostingGroupAuditError', 'U') IS NULL
BEGIN
    CREATE TABLE rpt.PostingGroupAuditError
        (
            PostingGroupAuditErrorId INT IDENTITY(1, 1) ,
            PostingGroupAuditId INT NOT NULL ,
            ErrorCode VARCHAR(5) NOT NULL ,
            ErrorDescription VARCHAR(MAX) NOT NULL ,
            LastChangeDate DATETIME2(7) NOT NULL ,
        );

    ALTER TABLE rpt.PostingGroupAuditError ADD 
    CONSTRAINT PK_PostingGroupAuditError PRIMARY KEY CLUSTERED (PostingGroupAuditErrorId);
END
GO
IF OBJECT_ID('rpt.ProcessAudit', 'U') IS NULL
BEGIN
    CREATE TABLE rpt.ProcessAudit
        (
            ProcessAuditId INT IDENTITY(1, 1) ,
            PostingGroupAuditId INT NOT NULL ,
            ProcessId SMALLINT NOT NULL ,
            Status VARCHAR(2) NOT NULL ,
			TotalRowCount BIGINT NULL,
            QueueDate DATETIME2(7) NOT NULL ,
            ExtractDate DATETIME2(7) NULL ,
            CreateDate DATETIME2(7) NOT NULL ,
            LastChangeDate DATETIME2(7) NOT NULL
        );

    ALTER TABLE rpt.ProcessAudit ADD 
    CONSTRAINT PK_ProcessAudit PRIMARY KEY CLUSTERED (ProcessAuditId);

END
GO


-- Adding New Column to store Records count from control file
IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'rpt.ProcessAudit')
                        AND NAME = 'TotalRowCount' )
    BEGIN

	BEGIN TRANSACTION
	BEGIN TRY

	SELECT  ProcessAuditId,
            PostingGroupAuditId,
            ProcessId,
            Status,
			NULL AS TotalRowCount,
            QueueDate,
            ExtractDate,
            CreateDate,
            LastChangeDate
	INTO #ProcessAudit
	FROM rpt.ProcessAudit;
	
	DROP TABLE  rpt.ProcessAudit;
	
	 CREATE TABLE rpt.ProcessAudit
        (
            ProcessAuditId INT IDENTITY(1, 1) ,
            PostingGroupAuditId INT NOT NULL ,
            ProcessId SMALLINT NOT NULL ,
            Status VARCHAR(2) NOT NULL ,
			TotalRowCount BIGINT NULL,
            QueueDate DATETIME2(7) NOT NULL ,
            ExtractDate DATETIME2(7) NULL ,
            CreateDate DATETIME2(7) NOT NULL ,
            LastChangeDate DATETIME2(7) NOT NULL
        );

    ALTER TABLE rpt.ProcessAudit ADD 
    CONSTRAINT PK_ProcessAudit PRIMARY KEY CLUSTERED (ProcessAuditId);

  	SET IDENTITY_INSERT rpt.ProcessAudit ON;
	INSERT INTO rpt.ProcessAudit(
		    ProcessAuditId,
            PostingGroupAuditId,
            ProcessId,
            Status,
			TotalRowCount,
            QueueDate,
            ExtractDate,
            CreateDate,
            LastChangeDate)
	SELECT  ProcessAuditId,
            PostingGroupAuditId,
            ProcessId,
            Status,
			TotalRowCount,
            QueueDate,
            ExtractDate,
            CreateDate,
            LastChangeDate
	FROM #ProcessAudit; 
	SET IDENTITY_INSERT rpt.ProcessAudit OFF; 
	COMMIT
	END TRY

	BEGIN CATCH
	ROLLBACK
	END CATCH

	END;
GO




SET XACT_ABORT ON
IF OBJECT_ID('rpt.ProcessCheckpoint', 'U') IS NULL
    BEGIN
        BEGIN TRANSACTION
        CREATE TABLE rpt.ProcessCheckpoint
            (
              ProcessId SMALLINT NOT NULL ,
              PreviousCheckpoint BIGINT NOT NULL ,
              LastChangeDate DATETIME2(7) NOT NULL
            );

        ALTER TABLE rpt.ProcessCheckpoint ADD 
        CONSTRAINT PK_ProcessCheckpoint PRIMARY KEY CLUSTERED (ProcessId);

		-- When we push the table, we'll want to copy over the existing checkpoints.
		IF OBJECT_ID('rpt.ProcessStepAudit', 'U') IS NOT NULL
		BEGIN
				INSERT  INTO rpt.ProcessCheckpoint
						( ProcessId ,
						  PreviousCheckpoint ,
						  LastChangeDate
						)
						SELECT  ps.ProcessId ,
								MAX(psa.CurrentCheckpoint) AS PreviousCheckpoint ,
								GETDATE()
						FROM    rpt.ProcessStepAudit psa
								INNER JOIN rpt.ProcessStep ps ON psa.ProcessStepId = ps.ProcessStepId
						WHERE   psa.CompleteDate IS NOT NULL
						GROUP BY ps.ProcessId;
		END
        COMMIT TRANSACTION
    END
GO
IF OBJECT_ID('rpt.ProcessStepAudit', 'U') IS NULL
BEGIN
    CREATE TABLE rpt.ProcessStepAudit
        (
            ProcessStepAuditId INT IDENTITY(1, 1) ,
            ProcessAuditId INT NOT NULL ,
            ProcessStepId INT NOT NULL ,
            PreviousCheckpoint BIGINT NULL ,
            CurrentCheckpoint BIGINT NULL ,
            CompleteDate DATETIME2(7) NULL ,
            TotalRowsAffected INT NULL ,
            CreateDate DATETIME2(7) NOT NULL ,
            LastChangeDate DATETIME2(7) NOT NULL
        );

    ALTER TABLE rpt.ProcessStepAudit ADD 
    CONSTRAINT PK_ProcessStepAudit PRIMARY KEY CLUSTERED (ProcessStepAuditId);
END
GO

-- --------------------------------------------------
-- Creating Table Description in Extended Property
-- --------------------------------------------------

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties
	WHERE   major_id = OBJECT_ID(N'rpt.AppVersion')
		AND name = N'MS_Description'
		AND minor_id = 0)
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion' --Table Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'This table stores a record for each version deployed to the database, along with the date and time of deployment',    --Table Description
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion' --Table Name

GO



-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.AppVersion')
		AND ep.name = N'MS_Description'
		AND c.name = N'AppVersionId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'AppVersionId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Primary key; Identity',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'AppVersionId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.AppVersion')
		AND ep.name = N'MS_Description'
		AND c.name = N'AppVersion' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'AppVersion' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'ODS version; the forrmat is x.x.x[.x]',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'AppVersion' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.AppVersion')
		AND ep.name = N'MS_Description'
		AND c.name = N'AppVersionDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'AppVersionDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The date and time this record was inserted into the AppVersion table',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'AppVersionDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Table Description in Extended Property
-- --------------------------------------------------

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND name = N'MS_Description'
		AND minor_id = 0)
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit' --Table Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Audit table that tracks the status of a posting group extract.',    --Table Description
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit' --Table Name

GO



-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'PostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Primary key. Identity.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'PostingGroupId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroup',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'DataExtractTypeId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DataExtractTypeId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to DataExtractType',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DataExtractTypeId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'Status' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'Status' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Load status for posting group.  This will either be a number representing the step in the extract process, or FI for complete.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'Status' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'ChildDBCTVersion' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ChildDBCTVersion' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Change tracking version Id.  Used for checkpointing tables under change tracking.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ChildDBCTVersion' --Column Name

GO

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'CoreDBCTVersion' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CoreDBCTVersion' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Change tracking version Id.  Used for checkpointing tables under change tracking in Core database.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CoreDBCTVersion' --Column Name

GO

-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'ChildDBSiteInfoHistory' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ChildDBSiteInfoHistory' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Max value of SiteinforHistory..SiteinforHistorySeq. Used for checkpointing dev static tables.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ChildDBSiteInfoHistory' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'CoreDBSiteInfoHistory' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CoreDBSiteInfoHistory' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Max value of SiteinforHistory..SiteinforHistorySeq in the HIM static database.  Used for checkpointing HIM static tables.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CoreDBSiteInfoHistory' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'ChildDBSnapshotName' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ChildDBSnapshotName' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The name of the database snapshot created for our data extraction process',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ChildDBSnapshotName' --Column Name

GO

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'CoreDBSnapshotName' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CoreDBSnapshotName' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The name of the database snapshot created for our data extraction process',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CoreDBSnapshotName' --Column Name

GO



-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'DBSnapshotServer' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DBSnapshotServer' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The name of the server on which our snapshot was created.  If the production server is an AOAG cluster, this will be one of the secondary servers.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DBSnapshotServer' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'SADBVersion' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'SADBVersion' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The Smart Advisor version of the OLTP',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'SADBVersion' --Column Name

GO

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'SAFSVersion' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'SAFSVersion' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The Smart Advisor version of the Core Database',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'SAFSVersion' --Column Name

GO



-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'SnapshotCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'SnapshotCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The date and time the snapshot database was created',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'SnapshotCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'SnapshotDropDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'SnapshotDropDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The data and time the snapshot database was dropped.  This happens after all data is extracted successfully.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'SnapshotDropDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'CreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The date and time the record was added',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'LastChangeDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LastChangeDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The last date and time the record was updated',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LastChangeDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsVersion' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsVersion' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Acs Ods version at the time this record was queued.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsVersion' --Column Name

GO


-- --------------------------------------------------
-- Creating Table Description in Extended Property
-- --------------------------------------------------

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessAudit')
		AND name = N'MS_Description'
		AND minor_id = 0)
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit' --Table Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Audit table that tracks the status of each table extract',    --Table Description
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit' --Table Name

GO



-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'ProcessAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Primary key.  Identity.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'PostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'ProcessId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Process.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'Status' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'Status' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Load status for posting group.  This will either be a number representing the step in the extract process, or FI for complete.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'Status' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'QueueDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'QueueDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The date and time the record was added',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'QueueDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'ExtractDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ExtractDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Data and time data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ExtractDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'CreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The date and time the record was added',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'LastChangeDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LastChangeDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The last date and time the record was updated',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LastChangeDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Table Description in Extended Property
-- --------------------------------------------------

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessCheckpoint')
		AND name = N'MS_Description'
		AND minor_id = 0)
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessCheckpoint' --Table Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'This table is used to keep track of where the last successful run for each table left off.  Used for incremental extracts.',    --Table Description
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessCheckpoint' --Table Name

GO



-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessCheckpoint')
		AND ep.name = N'MS_Description'
		AND c.name = N'ProcessId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessCheckpoint', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Process. Primary key.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessCheckpoint', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessCheckpoint')
		AND ep.name = N'MS_Description'
		AND c.name = N'PreviousCheckpoint' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessCheckpoint', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PreviousCheckpoint' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Checkpoint value at time of last successful extract.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessCheckpoint', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PreviousCheckpoint' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessCheckpoint')
		AND ep.name = N'MS_Description'
		AND c.name = N'LastChangeDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessCheckpoint', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LastChangeDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The date and time the record was added',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessCheckpoint', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LastChangeDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Table Description in Extended Property
-- --------------------------------------------------

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessStepAudit')
		AND name = N'MS_Description'
		AND minor_id = 0)
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit' --Table Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Audit table that tracks the status of each process step',    --Table Description
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit' --Table Name

GO



-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessStepAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'ProcessStepAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessStepAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Primary key. Identity.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessStepAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessStepAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'ProcessAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to ProcessAudit',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessStepAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'ProcessStepId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessStepId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to ProcessStep',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessStepId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessStepAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'PreviousCheckpoint' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PreviousCheckpoint' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Checkpoint value for last successful extract',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PreviousCheckpoint' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessStepAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'CurrentCheckpoint' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CurrentCheckpoint' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Checkpoint value for current extract',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CurrentCheckpoint' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessStepAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'CompleteDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CompleteDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time extract was completed',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CompleteDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessStepAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'TotalRowsAffected' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'TotalRowsAffected' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Total number of rows extracted',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'TotalRowsAffected' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessStepAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'CreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Data and time data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessStepAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'LastChangeDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LastChangeDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The last date and time the record was updated',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LastChangeDate' --Column Name

GO

