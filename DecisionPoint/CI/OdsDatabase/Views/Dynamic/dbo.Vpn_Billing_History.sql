IF OBJECT_ID('dbo.Vpn_Billing_History', 'V') IS NOT NULL
    DROP VIEW dbo.Vpn_Billing_History;
GO

CREATE VIEW dbo.Vpn_Billing_History
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,Customer
	,TransactionID
	,Period
	,ActivityFlag
	,BillableFlag
	,Void
	,CreditType
	,Network
	,BillIdNo
	,Line_No
	,TransactionDate
	,RepriceDate
	,ClaimNo
	,ProviderCharges
	,DPAllowed
	,VPNAllowed
	,Savings
	,Credits
	,NetSavings
	,SOJ
	,seqno
	,CompanyCode
	,VpnId
	,ProcessFlag
	,SK
	,DATABASE_NAME
	,SubmittedToFinance
	,IsInitialLoad
	,VpnBillingCategoryCode
FROM src.Vpn_Billing_History
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


