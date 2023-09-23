IF OBJECT_ID('dbo.if_ClaimSys', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ClaimSys;
GO

CREATE FUNCTION dbo.if_ClaimSys(
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
	t.ClaimIDMask,
	t.ClaimAccess,
	t.ClaimSysDesc,
	t.PolicyholderReq,
	t.ValidateBranch,
	t.ValidatePolicy,
	t.LglCode1TableCode,
	t.LglCode2TableCode,
	t.LglCode3TableCode,
	t.UROccTableCode,
	t.Policy5DaysTableCode,
	t.Policy90DaysTableCode,
	t.Job5DaysTableCode,
	t.Job90DaysTableCode,
	t.HCOTransIndTableCode,
	t.QualifiedInjWorkTableCode,
	t.PermStationaryTableCode,
	t.ValidateAdjuster,
	t.MCOProgram,
	t.AdjusterRequired,
	t.HospitalAdmitTableCode,
	t.AttorneyTaxAddrRequired,
	t.BodyPartTableCode,
	t.PolicyDefaults,
	t.PolicyCoPayAmount,
	t.PolicyCoPayPct,
	t.PolicyDeductible,
	t.PolicyLimit,
	t.PolicyTimeLimit,
	t.PolicyLimitWarningPct,
	t.RestrictUserAccess,
	t.BEOverridePermissionFlag,
	t.RootClaimLength,
	t.RelateClaimsTotalPolicyDetail,
	t.PolicyLimitResult,
	t.EnableClaimClientCodeDefault,
	t.ReevalCopyDocCtrlID,
	t.EnableCEPHeaderFieldEdits,
	t.EnableSmartClientSelection,
	t.SCSClientSelectionCode,
	t.SCSProviderSubset,
	t.SCSClientCodeMask,
	t.SCSDefaultClient,
	t.ClaimExternalIDasCarrierClaimID,
	t.PolicyExternalIDasCarrierPolicyID,
	t.URProfileID,
	t.BEUROverridesRequireReviewRef,
	t.UREntryValidations,
	t.PendPPOEDIControl,
	t.BEReevalLineAddDelete,
	t.CPTGroupToIndividual,
	t.ClaimExternalIDasClaimAdminClaimNum,
	t.CreateUserID,
	t.CreateDate,
	t.ModUserID,
	t.ModDate,
	t.FinancialAggregation
FROM src.ClaimSys t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimSysSubset,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ClaimSys
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimSysSubset) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimSysSubset = s.ClaimSysSubset
WHERE t.DmlOperation <> 'D';

GO


