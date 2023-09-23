IF OBJECT_ID('dbo.ClaimSys', 'V') IS NOT NULL
    DROP VIEW dbo.ClaimSys;
GO

CREATE VIEW dbo.ClaimSys
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClaimSysSubset
	,ClaimIDMask
	,ClaimAccess
	,ClaimSysDesc
	,PolicyholderReq
	,ValidateBranch
	,ValidatePolicy
	,LglCode1TableCode
	,LglCode2TableCode
	,LglCode3TableCode
	,UROccTableCode
	,Policy5DaysTableCode
	,Policy90DaysTableCode
	,Job5DaysTableCode
	,Job90DaysTableCode
	,HCOTransIndTableCode
	,QualifiedInjWorkTableCode
	,PermStationaryTableCode
	,ValidateAdjuster
	,MCOProgram
	,AdjusterRequired
	,HospitalAdmitTableCode
	,AttorneyTaxAddrRequired
	,BodyPartTableCode
	,PolicyDefaults
	,PolicyCoPayAmount
	,PolicyCoPayPct
	,PolicyDeductible
	,PolicyLimit
	,PolicyTimeLimit
	,PolicyLimitWarningPct
	,RestrictUserAccess
	,BEOverridePermissionFlag
	,RootClaimLength
	,RelateClaimsTotalPolicyDetail
	,PolicyLimitResult
	,EnableClaimClientCodeDefault
	,ReevalCopyDocCtrlID
	,EnableCEPHeaderFieldEdits
	,EnableSmartClientSelection
	,SCSClientSelectionCode
	,SCSProviderSubset
	,SCSClientCodeMask
	,SCSDefaultClient
	,ClaimExternalIDasCarrierClaimID
	,PolicyExternalIDasCarrierPolicyID
	,URProfileID
	,BEUROverridesRequireReviewRef
	,UREntryValidations
	,PendPPOEDIControl
	,BEReevalLineAddDelete
	,CPTGroupToIndividual
	,ClaimExternalIDasClaimAdminClaimNum
	,CreateUserID
	,CreateDate
	,ModUserID
	,ModDate
	,FinancialAggregation
FROM src.ClaimSys
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


