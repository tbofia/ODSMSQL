IF OBJECT_ID('stg.ClaimInsurer', 'U') IS NOT NULL 
	DROP TABLE stg.ClaimInsurer  
BEGIN
	CREATE TABLE stg.ClaimInsurer
		(
		  ClaimSysSubset CHAR (4) NULL,
		  ClaimSeq INT NULL,
		  InsurerType CHAR (1) NULL,
		  EffectiveDate DATETIME NULL,
		  InsurerSeq INT NULL,
		  TerminationDate DATETIME NULL,
		  ExternalPolicyNumber VARCHAR (30) NULL,
		  UnitStatClaimID VARCHAR (35) NULL,
		  UnitStatPolicyID VARCHAR (30) NULL,
		  PolicyEffectiveDate DATETIME NULL,
		  SelfInsured CHAR (1) NULL,
		  ClaimAdminClaimNum VARCHAR (35) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

