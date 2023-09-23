IF OBJECT_ID('dbo.if_VpnBillingCategory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_VpnBillingCategory;
GO

CREATE FUNCTION dbo.if_VpnBillingCategory(
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
	t.VpnBillingCategoryCode,
	t.VpnBillingCategoryDescription
FROM src.VpnBillingCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		VpnBillingCategoryCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.VpnBillingCategory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		VpnBillingCategoryCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.VpnBillingCategoryCode = s.VpnBillingCategoryCode
WHERE t.DmlOperation <> 'D';

GO


