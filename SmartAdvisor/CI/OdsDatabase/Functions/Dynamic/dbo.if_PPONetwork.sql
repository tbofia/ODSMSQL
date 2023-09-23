IF OBJECT_ID('dbo.if_PPONetwork', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_PPONetwork;
GO

CREATE FUNCTION dbo.if_PPONetwork(
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
	t.PPONetworkID,
	t.Name,
	t.TIN,
	t.Zip,
	t.State,
	t.City,
	t.Street,
	t.PhoneNum,
	t.PPONetworkComment,
	t.AllowMaint,
	t.ReqExtPPO,
	t.DemoRates,
	t.PrintAsProvider,
	t.PPOType,
	t.PPOVersion,
	t.PPOBridgeExists,
	t.UsesDrg,
	t.PPOToOther,
	t.SubNetworkIndicator,
	t.EmailAddress,
	t.WebSite,
	t.BillControlSeq
FROM src.PPONetwork t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PPONetworkID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PPONetwork
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PPONetworkID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PPONetworkID = s.PPONetworkID
WHERE t.DmlOperation <> 'D';

GO


