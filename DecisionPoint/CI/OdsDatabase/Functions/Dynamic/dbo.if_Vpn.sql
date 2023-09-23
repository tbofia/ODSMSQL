IF OBJECT_ID('dbo.if_Vpn', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Vpn;
GO

CREATE FUNCTION dbo.if_Vpn(
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
	t.VpnId,
	t.NetworkName,
	t.PendAndSend,
	t.BypassMatching,
	t.AllowsResends,
	t.OdsEligible
FROM src.Vpn t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		VpnId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Vpn
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		VpnId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.VpnId = s.VpnId
WHERE t.DmlOperation <> 'D';

GO


