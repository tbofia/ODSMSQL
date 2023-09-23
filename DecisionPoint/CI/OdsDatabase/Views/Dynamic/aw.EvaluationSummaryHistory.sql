IF OBJECT_ID('aw.EvaluationSummaryHistory', 'V') IS NOT NULL
    DROP VIEW aw.EvaluationSummaryHistory;
GO

CREATE VIEW aw.EvaluationSummaryHistory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,EvaluationSummaryHistoryId
	,DemandClaimantId
	,EvaluationSummary
	,CreatedBy
	,CreatedDate
FROM src.EvaluationSummaryHistory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


