IF OBJECT_ID('dbo.PPOProfileHistory', 'V') IS NOT NULL
    DROP VIEW dbo.PPOProfileHistory;
GO

CREATE VIEW dbo.PPOProfileHistory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,PPOProfileHistorySeq
	,RecordDeleted
	,LogDateTime
	,loginame
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
FROM src.PPOProfileHistory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


