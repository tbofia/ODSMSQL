
IF OBJECT_ID('stg.ProviderAnalyticsProvider', 'U') IS NOT NULL
DROP TABLE stg.ProviderAnalyticsProvider

GO

IF OBJECT_ID('stg.ProviderDataExplorerProvider', 'U') IS NOT NULL
DROP TABLE stg.ProviderDataExplorerProvider
BEGIN
CREATE TABLE stg.ProviderDataExplorerProvider(
	OdsPostingGroupAuditId INT NOT NULL,
	OdsCustomerId INT NOT NULL,	
	ProviderIdNo INT NOT NULL,
	ProviderTIN VARCHAR(15) NULL,
	ProviderFirstName VARCHAR(35) NULL,
	ProviderLastName VARCHAR(60) NULL,
	ProviderGroup VARCHAR(60) NULL,
	ProviderState VARCHAR(2) NULL,
	ProviderZip VARCHAR(12) NULL,	
	ProviderSPCList VARCHAR(50) NULL,
	ProviderNPINumber VARCHAR(10) NULL,	
	CreatedDate DATETIME NULL,	
	ProviderName	VARCHAR(150) NULL,
	ProviderTypeID VARCHAR(10) NULL,
	ProviderClusterID VARCHAR(100) NULL,
	Specialty VARCHAR(255) NULL,
	RunDate DATETIME NOT NULL DEFAULT GETDATE()
);
END
GO

