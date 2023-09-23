IF OBJECT_ID('dbo.if_BIReportAdjustmentCategoryMapping', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BIReportAdjustmentCategoryMapping;
GO

CREATE FUNCTION dbo.if_BIReportAdjustmentCategoryMapping(
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
	t.BIReportAdjustmentCategoryId,
	t.Adjustment360SubCategoryId
FROM src.BIReportAdjustmentCategoryMapping t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BIReportAdjustmentCategoryId,
		Adjustment360SubCategoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BIReportAdjustmentCategoryMapping
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BIReportAdjustmentCategoryId,
		Adjustment360SubCategoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BIReportAdjustmentCategoryId = s.BIReportAdjustmentCategoryId
	AND t.Adjustment360SubCategoryId = s.Adjustment360SubCategoryId
WHERE t.DmlOperation <> 'D';

GO


