IF OBJECT_ID('dbo.if_PolicyInsurer', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_PolicyInsurer;
GO

CREATE FUNCTION dbo.if_PolicyInsurer(
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
	t.PolicySeq,
	t.Jurisdiction,
	t.InsurerType,
	t.EffectiveDate,
	t.InsurerSeq,
	t.TerminationDate
FROM src.PolicyInsurer t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimSysSubset,
		PolicySeq,
		Jurisdiction,
		InsurerType,
		EffectiveDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PolicyInsurer
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimSysSubset,
		PolicySeq,
		Jurisdiction,
		InsurerType,
		EffectiveDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimSysSubset = s.ClaimSysSubset
	AND t.PolicySeq = s.PolicySeq
	AND t.Jurisdiction = s.Jurisdiction
	AND t.InsurerType = s.InsurerType
	AND t.EffectiveDate = s.EffectiveDate
WHERE t.DmlOperation <> 'D';

GO


