IF OBJECT_ID('dbo.SupplementBillCustomEndnote', 'V') IS NOT NULL
    DROP VIEW dbo.SupplementBillCustomEndnote;
GO

CREATE VIEW dbo.SupplementBillCustomEndnote
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
FROM src.SupplementBillCustomEndnote
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


