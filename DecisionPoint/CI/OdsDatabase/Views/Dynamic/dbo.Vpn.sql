IF OBJECT_ID('dbo.Vpn', 'V') IS NOT NULL
    DROP VIEW dbo.Vpn;
GO

CREATE VIEW dbo.Vpn
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,VpnId
	,NetworkName
	,PendAndSend
	,BypassMatching
	,AllowsResends
	,OdsEligible
FROM src.Vpn
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


