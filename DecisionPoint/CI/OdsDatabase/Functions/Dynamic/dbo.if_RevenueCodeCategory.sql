IF OBJECT_ID('dbo.if_RevenueCodeCategory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_RevenueCodeCategory;
GO

CREATE FUNCTION dbo.if_RevenueCodeCategory(
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
	t.RevenueCodeCategoryId,
	t.Description,
	t.NarrativeInformation
FROM src.RevenueCodeCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RevenueCodeCategoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.RevenueCodeCategory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RevenueCodeCategoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RevenueCodeCategoryId = s.RevenueCodeCategoryId
WHERE t.DmlOperation <> 'D';

GO


