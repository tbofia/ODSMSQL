IF OBJECT_ID('dbo.BILLS_Endnotes', 'V') IS NOT NULL
    DROP VIEW dbo.BILLS_Endnotes;
GO

CREATE VIEW dbo.BILLS_Endnotes
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillIDNo
	,LINE_NO
	,EndNote
	,Referral
	,PercentDiscount
	,ActionId
	,EndnoteTypeId
FROM src.BILLS_Endnotes
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


