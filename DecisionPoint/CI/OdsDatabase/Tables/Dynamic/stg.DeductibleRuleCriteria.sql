IF OBJECT_ID('stg.DeductibleRuleCriteria', 'U') IS NOT NULL 
	DROP TABLE stg.DeductibleRuleCriteria  
BEGIN
	CREATE TABLE stg.DeductibleRuleCriteria
		(
		  DeductibleRuleCriteriaId INT NULL,
		  PricingRuleDateCriteriaId TINYINT NULL,
		  StartDate DATETIME NULL,
		  EndDate DATETIME NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

