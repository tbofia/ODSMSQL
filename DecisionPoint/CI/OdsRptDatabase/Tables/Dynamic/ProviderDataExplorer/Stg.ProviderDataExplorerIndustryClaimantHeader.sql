
IF OBJECT_ID('stg.ProviderDataExplorerIndustryClaimantHeader', 'U') IS NOT NULL
DROP TABLE stg.ProviderDataExplorerIndustryClaimantHeader;

BEGIN
CREATE TABLE Stg.ProviderDataExplorerIndustryClaimantHeader
(
	OdsCustomerId INT NOT NULL,
	ClaimId INT NOT NULL,
	DateLoss DATETIME NULL,
	CVCode VARCHAR(2) NULL,
	ClaimantId INT NULL,
	ClaimantStateofJurisdiction VARCHAR(2) NULL,
	CoverageType VARCHAR(25) NULL,
	ClaimantHeaderId INT NOT NULL,
	ProviderId INT NULL,
	MinimumDateofService DATE NULL,
	MaximumDateofService DATE NULL,
	DOSTenureInDays INT NULL,
	ExpectedTenureInDays INT NULL,
	InjuryDescription VARCHAR(100) NULL,
	DerivedCVType VARCHAR(25) NULL,
	DerivedCVDesc VARCHAR(500) NULL,
	CVCodeDesciption VARCHAR(100) NULL,
	CoverageTypeDescription VARCHAR(100) NULL,
	RunDate DATETIME NOT NULL DEFAULT GETDATE()
	);

END
GO
