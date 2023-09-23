IF OBJECT_ID('dbo.BillFee', 'V') IS NOT NULL
    DROP VIEW dbo.BillFee;
GO

CREATE VIEW dbo.BillFee
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClientCode
	,BillSeq
	,FeeType
	,TransactionType
	,FeeCtrlSource
	,FeeControlSeq
	,FeeAmount
	,InvoiceSeq
	,InvoiceSubSeq
	,PPONetworkID
	,ReductionCode
	,FeeOverride
	,OverrideVerified
	,ExclusiveFee
	,FeeSourceID
	,HandlingFee
FROM src.BillFee
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


