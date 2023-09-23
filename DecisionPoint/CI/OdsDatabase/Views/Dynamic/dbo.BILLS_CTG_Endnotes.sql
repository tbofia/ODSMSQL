IF OBJECT_ID('dbo.BILLS_CTG_Endnotes', 'V') IS NOT NULL
    DROP VIEW dbo.BILLS_CTG_Endnotes;
GO

CREATE VIEW dbo.BILLS_CTG_Endnotes
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillIdNo
	,Line_No
	,Endnote
	,RuleType
	,RuleId
	,PreCertAction
	,PercentDiscount
	,ActionId
FROM src.BILLS_CTG_Endnotes
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


