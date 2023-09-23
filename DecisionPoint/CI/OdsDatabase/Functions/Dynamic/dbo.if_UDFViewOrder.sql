IF OBJECT_ID('dbo.if_UDFViewOrder', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_UDFViewOrder;
GO

CREATE FUNCTION dbo.if_UDFViewOrder(
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
	t.OfficeId,
	t.UDFIdNo,
	t.ViewOrder
FROM src.UDFViewOrder t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		OfficeId,
		UDFIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UDFViewOrder
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		OfficeId,
		UDFIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.OfficeId = s.OfficeId
	AND t.UDFIdNo = s.UDFIdNo
WHERE t.DmlOperation <> 'D';

GO


