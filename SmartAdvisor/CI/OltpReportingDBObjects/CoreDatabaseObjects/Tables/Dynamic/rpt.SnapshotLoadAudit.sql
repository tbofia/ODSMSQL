IF OBJECT_ID('rpt.SnapshotLoadAudit', 'U') IS NULL
BEGIN
    CREATE TABLE  rpt.SnapshotLoadAudit
        (
		SnapshotLoadAuditId INT IDENTITY(1,1),
		SiteCode CHAR(3) NOT NULL,
		SiteInfoHistorySeq BIGINT NOT NULL,
		OdsVersion VARCHAR(10) NOT NULL,
		Status CHAR(2) NOT NULL,
		CreateDate DATETIME NOT NULL
		);
END
GO



