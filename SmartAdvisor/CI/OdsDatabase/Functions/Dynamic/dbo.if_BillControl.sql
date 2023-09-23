IF OBJECT_ID('dbo.if_BillControl', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillControl;
GO

CREATE FUNCTION dbo.if_BillControl(
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
	t.ClientCode,
	t.BillSeq,
	t.BillControlSeq,
	t.ModDate,
	t.CreateDate,
	t.Control,
	t.ExternalID,
	t.BatchNumber,
	t.ModUserID,
	t.ExternalID2,
	t.Message
FROM src.BillControl t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		BillSeq,
		BillControlSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillControl
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		BillSeq,
		BillControlSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.BillSeq = s.BillSeq
	AND t.BillControlSeq = s.BillControlSeq
WHERE t.DmlOperation <> 'D';

GO


