IF OBJECT_ID('dbo.if_UDFBill', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_UDFBill;
GO

CREATE FUNCTION dbo.if_UDFBill(
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
	t.UDFIdNo,
	t.UDFValueText,
	t.UDFValueDecimal,
	t.UDFValueDate
FROM src.UDFBill t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		UDFIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UDFBill
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo,
		UDFIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
	AND t.UDFIdNo = s.UDFIdNo
WHERE t.DmlOperation <> 'D';

GO


