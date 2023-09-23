IF OBJECT_ID('dbo.if_ProviderCluster', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ProviderCluster;
GO

CREATE FUNCTION dbo.if_ProviderCluster(
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
	t.PvdIDNo,
	t.OrgOdsCustomerId,
	t.MitchellProviderKey,
	t.ProviderClusterKey,
	t.ProviderType
FROM src.ProviderCluster t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PvdIDNo,
		OrgOdsCustomerId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderCluster
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PvdIDNo,
		OrgOdsCustomerId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PvdIDNo = s.PvdIDNo
	AND t.OrgOdsCustomerId = s.OrgOdsCustomerId
WHERE t.DmlOperation <> 'D';

GO


