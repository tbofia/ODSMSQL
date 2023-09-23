IF OBJECT_ID('dbo.if_Adjustment360Category', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Adjustment360Category;
GO

CREATE FUNCTION dbo.if_Adjustment360Category(
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
	t.Adjustment360CategoryId,
	t.Name
FROM src.Adjustment360Category t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Adjustment360CategoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Adjustment360Category
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Adjustment360CategoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Adjustment360CategoryId = s.Adjustment360CategoryId
WHERE t.DmlOperation <> 'D';

GO


