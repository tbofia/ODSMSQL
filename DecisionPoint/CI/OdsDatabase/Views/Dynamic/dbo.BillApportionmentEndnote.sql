IF OBJECT_ID('dbo.BillApportionmentEndnote', 'V') IS NOT NULL
    DROP VIEW dbo.BillApportionmentEndnote;
GO

CREATE VIEW dbo.BillApportionmentEndnote
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
	,LineNumber
	,Endnote
FROM src.BillApportionmentEndnote
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


