
IF OBJECT_ID('stg.ProviderAnalyticsClaimantHeader', 'U') IS NOT NULL
DROP TABLE stg.ProviderAnalyticsClaimantHeader

GO

IF OBJECT_ID('stg.ProviderDataExplorerClaimantHeader', 'U') IS NOT NULL
DROP TABLE stg.ProviderDataExplorerClaimantHeader
BEGIN
CREATE TABLE stg.ProviderDataExplorerClaimantHeader(
	OdsPostingGroupAuditId INT NOT NULL,
	OdsCustomerId INT NOT NULL,	
	ClaimIdNo INT NULL,
	ClaimNo VARCHAR(500) NULL,
	DateLoss DATETIME NULL,
	CVCode VARCHAR(2) NULL,	
	LossState VARCHAR(2) NULL,
	ClaimantIdNo INT NULL,	
	ClaimantState VARCHAR(2) NULL,
	ClaimantZip VARCHAR(12) NULL,
	ClaimantStateOfJurisdiction VARCHAR(2) NULL,
	CoverageType VARCHAR(2) NULL,	
	ClaimantHdrIdNo INT NOT NULL,
	ProviderIdNo INT NOT NULL,
	CreateDate DATETIME NULL,
	LastChangedOn DATETIME NULL,
	CustomerName VARCHAR(100) NULL,	
	CVCodeDesciption VARCHAR(100) NULL,
	CoverageTypeDescription  VARCHAR(100) NULL,
	ExpectedTenureInDays INT NULL,
	ExpectedRecoveryDate DATE NULL	,
	InjuryDescription VARCHAR(100) NULL,
	InjuryNatureId TINYINT NULL,
	InjuryNaturePriority TINYINT NULL,
	RunDate DATETIME NOT NULL DEFAULT GETDATE()
);
END
GO


