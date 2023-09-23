IF OBJECT_ID('stg.SurgicalModifierException', 'U') IS NOT NULL 
	DROP TABLE stg.SurgicalModifierException  
BEGIN
	CREATE TABLE stg.SurgicalModifierException
		(
		  Modifier VARCHAR (2) NULL,
		  State VARCHAR (2) NULL,
		  CoverageType VARCHAR (2) NULL,
		  StartDate DATETIME2 (7) NULL,
		  EndDate DATETIME2 (7) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

