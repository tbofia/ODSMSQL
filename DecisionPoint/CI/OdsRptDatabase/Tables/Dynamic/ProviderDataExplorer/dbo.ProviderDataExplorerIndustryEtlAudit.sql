
IF OBJECT_ID('dbo.ProviderDataExplorerIndustryEtlAudit','U') IS NULL	
 BEGIN
CREATE TABLE dbo.ProviderDataExplorerIndustryEtlAudit
	(
	AuditId INT IDENTITY(1,1) NOT NULL,
	AuditFor VARCHAR(50) NOT NULL,
	AuditProcess VARCHAR(50) NOT NULL,	
	StartDatetime DATETIME NOT NULL,
	EndDatetime DATETIME NULL,
	CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
	UpdatedDate DATETIME NOT NULL DEFAULT GETDATE(),
	ReportId INT NULL
	)

	ALTER TABLE dbo.ProviderDataExplorerIndustryEtlAudit ADD 
	CONSTRAINT PK_ProviderDataExplorerIndustryEtlAudit PRIMARY KEY CLUSTERED
	(
		AuditId
	);
END
GO
