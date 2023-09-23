IF OBJECT_ID('dbo.if_ClaimInsurer', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ClaimInsurer;
GO

CREATE FUNCTION dbo.if_ClaimInsurer(
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
	t.ClaimSysSubset,
	t.ClaimSeq,
	t.InsurerType,
	t.EffectiveDate,
	t.InsurerSeq,
	t.TerminationDate,
	t.ExternalPolicyNumber,
	t.UnitStatClaimID,
	t.UnitStatPolicyID,
	t.PolicyEffectiveDate,
	t.SelfInsured,
	t.ClaimAdminClaimNum
FROM src.ClaimInsurer t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimSysSubset,
		ClaimSeq,
		InsurerType,
		EffectiveDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ClaimInsurer
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimSysSubset,
		ClaimSeq,
		InsurerType,
		EffectiveDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimSysSubset = s.ClaimSysSubset
	AND t.ClaimSeq = s.ClaimSeq
	AND t.InsurerType = s.InsurerType
	AND t.EffectiveDate = s.EffectiveDate
WHERE t.DmlOperation <> 'D';

GO


