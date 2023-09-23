IF OBJECT_ID('dbo.if_BIReportAdjustmentCategory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BIReportAdjustmentCategory;
GO

CREATE FUNCTION dbo.if_BIReportAdjustmentCategory(
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
	t.Name,
	t.Description,
	t.DisplayPriority
FROM src.BIReportAdjustmentCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BIReportAdjustmentCategoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BIReportAdjustmentCategory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BIReportAdjustmentCategoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BIReportAdjustmentCategoryId = s.BIReportAdjustmentCategoryId
WHERE t.DmlOperation <> 'D';

GO


