IF OBJECT_ID('dbo.MedicareStatusIndicatorRule', 'V') IS NOT NULL
    DROP VIEW dbo.MedicareStatusIndicatorRule;
GO

CREATE VIEW dbo.MedicareStatusIndicatorRule
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,MedicareStatusIndicatorRuleId
	,MedicareStatusIndicatorRuleName
	,StatusIndicator
	,StartDate
	,EndDate
	,Endnote
	,EditActionId
	,Comments
FROM src.MedicareStatusIndicatorRule
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


