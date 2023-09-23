IF OBJECT_ID('aw.EvaluationSummary', 'V') IS NOT NULL
    DROP VIEW aw.EvaluationSummary;
GO

CREATE VIEW aw.EvaluationSummary
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,DemandClaimantId
	,Details
	,CreatedBy
	,CreatedDate
	,ModifiedBy
	,ModifiedDate
	,EvaluationSummaryTemplateVersionId
FROM src.EvaluationSummary
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


