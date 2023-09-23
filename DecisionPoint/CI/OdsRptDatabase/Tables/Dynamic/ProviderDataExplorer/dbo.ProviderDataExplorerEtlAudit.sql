IF OBJECT_ID('dbo.ProviderAnalyticsEtlAudit', 'U') IS NOT NULL
BEGIN
	-- Rename the existing dbo.ProviderAnalyticsEtlAudit tbale to dbo.ProviderDataExplorerEtlAudit.
	EXEC sp_rename 'dbo.ProviderAnalyticsEtlAudit.PK_ProviderAnalyticsEtlAudit', 'PK_ProviderDataExplorerEtlAudit', N'INDEX'
	EXEC sp_rename 'dbo.ProviderAnalyticsEtlAudit', 'ProviderDataExplorerEtlAudit'	
END

GO

IF OBJECT_ID('dbo.ProviderDataExplorerEtlAudit','U') IS NULL	

BEGIN
CREATE TABLE dbo.ProviderDataExplorerEtlAudit(
	AuditId INT IDENTITY(1,1) NOT NULL,
	AuditFor VARCHAR(50) NOT NULL,
	AuditProcess VARCHAR(50) NOT NULL,
	DataAsOfOdsPostingGroupAuditId INT NOT NULL,
	StartDatetime DATETIME NOT NULL,
	EndDatetime DATETIME NULL,
	CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
	UpdatedDate DATETIME NOT NULL DEFAULT GETDATE(),
	ReportId INT NULL
)

	ALTER TABLE dbo.ProviderDataExplorerEtlAudit ADD 
	CONSTRAINT PK_ProviderDataExplorerEtlAudit PRIMARY KEY CLUSTERED
	(
		AuditId
	);

END
GO
