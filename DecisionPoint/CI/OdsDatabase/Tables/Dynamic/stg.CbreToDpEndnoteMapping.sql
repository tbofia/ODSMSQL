IF OBJECT_ID('stg.CbreToDpEndnoteMapping', 'U') IS NOT NULL 
	DROP TABLE stg.CbreToDpEndnoteMapping  
BEGIN
	CREATE TABLE stg.CbreToDpEndnoteMapping
		(
		  Endnote INT NULL,
		  EndnoteTypeId TINYINT NULL,
		  CbreEndnote SMALLINT NULL,
		  PricingState VARCHAR (2) NULL,
		  PricingMethodId TINYINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

