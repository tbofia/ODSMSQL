IF OBJECT_ID('dbo.SupplementBill_Pharm_ApportionmentEndnote', 'V') IS NOT NULL
    DROP VIEW dbo.SupplementBill_Pharm_ApportionmentEndnote;
GO

CREATE VIEW dbo.SupplementBill_Pharm_ApportionmentEndnote
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillId
	,SequenceNumber
	,LineNumber
	,Endnote
FROM src.SupplementBill_Pharm_ApportionmentEndnote
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


