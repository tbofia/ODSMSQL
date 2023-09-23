IF OBJECT_ID('aw.ClaimantProviderSummaryEvaluation', 'V') IS NOT NULL
    DROP VIEW aw.ClaimantProviderSummaryEvaluation;
GO

CREATE VIEW aw.ClaimantProviderSummaryEvaluation
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClaimantProviderSummaryEvaluationId
	,ClaimantHeaderId
	,EvaluatedAmount
	,MinimumEvaluatedAmount
	,MaximumEvaluatedAmount
	,Comments
FROM src.ClaimantProviderSummaryEvaluation
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


