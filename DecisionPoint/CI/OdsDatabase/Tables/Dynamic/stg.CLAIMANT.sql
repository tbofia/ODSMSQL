IF OBJECT_ID('stg.CLAIMANT', 'U') IS NOT NULL 
	DROP TABLE stg.CLAIMANT  
BEGIN
	CREATE TABLE stg.CLAIMANT
		(
		  CmtIDNo INT NULL,
		  ClaimIDNo INT NULL,
		  CmtSSN VARCHAR (11) NULL,
		  CmtLastName VARCHAR (60) NULL,
		  CmtFirstName VARCHAR (35) NULL,
		  CmtMI VARCHAR (1) NULL,
		  CmtDOB DATETIME NULL,
		  CmtSEX VARCHAR (1) NULL,
		  CmtAddr1 VARCHAR (55) NULL,
		  CmtAddr2 VARCHAR (55) NULL,
		  CmtCity VARCHAR (30) NULL,
		  CmtState VARCHAR (2) NULL,
		  CmtZip VARCHAR (12) NULL,
		  CmtPhone VARCHAR (25) NULL,
		  CmtOccNo VARCHAR (11) NULL,
		  CmtAttorneyNo INT NULL,
		  CmtPolicyLimit MONEY NULL,
		  CmtStateOfJurisdiction VARCHAR (2) NULL,
		  CmtDeductible MONEY NULL,
		  CmtCoPaymentPercentage SMALLINT NULL,
		  CmtCoPaymentMax MONEY NULL,
		  CmtPPO_Eligible SMALLINT NULL,
		  CmtCoordBenefits SMALLINT NULL,
		  CmtFLCopay SMALLINT NULL,
		  CmtCOAExport DATETIME NULL,
		  CmtPGFirstName VARCHAR (30) NULL,
		  CmtPGLastName VARCHAR (30) NULL,
		  CmtDedType SMALLINT NULL,
		  ExportToClaimIQ SMALLINT NULL,
		  CmtInactive SMALLINT NULL,
		  CmtPreCertOption SMALLINT NULL,
		  CmtPreCertState VARCHAR (2) NULL,
		  CreateDate DATETIME NULL,
		  LastChangedOn DATETIME NULL,
		  OdsParticipant BIT NULL,
		  CoverageType VARCHAR (2) NULL,
		  DoNotDisplayCoverageTypeOnEOB BIT NULL,
		  ShowAllocationsOnEob BIT NULL,
		  SetPreAllocation BIT NULL,
		  PharmacyEligible TINYINT NULL,
		  SendCardToClaimant TINYINT NULL,
		  ShareCoPayMaximum BIT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

