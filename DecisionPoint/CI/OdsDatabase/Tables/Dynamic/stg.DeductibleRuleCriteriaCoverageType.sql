IF OBJECT_ID('stg.DeductibleRuleCriteriaCoverageType', 'U') IS NOT NULL 
	DROP TABLE stg.DeductibleRuleCriteriaCoverageType  
BEGIN
	CREATE TABLE stg.DeductibleRuleCriteriaCoverageType
		(
		  DeductibleRuleCriteriaId INT NULL,
		  CoverageType VARCHAR (5) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

