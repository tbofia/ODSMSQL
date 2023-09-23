IF OBJECT_ID('stg.PPORateType', 'U') IS NOT NULL 
	DROP TABLE stg.PPORateType  
BEGIN
	CREATE TABLE stg.PPORateType
		(
		  RateTypeCode CHAR (8) NULL,
		  PPONetworkID CHAR (2) NULL,
		  Category CHAR (1) NULL,
		  Priority CHAR (1) NULL,
		  VBColor SMALLINT NULL,
		  RateTypeDescription VARCHAR (70) NULL,
		  Explanation VARCHAR (6000) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

