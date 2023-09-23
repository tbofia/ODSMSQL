IF OBJECT_ID('dbo.VpnLedger', 'V') IS NOT NULL
    DROP VIEW dbo.VpnLedger;
GO

CREATE VIEW dbo.VpnLedger
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,TransactionID
	,TransactionTypeID
	,BillIdNo
	,Line_No
	,Charged
	,DPAllowed
	,VPNAllowed
	,Savings
	,Credits
	,HasOverride
	,EndNotes
	,NetworkIdNo
	,ProcessFlag
	,LineType
	,DateTimeStamp
	,SeqNo
	,VPN_Ref_Line_No
	,SpecialProcessing
	,CreateDate
	,LastChangedOn
	,AdjustedCharged
FROM src.VpnLedger
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


