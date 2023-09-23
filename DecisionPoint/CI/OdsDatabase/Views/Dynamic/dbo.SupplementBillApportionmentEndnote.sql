IF OBJECT_ID('dbo.SupplementBillApportionmentEndnote', 'V') IS NOT NULL
    DROP VIEW dbo.SupplementBillApportionmentEndnote;
GO

CREATE VIEW dbo.SupplementBillApportionmentEndnote
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
FROM src.SupplementBillApportionmentEndnote
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


