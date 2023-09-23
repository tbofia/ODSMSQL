
IF OBJECT_ID('stg.ProviderDataExplorerIndustryProvider', 'U') IS NOT NULL
DROP TABLE stg.ProviderDataExplorerIndustryProvider;

BEGIN
CREATE TABLE Stg.ProviderDataExplorerIndustryProvider
	(
	OdsCustomerId INT NOT NULL,
	ProviderId INT NOT NULL,
	ProviderTIN VARCHAR(15) NULL,
	ProviderFirstName VARCHAR(35) NULL,
	ProviderLastName VARCHAR(60) NULL,
	ProviderGroup VARCHAR(60) NULL,
	ProviderState VARCHAR(2) NULL,
	ProviderZip VARCHAR(12) NULL,
	ProviderNPINumber VARCHAR(10) NULL,
	ProviderName VARCHAR(150) NULL,
	ProviderTypeID VARCHAR(10) NULL,
	ProviderClusterId VARCHAR(100) NULL,
	ProviderClusterName VARCHAR(350) NULL,
	RunDate DATETIME NOT NULL DEFAULT GETDATE()
	);

END
GO
