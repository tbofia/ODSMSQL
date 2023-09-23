IF OBJECT_ID('stg.CoverageType', 'U') IS NOT NULL 
	DROP TABLE stg.CoverageType  
BEGIN
	CREATE TABLE stg.CoverageType
		(
		  LongName VARCHAR (30) NULL,
		  ShortName VARCHAR (2) NULL,
		  CbreCoverageTypeCode VARCHAR (2) NULL,
		  CoverageTypeCategoryCode VARCHAR(4) NULL,
		  PricingMethodId TINYINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

