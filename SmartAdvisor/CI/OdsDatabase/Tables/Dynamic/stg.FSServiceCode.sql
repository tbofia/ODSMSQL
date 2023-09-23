IF OBJECT_ID('stg.FSServiceCode', 'U') IS NOT NULL 
	DROP TABLE stg.FSServiceCode  
BEGIN
	CREATE TABLE stg.FSServiceCode
		(
		  Jurisdiction CHAR (2) NULL,
		  ServiceCode VARCHAR (30) NULL,
		  GeoAreaCode VARCHAR (12) NULL,
		  EffectiveDate DATETIME NULL,
		  Description VARCHAR (255) NULL,
		  TermDate DATETIME NULL,
		  CodeSource VARCHAR (6) NULL,
		  CodeGroup VARCHAR (12) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

