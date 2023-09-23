IF OBJECT_ID('dbo.if_ReferenceBillApcLines', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ReferenceBillApcLines;
GO

CREATE FUNCTION dbo.if_ReferenceBillApcLines(
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
	t.Line_No,
	t.PaymentAPC,
	t.ServiceIndicator,
	t.PaymentIndicator,
	t.OutlierAmount,
	t.PricerAllowed,
	t.MedicareAmount
FROM src.ReferenceBillApcLines t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		Line_No,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ReferenceBillApcLines
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo,
		Line_No) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
	AND t.Line_No = s.Line_No
WHERE t.DmlOperation <> 'D';

GO


