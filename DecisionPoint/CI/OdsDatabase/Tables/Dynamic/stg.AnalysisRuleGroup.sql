IF OBJECT_ID('stg.AnalysisRuleGroup', 'U') IS NOT NULL
DROP TABLE stg.AnalysisRuleGroup
BEGIN
	CREATE TABLE stg.AnalysisRuleGroup (
		AnalysisRuleGroupId int NULL
	   ,AnalysisRuleId int NULL
	   ,AnalysisGroupId int NULL
	   ,DmlOperation CHAR(1) NOT NULL
		)
END
GO
