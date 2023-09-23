IF OBJECT_ID('dbo.Bill_Pharm_ApportionmentEndnote', 'V') IS NOT NULL
    DROP VIEW dbo.Bill_Pharm_ApportionmentEndnote;
GO

CREATE VIEW dbo.Bill_Pharm_ApportionmentEndnote
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
FROM src.Bill_Pharm_ApportionmentEndnote
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


