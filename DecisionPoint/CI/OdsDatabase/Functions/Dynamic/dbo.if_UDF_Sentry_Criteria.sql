IF OBJECT_ID('dbo.if_UDF_Sentry_Criteria', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_UDF_Sentry_Criteria;
GO

CREATE FUNCTION dbo.if_UDF_Sentry_Criteria(
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
	t.UdfIdNo,
	t.CriteriaID,
	t.ParentName,
	t.Name,
	t.Description,
	t.Operators,
	t.PredefinedValues,
	t.ValueDataType,
	t.ValueFormat
FROM src.UDF_Sentry_Criteria t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CriteriaID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UDF_Sentry_Criteria
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CriteriaID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CriteriaID = s.CriteriaID
WHERE t.DmlOperation <> 'D';

GO


