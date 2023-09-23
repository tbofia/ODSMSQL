IF OBJECT_ID('dbo.Bills_Pharm_CTG_Endnotes', 'V') IS NOT NULL
    DROP VIEW dbo.Bills_Pharm_CTG_Endnotes;
GO

CREATE VIEW dbo.Bills_Pharm_CTG_Endnotes
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
	,RuleType
	,RuleId
	,PreCertAction
	,PercentDiscount
	,ActionId
FROM src.Bills_Pharm_CTG_Endnotes
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


