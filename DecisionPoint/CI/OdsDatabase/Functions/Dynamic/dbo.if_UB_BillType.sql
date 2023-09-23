IF OBJECT_ID('dbo.if_UB_BillType', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_UB_BillType;
GO

CREATE FUNCTION dbo.if_UB_BillType(
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
	t.TOB,
	t.Description,
	t.Flag,
	t.UB_BillTypeID
FROM src.UB_BillType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		TOB,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UB_BillType
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		TOB) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.TOB = s.TOB
WHERE t.DmlOperation <> 'D';

GO


