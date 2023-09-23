IF OBJECT_ID('dbo.if_PPOSubNetwork', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_PPOSubNetwork;
GO

CREATE FUNCTION dbo.if_PPOSubNetwork(
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
	t.GroupCode,
	t.GroupName,
	t.ExternalID,
	t.SiteCode,
	t.CreateDate,
	t.CreateUserID,
	t.ModDate,
	t.ModUserID,
	t.Street1,
	t.Street2,
	t.City,
	t.State,
	t.Zip,
	t.PhoneNum,
	t.EmailAddress,
	t.WebSite,
	t.TIN,
	t.Comment
FROM src.PPOSubNetwork t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PPONetworkID,
		GroupCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PPOSubNetwork
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PPONetworkID,
		GroupCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PPONetworkID = s.PPONetworkID
	AND t.GroupCode = s.GroupCode
WHERE t.DmlOperation <> 'D';

GO


