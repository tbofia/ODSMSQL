IF OBJECT_ID('dbo.if_RevenueCode', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_RevenueCode;
GO

CREATE FUNCTION dbo.if_RevenueCode(
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
	t.RevenueCode,
	t.RevenueCodeSubCategoryId
FROM src.RevenueCode t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RevenueCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.RevenueCode
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RevenueCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RevenueCode = s.RevenueCode
WHERE t.DmlOperation <> 'D';

GO


