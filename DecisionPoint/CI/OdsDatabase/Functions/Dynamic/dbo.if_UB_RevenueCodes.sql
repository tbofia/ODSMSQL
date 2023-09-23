IF OBJECT_ID('dbo.if_UB_RevenueCodes', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_UB_RevenueCodes;
GO

CREATE FUNCTION dbo.if_UB_RevenueCodes(
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
	t.StartDate,
	t.EndDate,
	t.PRC_DESC,
	t.Flags,
	t.Vague,
	t.PerVisit,
	t.PerClaimant,
	t.PerProvider,
	t.BodyFlags,
	t.DrugFlag,
	t.CurativeFlag,
	t.RevenueCodeSubCategoryId
FROM src.UB_RevenueCodes t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RevenueCode,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UB_RevenueCodes
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RevenueCode,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RevenueCode = s.RevenueCode
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D';

GO


