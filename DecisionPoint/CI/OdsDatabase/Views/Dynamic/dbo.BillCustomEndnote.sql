IF OBJECT_ID('dbo.BillCustomEndnote', 'V') IS NOT NULL
    DROP VIEW dbo.BillCustomEndnote;
GO

CREATE VIEW dbo.BillCustomEndnote
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
FROM src.BillCustomEndnote
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


