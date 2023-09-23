
IF OBJECT_ID('adm.ReportJobAudit', 'U') IS NULL
BEGIN
CREATE TABLE adm.ReportJobAudit(
	ReportJobAuditId INT NOT NULL IDENTITY(1,1),
	ReportID INT NULL,
	CommandID INT NULL,
	JobStatus INT NULL,
	CmdStatus INT NULL,
	Job_StartDate DATETIME NULL,
	Job_LastUpdate DATETIME NULL,
	Cmd_LastUpdate DATETIME NULL
	);
 ALTER TABLE adm.ReportJobAudit ADD 
        CONSTRAINT PK_ReportJobAudit PRIMARY KEY CLUSTERED (ReportJobAuditId);
END
GO
