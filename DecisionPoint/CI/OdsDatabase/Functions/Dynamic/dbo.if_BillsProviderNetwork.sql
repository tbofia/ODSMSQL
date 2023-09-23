IF OBJECT_ID('dbo.if_BillsProviderNetwork', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillsProviderNetwork;
GO

CREATE FUNCTION dbo.if_BillsProviderNetwork(
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
	t.NetworkId,
	t.NetworkName
FROM src.BillsProviderNetwork t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillsProviderNetwork
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
WHERE t.DmlOperation <> 'D';

GO


