IF OBJECT_ID('stg.ProviderNumberCriteriaTypeOfBill', 'U') IS NOT NULL 
	DROP TABLE stg.ProviderNumberCriteriaTypeOfBill  
BEGIN
	CREATE TABLE stg.ProviderNumberCriteriaTypeOfBill
		(
		  ProviderNumberCriteriaId SMALLINT NULL,
		  TypeOfBill VARCHAR (4) NULL,
		  MatchingProfileNumber TINYINT NULL,
		  AttributeMatchTypeId TINYINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

