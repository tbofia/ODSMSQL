IF OBJECT_ID('dbo.if_CLAIMANT', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CLAIMANT;
GO

CREATE FUNCTION dbo.if_CLAIMANT(
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
	t.CmtIDNo,
	t.ClaimIDNo,
	t.CmtSSN,
	t.CmtLastName,
	t.CmtFirstName,
	t.CmtMI,
	t.CmtDOB,
	t.CmtSEX,
	t.CmtAddr1,
	t.CmtAddr2,
	t.CmtCity,
	t.CmtState,
	t.CmtZip,
	t.CmtPhone,
	t.CmtOccNo,
	t.CmtAttorneyNo,
	t.CmtPolicyLimit,
	t.CmtStateOfJurisdiction,
	t.CmtDeductible,
	t.CmtCoPaymentPercentage,
	t.CmtCoPaymentMax,
	t.CmtPPO_Eligible,
	t.CmtCoordBenefits,
	t.CmtFLCopay,
	t.CmtCOAExport,
	t.CmtPGFirstName,
	t.CmtPGLastName,
	t.CmtDedType,
	t.ExportToClaimIQ,
	t.CmtInactive,
	t.CmtPreCertOption,
	t.CmtPreCertState,
	t.CreateDate,
	t.LastChangedOn,
	t.OdsParticipant,
	t.CoverageType,
	t.DoNotDisplayCoverageTypeOnEOB,
	t.ShowAllocationsOnEob,
	t.SetPreAllocation,
	t.PharmacyEligible,
	t.SendCardToClaimant,
	t.ShareCoPayMaximum
FROM src.CLAIMANT t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CmtIDNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CLAIMANT
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CmtIDNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CmtIDNo = s.CmtIDNo
WHERE t.DmlOperation <> 'D';

GO


