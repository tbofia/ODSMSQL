IF OBJECT_ID('aw.AnalysisRule', 'V') IS NOT NULL
    DROP VIEW aw.AnalysisRule;
GO

CREATE VIEW aw.AnalysisRule
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,AnalysisRuleId
	,Title
	,AssemblyQualifiedName
	,MethodToInvoke
	,DisplayMessage
	,DisplayOrder
	,IsActive
	,CreateDate
	,LastChangedOn
	,MessageToken
FROM src.AnalysisRule
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


