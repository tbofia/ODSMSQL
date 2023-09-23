IF OBJECT_ID('dbo.if_PPOProfile', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_PPOProfile;
GO

CREATE FUNCTION dbo.if_PPOProfile(
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
	t.SiteCode,
	t.PPOProfileID,
	t.ProfileDesc,
	t.CreateDate,
	t.CreateUserID,
	t.ModDate,
	t.ModUserID,
	t.SmartSearchPageMax,
	t.JurisdictionStackExclusive,
	t.ReevalFullStackWhenOrigAllowNoHit
FROM src.PPOProfile t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		SiteCode,
		PPOProfileID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PPOProfile
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		SiteCode,
		PPOProfileID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.SiteCode = s.SiteCode
	AND t.PPOProfileID = s.PPOProfileID
WHERE t.DmlOperation <> 'D';

GO


