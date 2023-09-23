IF OBJECT_ID('stg.AnalysisRuleThreshold', 'U') IS NOT NULL
DROP TABLE stg.AnalysisRuleThreshold
BEGIN
	CREATE TABLE stg.AnalysisRuleThreshold (
	   AnalysisRuleThresholdId int NULL
      ,AnalysisRuleId int NULL
      ,ThresholdKey varchar(50) NULL
      ,ThresholdValue varchar(100) NULL
      ,CreateDate datetimeoffset(7) NULL
      ,LastChangedOn datetimeoffset(7) NULL
	  ,DmlOperation CHAR(1) NOT NULL
		)
END
GO
