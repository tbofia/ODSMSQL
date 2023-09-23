IF OBJECT_ID('dbo.PPOSubNetwork', 'V') IS NOT NULL
    DROP VIEW dbo.PPOSubNetwork;
GO

CREATE VIEW dbo.PPOSubNetwork
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,PPONetworkID
	,GroupCode
	,GroupName
	,ExternalID
	,SiteCode
	,CreateDate
	,CreateUserID
	,ModDate
	,ModUserID
	,Street1
	,Street2
	,City
	,State
	,Zip
	,PhoneNum
	,EmailAddress
	,WebSite
	,TIN
	,Comment
FROM src.PPOSubNetwork
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


