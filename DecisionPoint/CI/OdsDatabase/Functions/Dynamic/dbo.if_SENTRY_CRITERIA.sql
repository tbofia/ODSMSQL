IF OBJECT_ID('dbo.if_SENTRY_CRITERIA', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SENTRY_CRITERIA;
GO

CREATE FUNCTION dbo.if_SENTRY_CRITERIA(
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
	t.CriteriaID,
	t.ParentName,
	t.Name,
	t.Description,
	t.Operators,
	t.PredefinedValues,
	t.ValueDataType,
	t.ValueFormat,
	t.NullAllowed
FROM src.SENTRY_CRITERIA t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CriteriaID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SENTRY_CRITERIA
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CriteriaID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CriteriaID = s.CriteriaID
WHERE t.DmlOperation <> 'D';

GO


