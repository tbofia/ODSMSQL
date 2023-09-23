IF OBJECT_ID('dbo.Bill_Sentry_Endnote', 'V') IS NOT NULL
    DROP VIEW dbo.Bill_Sentry_Endnote;
GO

CREATE VIEW dbo.Bill_Sentry_Endnote
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillID
	,Line
	,RuleID
	,PercentDiscount
	,ActionId
FROM src.Bill_Sentry_Endnote
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


