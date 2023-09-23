IF OBJECT_ID('stg.ClientInsurer', 'U') IS NOT NULL 
	DROP TABLE stg.ClientInsurer  
BEGIN
	CREATE TABLE stg.ClientInsurer
		(
		  ClientCode CHAR (4) NULL,
		  InsurerType CHAR (1) NULL,
		  EffectiveDate DATETIME NULL,
		  InsurerSeq INT NULL,
		  TerminationDate DATETIME NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

