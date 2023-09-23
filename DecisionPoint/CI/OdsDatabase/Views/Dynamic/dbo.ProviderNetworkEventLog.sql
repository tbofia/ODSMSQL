IF OBJECT_ID('dbo.ProviderNetworkEventLog', 'V') IS NOT NULL
    DROP VIEW dbo.ProviderNetworkEventLog;
GO

CREATE VIEW dbo.ProviderNetworkEventLog
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,IDField
	,LogDate
	,EventId
	,ClaimIdNo
	,BillIdNo
	,UserId
	,NetworkId
	,FileName
	,ExtraText
	,ProcessInfo
	,TieredTypeID
	,TierNumber
FROM src.ProviderNetworkEventLog
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


