IF OBJECT_ID('stg.Region', 'U') IS NOT NULL 
	DROP TABLE stg.Region  
BEGIN
	CREATE TABLE stg.Region
		(
		  Jurisdiction CHAR (2) NULL,
		  Extension CHAR (3) NULL,
		  EndZip CHAR (5) NULL,
		  Beg VARCHAR (5) NULL,
		  Region SMALLINT NULL,
		  RegionDescription VARCHAR (4) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

