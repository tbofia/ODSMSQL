
IF OBJECT_ID('dbo.ProviderAnalyticsClaimantHeader', 'U') IS NOT NULL
BEGIN
	-- Rename the existing dbo.ProviderAnalyticsClaimantHeader tbale to dbo.ProviderDataExplorerClaimantHeader.
	EXEC sp_rename 'dbo.ProviderAnalyticsClaimantHeader.PK_ProviderAnalyticsClaimantHeader', 'PK_ProviderDataExplorerClaimantHeader', N'INDEX'
	EXEC sp_rename 'dbo.ProviderAnalyticsClaimantHeader', 'ProviderDataExplorerClaimantHeader'	
END

GO

IF OBJECT_ID('dbo.ProviderDataExplorerClaimantHeader','U') IS NULL
	
BEGIN
CREATE TABLE dbo.ProviderDataExplorerClaimantHeader(
	OdsPostingGroupAuditId INT NOT NULL,
	OdsCustomerId INT NOT NULL,	
	ClaimId INT NOT NULL,
	ClaimNumber VARCHAR(500) NULL,
	DateLoss DATETIME NULL,
	CVCode VARCHAR(2) NULL,
	LossState VARCHAR(2) NULL,
	ClaimantId INT NULL,	
	ClaimantState VARCHAR(2) NULL,
	ClaimantZip VARCHAR(12) NULL,
	ClaimantStateofJurisdiction VARCHAR(2) NULL,
	CoverageType VARCHAR(25) NULL,
	ClaimantHeaderId INT NOT NULL,
	ProviderId VARCHAR(32) NOT NULL,
	CreateDate DATETIME NULL,
	LastChangedOn DATETIME NULL,
	MinimumDateofService DATE NULL,
	MaximumDateofService DATE NULL,
	DOSTenureInDays INT NULL,
	ExpectedTenureInDays INT NULL,
	ExpectedRecoveryDate DATE NULL,	
	CustomerName VARCHAR(250) NULL,
	InjuryDescription VARCHAR(100) NULL,
	InjuryNatureId TINYINT NULL,
	InjuryNaturePriority TINYINT NULL,	
	DerivedCVType VARCHAR(25) NULL,
	DerivedCVDesc VARCHAR(500) NULL,
	ClaimantZipLat FLOAT NULL,
	ClaimantZipLong FLOAT NULL,
	MSADesignation VARCHAR(10) NULL,
	CBSADesignation VARCHAR(10) NULL,
	CVCodeDesciption VARCHAR(100) NULL,
	CoverageTypeDescription VARCHAR(100) NULL ,	
	RunDate DATETIME NOT NULL DEFAULT GETDATE()

	) ON rpt_PartitionScheme(OdsCustomerId)
	 WITH(
	      DATA_COMPRESSION = PAGE
		 )

	ALTER TABLE dbo.ProviderDataExplorerClaimantHeader ADD
	CONSTRAINT PK_ProviderDataExplorerClaimantHeader PRIMARY KEY CLUSTERED
	(	
		OdsPostingGroupAuditId,
		OdsCustomerId,		
		ClaimantHeaderId
	
	);
END
GO

IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='DmlOperation'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerClaimantHeader' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerClaimantHeader DROP COLUMN DmlOperation 

END;
 
 GO
 
 
IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsCreateDate'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerClaimantHeader' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerClaimantHeader DROP COLUMN OdsCreateDate 

END;
 
 GO

  
  IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsHashbytesValue'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerClaimantHeader' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerClaimantHeader DROP COLUMN OdsHashbytesValue 

END;
 
 GO
  
  
  IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsSnapshotDate'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerClaimantHeader' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerClaimantHeader DROP COLUMN OdsSnapshotDate 

END;
 
 GO


IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsRowIsCurrent'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerClaimantHeader' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerClaimantHeader DROP COLUMN OdsRowIsCurrent 

END;
 
 GO


