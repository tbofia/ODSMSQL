IF OBJECT_ID('aw.if_EvaluationSummary', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_EvaluationSummary;
GO

CREATE FUNCTION aw.if_EvaluationSummary(
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
	t.DemandClaimantId,
	t.Details,
	t.CreatedBy,
	t.CreatedDate,
	t.ModifiedBy,
	t.ModifiedDate,
	t.EvaluationSummaryTemplateVersionId
FROM src.EvaluationSummary t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DemandClaimantId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EvaluationSummary
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DemandClaimantId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DemandClaimantId = s.DemandClaimantId
WHERE t.DmlOperation <> 'D';

GO


