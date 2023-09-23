IF OBJECT_ID('dbo.Bills_Pharm_Endnotes', 'V') IS NOT NULL
    DROP VIEW dbo.Bills_Pharm_Endnotes;
GO

CREATE VIEW dbo.Bills_Pharm_Endnotes
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
FROM src.Bills_Pharm_Endnotes
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


