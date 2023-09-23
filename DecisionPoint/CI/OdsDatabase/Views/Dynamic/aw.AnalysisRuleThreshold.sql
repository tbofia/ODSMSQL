IF OBJECT_ID('aw.AnalysisRuleThreshold', 'V') IS NOT NULL
    DROP VIEW aw.AnalysisRuleThreshold;
GO

CREATE VIEW aw.AnalysisRuleThreshold
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,AnalysisRuleThresholdId
	,AnalysisRuleId
	,ThresholdKey
	,ThresholdValue
	,CreateDate
	,LastChangedOn
FROM src.AnalysisRuleThreshold
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


