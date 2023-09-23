IF OBJECT_ID('dbo.if_BillAdjustment', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillAdjustment;
GO

CREATE FUNCTION dbo.if_BillAdjustment(
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
	t.BillLineAdjustmentId,
	t.BillIdNo,
	t.LineNumber,
	t.Adjustment,
	t.EndNote,
	t.EndNoteTypeId
FROM src.BillAdjustment t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillLineAdjustmentId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillAdjustment
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillLineAdjustmentId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillLineAdjustmentId = s.BillLineAdjustmentId
WHERE t.DmlOperation <> 'D';

GO


