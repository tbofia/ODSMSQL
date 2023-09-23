IF OBJECT_ID('aw.if_EvaluationSummaryHistory', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_EvaluationSummaryHistory;
GO

CREATE FUNCTION aw.if_EvaluationSummaryHistory(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.EvaluationSummaryHistoryId,
	t.DemandClaimantId,
	t.EvaluationSummary,
	t.CreatedBy,
	t.CreatedDate
FROM src.EvaluationSummaryHistory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		EvaluationSummaryHistoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EvaluationSummaryHistory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		EvaluationSummaryHistoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.EvaluationSummaryHistoryId = s.EvaluationSummaryHistoryId
WHERE t.DmlOperation <> 'D';

GO


