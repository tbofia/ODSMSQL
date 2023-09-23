
IF OBJECT_ID('dbo.ProviderDataExplorerIndustryOutput','U') IS NULL	
BEGIN
CREATE TABLE dbo.ProviderDataExplorerIndustryOutput(
	ProviderClusterName VARCHAR(250) NULL,
	FormType NVARCHAR(10) NULL,
	SubFormType VARCHAR(200) NULL,
	CoverageLine VARCHAR(50) NULL,
	StateofJurisdiction VARCHAR(2) NULL,
	InjuryType VARCHAR(100) NULL,
	CodeType VARCHAR(25) NULL,
	Code VARCHAR(50) NULL,
	Category VARCHAR(100) NULL,
	SubCategory VARCHAR(250) NULL,
	AvgActualTenure INT NULL,
	AvgExpectedTenure INT NULL,
	TotalCharged MONEY NULL,
	TotalAllowed MONEY NULL,
	TotalAdjustment MONEY NULL,
	TotalClaims INT NULL,
	TotalClaimants INT NULL,
	TotalBills INT NULL,
	TotalLines INT NULL,
	RunDate DATETIME NOT NULL DEFAULT GETDATE()
);
END

GO


