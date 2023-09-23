IF OBJECT_ID('stg.CMS_Zip2Region', 'U') IS NOT NULL 
	DROP TABLE stg.CMS_Zip2Region  
BEGIN
	CREATE TABLE stg.CMS_Zip2Region
		(
		  StartDate DATETIME NULL,
		  EndDate DATETIME NULL,
		  ZIP_Code VARCHAR (5) NULL,
		  State VARCHAR (2) NULL,
		  Region VARCHAR (2) NULL,
		  AmbRegion VARCHAR (2) NULL,
		  RuralFlag SMALLINT NULL,
		  ASCRegion SMALLINT NULL,
		  PlusFour SMALLINT NULL,
		  CarrierId INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

