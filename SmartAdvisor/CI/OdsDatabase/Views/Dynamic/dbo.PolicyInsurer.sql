IF OBJECT_ID('dbo.PolicyInsurer', 'V') IS NOT NULL
    DROP VIEW dbo.PolicyInsurer;
GO

CREATE VIEW dbo.PolicyInsurer
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
	,PolicySeq
	,Jurisdiction
	,InsurerType
	,EffectiveDate
	,InsurerSeq
	,TerminationDate
FROM src.PolicyInsurer
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


