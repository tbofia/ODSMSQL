IF OBJECT_ID('stg.SentryRuleTypeCriteria', 'U') IS NOT NULL 
	DROP TABLE stg.SentryRuleTypeCriteria  
BEGIN
	CREATE TABLE stg.SentryRuleTypeCriteria
		(
		  RuleTypeId INT NULL,
		  CriteriaId INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

