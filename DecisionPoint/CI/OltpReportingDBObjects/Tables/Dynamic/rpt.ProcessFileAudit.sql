IF OBJECT_ID('rpt.ProcessFileAudit', 'U') IS NULL
    BEGIN
		CREATE TABLE rpt.ProcessFileAudit(
			ProcessFileAuditId int IDENTITY(1,1) NOT NULL,
			ProcessAuditId int NULL,
			FileNumber int NULL,
			Status varchar(3) NULL,
			TotalRecordsInFile int NULL,
			LoadDate datetime2(7) NULL,
			CreateDate datetime2(7) NULL,
			LastChangeDate datetime2(7) NULL,
			FileSize numeric(10, 3) NULL
		); 
		ALTER TABLE rpt.ProcessFileAudit ADD 
		CONSTRAINT PK_ProcessFileAudit PRIMARY KEY CLUSTERED (ProcessFileAuditId);
	END
GO


