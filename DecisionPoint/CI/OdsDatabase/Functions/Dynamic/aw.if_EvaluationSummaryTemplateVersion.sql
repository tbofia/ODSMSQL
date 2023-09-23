IF OBJECT_ID('aw.if_EvaluationSummaryTemplateVersion', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_EvaluationSummaryTemplateVersion;
GO

CREATE FUNCTION aw.if_EvaluationSummaryTemplateVersion(
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
	t.EvaluationSummaryTemplateVersionId,
	t.Template,
	t.TemplateHash,
	t.CreatedDate
FROM src.EvaluationSummaryTemplateVersion t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		EvaluationSummaryTemplateVersionId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EvaluationSummaryTemplateVersion
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		EvaluationSummaryTemplateVersionId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.EvaluationSummaryTemplateVersionId = s.EvaluationSummaryTemplateVersionId
WHERE t.DmlOperation <> 'D';

GO


