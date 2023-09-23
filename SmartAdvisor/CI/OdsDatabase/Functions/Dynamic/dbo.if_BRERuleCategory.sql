IF OBJECT_ID('dbo.if_BRERuleCategory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BRERuleCategory;
GO

CREATE FUNCTION dbo.if_BRERuleCategory(
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
	t.BRERuleCategoryID,
	t.CategoryDescription
FROM src.BRERuleCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BRERuleCategoryID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BRERuleCategory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BRERuleCategoryID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BRERuleCategoryID = s.BRERuleCategoryID
WHERE t.DmlOperation <> 'D';

GO


