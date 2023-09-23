IF OBJECT_ID('dbo.ClaimInsurer', 'V') IS NOT NULL
    DROP VIEW dbo.ClaimInsurer;
GO

CREATE VIEW dbo.ClaimInsurer
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
	,ClaimSeq
	,InsurerType
	,EffectiveDate
	,InsurerSeq
	,TerminationDate
	,ExternalPolicyNumber
	,UnitStatClaimID
	,UnitStatPolicyID
	,PolicyEffectiveDate
	,SelfInsured
	,ClaimAdminClaimNum
FROM src.ClaimInsurer
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


