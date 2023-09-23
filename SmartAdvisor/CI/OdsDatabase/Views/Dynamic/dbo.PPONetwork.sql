IF OBJECT_ID('dbo.PPONetwork', 'V') IS NOT NULL
    DROP VIEW dbo.PPONetwork;
GO

CREATE VIEW dbo.PPONetwork
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
	,Name
	,TIN
	,Zip
	,State
	,City
	,Street
	,PhoneNum
	,PPONetworkComment
	,AllowMaint
	,ReqExtPPO
	,DemoRates
	,PrintAsProvider
	,PPOType
	,PPOVersion
	,PPOBridgeExists
	,UsesDrg
	,PPOToOther
	,SubNetworkIndicator
	,EmailAddress
	,WebSite
	,BillControlSeq
FROM src.PPONetwork
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


