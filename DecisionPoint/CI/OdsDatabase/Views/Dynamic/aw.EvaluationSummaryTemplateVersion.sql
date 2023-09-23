IF OBJECT_ID('aw.EvaluationSummaryTemplateVersion', 'V') IS NOT NULL
    DROP VIEW aw.EvaluationSummaryTemplateVersion;
GO

CREATE VIEW aw.EvaluationSummaryTemplateVersion
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,EvaluationSummaryTemplateVersionId
	,Template
	,TemplateHash
	,CreatedDate
FROM src.EvaluationSummaryTemplateVersion
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


