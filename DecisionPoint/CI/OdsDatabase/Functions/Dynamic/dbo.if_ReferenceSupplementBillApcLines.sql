IF OBJECT_ID('dbo.if_ReferenceSupplementBillApcLines', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ReferenceSupplementBillApcLines;
GO

CREATE FUNCTION dbo.if_ReferenceSupplementBillApcLines(
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
	t.BillIdNo,
	t.SeqNo,
	t.Line_No,
	t.PaymentAPC,
	t.ServiceIndicator,
	t.PaymentIndicator,
	t.OutlierAmount,
	t.PricerAllowed,
	t.MedicareAmount
FROM src.ReferenceSupplementBillApcLines t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		SeqNo,
		Line_No,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ReferenceSupplementBillApcLines
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo,
		SeqNo,
		Line_No) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
	AND t.SeqNo = s.SeqNo
	AND t.Line_No = s.Line_No
WHERE t.DmlOperation <> 'D';

GO


