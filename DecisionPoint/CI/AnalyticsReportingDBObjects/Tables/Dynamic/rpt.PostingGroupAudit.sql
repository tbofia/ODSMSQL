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
