IF OBJECT_ID('dbo.CLAIMANT', 'V') IS NOT NULL
    DROP VIEW dbo.CLAIMANT;
GO

CREATE VIEW dbo.CLAIMANT
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CmtIDNo
	,ClaimIDNo
	,CmtSSN
	,CmtLastName
	,CmtFirstName
	,CmtMI
	,CmtDOB
	,CmtSEX
	,CmtAddr1
	,CmtAddr2
	,CmtCity
	,CmtState
	,CmtZip
	,CmtPhone
	,CmtOccNo
	,CmtAttorneyNo
	,CmtPolicyLimit
	,CmtStateOfJurisdiction
	,CmtDeductible
	,CmtCoPaymentPercentage
	,CmtCoPaymentMax
	,CmtPPO_Eligible
	,CmtCoordBenefits
	,CmtFLCopay
	,CmtCOAExport
	,CmtPGFirstName
	,CmtPGLastName
	,CmtDedType
	,ExportToClaimIQ
	,CmtInactive
	,CmtPreCertOption
	,CmtPreCertState
	,CreateDate
	,LastChangedOn
	,OdsParticipant
	,CoverageType
	,DoNotDisplayCoverageTypeOnEOB
	,ShowAllocationsOnEob
	,SetPreAllocation
	,PharmacyEligible
	,SendCardToClaimant
	,ShareCoPayMaximum
FROM src.CLAIMANT
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


