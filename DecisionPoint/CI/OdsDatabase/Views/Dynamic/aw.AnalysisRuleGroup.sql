IF OBJECT_ID('aw.AnalysisRuleGroup', 'V') IS NOT NULL
    DROP VIEW aw.AnalysisRuleGroup;
GO

CREATE VIEW aw.AnalysisRuleGroup
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,AnalysisRuleGroupId
	,AnalysisRuleId
	,AnalysisGroupId
FROM src.AnalysisRuleGroup
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


