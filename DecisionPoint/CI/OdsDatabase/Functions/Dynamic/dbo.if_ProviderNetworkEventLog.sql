IF OBJECT_ID('dbo.if_ProviderNetworkEventLog', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ProviderNetworkEventLog;
GO

CREATE FUNCTION dbo.if_ProviderNetworkEventLog(
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
	t.IDField,
	t.LogDate,
	t.EventId,
	t.ClaimIdNo,
	t.BillIdNo,
	t.UserId,
	t.NetworkId,
	t.FileName,
	t.ExtraText,
	t.ProcessInfo,
	t.TieredTypeID,
	t.TierNumber
FROM src.ProviderNetworkEventLog t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		IDField,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderNetworkEventLog
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		IDField) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.IDField = s.IDField
WHERE t.DmlOperation <> 'D';

GO


