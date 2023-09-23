IF OBJECT_ID('dbo.BillExclusionLookUpTable', 'U') IS NULL
BEGIN
	CREATE TABLE dbo.BillExclusionLookUpTable (
		ReportID TINYINT NOT NULL
		,ReportName NVARCHAR(100) NOT NULL
		);

	ALTER TABLE dbo.BillExclusionLookUpTable ADD 
	CONSTRAINT PK_BillExclusionLookUpTable PRIMARY KEY CLUSTERED (ReportID ASC);
END
GO

IF OBJECT_ID('dbo.CustomerBillExclusion', 'U') IS NULL
BEGIN
	CREATE TABLE dbo.CustomerBillExclusion (
		BIllIdNo INT NOT NULL
		,Customer NVARCHAR(50) NOT NULL
		,ReportID TINYINT NOT NULL
		,CreateDate DATETIME NULL
		);
		
	ALTER TABLE dbo.CustomerBillExclusion ADD
	CONSTRAINT PK_CustomerBillExclusion PRIMARY KEY CLUSTERED (BIllIdNo ASC,Customer ASC,ReportID ASC);
END
GO


-- Add CreateDate column to dbo.CustomerBillExclusion
IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'dbo.CustomerBillExclusion')
                        AND NAME = 'CreateDate' )
BEGIN
    ALTER TABLE dbo.CustomerBillExclusion ADD CreateDate datetime DEFAULT Getdate()  
END
GO


IF OBJECT_ID('dbo.MedicalCodeCutOffs', 'U') IS NULL
BEGIN
	CREATE TABLE dbo.MedicalCodeCutOffs(
		CodeTypeID INT NOT NULL,
		CodeType VARCHAR(50) NULL,
		Code VARCHAR(50) NOT NULL,
		FormType VARCHAR(10) NOT NULL,
		MaxChargedPerUnit FLOAT NULL,
		MaxUnitsPerEncounter FLOAT NULL);
	ALTER TABLE dbo.MedicalCodeCutOffs ADD
	CONSTRAINT PK_MedicalCodeCutOffs PRIMARY KEY CLUSTERED (CodeTypeID ASC,	Code ASC,FormType ASC) 
END
GO 
IF OBJECT_ID('dbo.ProviderSpecialtyToProvType', 'U') IS NULL
BEGIN
	CREATE TABLE dbo.ProviderSpecialtyToProvType (
		ProviderType VARCHAR(20) NOT NULL
		,ProviderType_Desc VARCHAR(80) NULL
		,Specialty VARCHAR(20) NOT NULL
		,Specialty_Desc VARCHAR(80) NULL
		,CreateDate DATETIME NOT NULL
		,ModifyDate DATETIME NULL
		,LogicalDelete CHAR(1) NOT NULL
		);

	ALTER TABLE dbo.ProviderSpecialtyToProvType ADD 
	CONSTRAINT PK_ProviderSpecialtyToProvType PRIMARY KEY CLUSTERED (ProviderType,Specialty);
END
GO

IF OBJECT_ID('dbo.VPNActivityFlag', 'U') IS NULL
BEGIN
	CREATE TABLE dbo.VPNActivityFlag(
		Activity_Flag VARCHAR(1) NOT NULL,
		AF_Description VARCHAR(50) NULL,
		AF_ShortDesc VARCHAR(50) NULL,
		Data_Source VARCHAR(5) NULL,
		Default_Billable BIT NULL,
		Credit BIT NULL);
		
	ALTER TABLE dbo.VPNActivityFlag 
	ADD CONSTRAINT PK_VPNActivityFlag PRIMARY KEY CLUSTERED (Activity_Flag)
END
GO
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
            IsInitialLoad BIT NOT NULL ,
            Status VARCHAR(2) NOT NULL ,
            CurrentCTVersion BIGINT NULL ,
			CurrentDPAppVersionId INT NULL ,
			CurrentMmedStaticDataVersionId INT NULL ,
            DBSnapshotName VARCHAR(100) NOT NULL ,
            DBSnapshotServer VARCHAR(100) NOT NULL ,
            DPAppVersion VARCHAR(10) NULL ,
            SnapshotCreateDate DATETIME2(7) NOT NULL ,
            SnapshotDropDate DATETIME2(7) NULL ,
            CreateDate DATETIME2(7) NOT NULL ,
            LastChangeDate DATETIME2(7) NOT NULL ,
			AcsOdsVersion VARCHAR(10) NOT NULL CONSTRAINT DF_PostingGroupAudit_AcsOdsVersion DEFAULT ('1.0.0.0') ,
			DMAppVersion VARCHAR(10) NULL ,
			CurrentDMAppVersionId INT NULL
        );

    ALTER TABLE rpt.PostingGroupAudit ADD 
    CONSTRAINT PK_PostingGroupAudit PRIMARY KEY CLUSTERED (PostingGroupAuditId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('rpt.PostingGroupAudit') AND name = 'AcsOdsVersion')
ALTER TABLE rpt.PostingGroupAudit ADD AcsOdsVersion VARCHAR(10) NOT NULL CONSTRAINT DF_PostingGroupAudit_AcsOdsVersion DEFAULT ('1.0.0.0');
GO

SET XACT_ABORT ON;
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('rpt.PostingGroupAudit') AND name = 'IsInitialLoad')
BEGIN
	BEGIN TRANSACTION

	ALTER TABLE rpt.PostingGroupAudit ALTER COLUMN IsInitialLoad TINYINT NOT NULL;

	EXEC sp_rename 'rpt.PostingGroupAudit.IsInitialLoad', 'DataExtractTypeId', 'COLUMN';

	COMMIT TRANSACTION
END
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('rpt.PostingGroupAudit') AND name = 'AppVersion')
	EXEC sp_rename 'rpt.PostingGroupAudit.AppVersion', 'DPAppVersion', 'COLUMN';
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('rpt.PostingGroupAudit') AND name = 'DMAppVersion')
ALTER TABLE rpt.PostingGroupAudit ADD DMAppVersion VARCHAR(10) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('rpt.PostingGroupAudit') AND name = 'CurrentDMAppVersionId')
ALTER TABLE rpt.PostingGroupAudit ADD CurrentDMAppVersionId INT NULL;
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
