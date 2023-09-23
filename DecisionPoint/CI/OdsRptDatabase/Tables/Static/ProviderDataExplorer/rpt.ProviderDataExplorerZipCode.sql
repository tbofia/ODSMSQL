
IF OBJECT_ID('rpt.ProviderAnalyticsZipCode', 'U') IS NOT NULL
DROP TABLE rpt.ProviderAnalyticsZipCode

GO

IF OBJECT_ID('rpt.ProviderDataExplorerZipCode','U') IS NULL
BEGIN
CREATE TABLE rpt.ProviderDataExplorerZipCode
(
	ZipCode	VARCHAR(500) NOT NULL,
	ZipCodeType	VARCHAR(500) NULL,
	City VARCHAR(500) NULL,
	State VARCHAR(500) NULL,
	LocationType VARCHAR(500) NULL,
	Lat	FLOAT NULL,
	Long FLOAT NULL,
	Location VARCHAR(500) NULL,
	Decommisioned VARCHAR(500) NULL,
	TaxReturnsFiled VARCHAR(500) NULL,
	EstimatedPopulation	VARCHAR(500) NULL,
	TotalWages	VARCHAR(500) NULL
)	
	ALTER TABLE rpt.ProviderDataExplorerZipCode ADD 
	CONSTRAINT PK_ProviderDataExplorerZipCode PRIMARY KEY CLUSTERED
	(
		ZipCode
	);
END
GO
