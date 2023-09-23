IF OBJECT_ID('dbo.if_RPT_RsnCategories', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_RPT_RsnCategories;
GO

CREATE FUNCTION dbo.if_RPT_RsnCategories(
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
	t.CategoryIdNo,
	t.CatDesc,
	t.Priority
FROM src.RPT_RsnCategories t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CategoryIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.RPT_RsnCategories
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CategoryIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CategoryIdNo = s.CategoryIdNo
WHERE t.DmlOperation <> 'D';

GO


