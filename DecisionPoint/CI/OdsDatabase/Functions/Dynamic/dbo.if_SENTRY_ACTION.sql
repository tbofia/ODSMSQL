IF OBJECT_ID('dbo.if_SENTRY_ACTION', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SENTRY_ACTION;
GO

CREATE FUNCTION dbo.if_SENTRY_ACTION(
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
	t.ActionID,
	t.Name,
	t.Description,
	t.CompatibilityKey,
	t.PredefinedValues,
	t.ValueDataType,
	t.ValueFormat,
	t.BillLineAction,
	t.AnalyzeFlag,
	t.ActionCategoryIDNo
FROM src.SENTRY_ACTION t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ActionID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SENTRY_ACTION
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ActionID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ActionID = s.ActionID
WHERE t.DmlOperation <> 'D';

GO


