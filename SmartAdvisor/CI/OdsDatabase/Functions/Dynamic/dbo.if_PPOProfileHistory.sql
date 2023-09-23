IF OBJECT_ID('dbo.if_PPOProfileHistory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_PPOProfileHistory;
GO

CREATE FUNCTION dbo.if_PPOProfileHistory(
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
	t.PPOProfileHistorySeq,
	t.RecordDeleted,
	t.LogDateTime,
	t.loginame,
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
FROM src.PPOProfileHistory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PPOProfileHistorySeq,
		SiteCode,
		PPOProfileID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PPOProfileHistory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PPOProfileHistorySeq,
		SiteCode,
		PPOProfileID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PPOProfileHistorySeq = s.PPOProfileHistorySeq
	AND t.SiteCode = s.SiteCode
	AND t.PPOProfileID = s.PPOProfileID
WHERE t.DmlOperation <> 'D';

GO


