IF OBJECT_ID('stg.ReductionType', 'U') IS NOT NULL 
	DROP TABLE stg.ReductionType  
BEGIN
	CREATE TABLE stg.ReductionType
		(
		  ReductionCode SMALLINT NULL,
		  ReductionDescription VARCHAR (50) NULL,
		  BEOverride CHAR (1) NULL,
		  BEMsg CHAR (1) NULL,
		  Abbreviation VARCHAR (8) NULL,
		  DefaultMessageCode VARCHAR (6) NULL,
		  DefaultDenialMessageCode VARCHAR (6) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

