IF OBJECT_ID('stg.ProviderNumberCriteriaRevenueCode', 'U') IS NOT NULL 
	DROP TABLE stg.ProviderNumberCriteriaRevenueCode  
BEGIN
	CREATE TABLE stg.ProviderNumberCriteriaRevenueCode
		(
		  ProviderNumberCriteriaId SMALLINT NULL,
		  RevenueCode VARCHAR (4) NULL,
		  MatchingProfileNumber TINYINT NULL,
		  AttributeMatchTypeId TINYINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

