IF OBJECT_ID('stg.PolicyInsurer', 'U') IS NOT NULL 
	DROP TABLE stg.PolicyInsurer  
BEGIN
	CREATE TABLE stg.PolicyInsurer
		(
		  ClaimSysSubset CHAR (4) NULL,
		  PolicySeq INT NULL,
		  Jurisdiction CHAR (2) NULL,
		  InsurerType CHAR (1) NULL,
		  EffectiveDate DATETIME NULL,
		  InsurerSeq INT NULL,
		  TerminationDate DATETIME NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

