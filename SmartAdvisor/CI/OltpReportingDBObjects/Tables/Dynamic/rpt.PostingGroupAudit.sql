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
