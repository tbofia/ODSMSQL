IF OBJECT_ID('dbo.PPOProfile', 'V') IS NOT NULL
    DROP VIEW dbo.PPOProfile;
GO

CREATE VIEW dbo.PPOProfile
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,SiteCode
	,PPOProfileID
	,ProfileDesc
	,CreateDate
	,CreateUserID
	,ModDate
	,ModUserID
	,SmartSearchPageMax
	,JurisdictionStackExclusive
	,ReevalFullStackWhenOrigAllowNoHit
FROM src.PPOProfile
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


