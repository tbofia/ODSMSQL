IF OBJECT_ID('dbo.if_CustomerBillExclusion', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CustomerBillExclusion;
GO

CREATE FUNCTION dbo.if_CustomerBillExclusion(
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
	t.Customer,
	t.ReportID,
	t.CreateDate
FROM src.CustomerBillExclusion t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		Customer,
		ReportID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CustomerBillExclusion
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo,
		Customer,
		ReportID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
	AND t.Customer = s.Customer
	AND t.ReportID = s.ReportID
WHERE t.DmlOperation <> 'D';

GO


