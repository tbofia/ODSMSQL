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
	t.ProviderSubSet,
	t.ProviderSeq,
	t.OrgOdsCustomerId,
	t.MitchellProviderKey,
	t.ProviderClusterKey,
	t.ProviderType
FROM src.ProviderCluster t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProviderSubSet,
		ProviderSeq,
		OrgOdsCustomerId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderCluster
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProviderSubSet,
		ProviderSeq,
		OrgOdsCustomerId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProviderSubSet = s.ProviderSubSet
	AND t.ProviderSeq = s.ProviderSeq
	AND t.OrgOdsCustomerId = s.OrgOdsCustomerId
WHERE t.DmlOperation <> 'D';

GO


