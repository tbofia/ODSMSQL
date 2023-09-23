IF OBJECT_ID('aw.if_ClaimantProviderSummaryEvaluation', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_ClaimantProviderSummaryEvaluation;
GO

CREATE FUNCTION aw.if_ClaimantProviderSummaryEvaluation(
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
	t.ClaimantProviderSummaryEvaluationId,
	t.ClaimantHeaderId,
	t.EvaluatedAmount,
	t.MinimumEvaluatedAmount,
	t.MaximumEvaluatedAmount,
	t.Comments
FROM src.ClaimantProviderSummaryEvaluation t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimantProviderSummaryEvaluationId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ClaimantProviderSummaryEvaluation
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimantProviderSummaryEvaluationId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimantProviderSummaryEvaluationId = s.ClaimantProviderSummaryEvaluationId
WHERE t.DmlOperation <> 'D';

GO


