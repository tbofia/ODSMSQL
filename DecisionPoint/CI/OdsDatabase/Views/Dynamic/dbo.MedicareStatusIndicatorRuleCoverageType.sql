IF OBJECT_ID('dbo.MedicareStatusIndicatorRuleCoverageType', 'V') IS NOT NULL
    DROP VIEW dbo.MedicareStatusIndicatorRuleCoverageType;
GO

CREATE VIEW dbo.MedicareStatusIndicatorRuleCoverageType
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
	,ShortName
FROM src.MedicareStatusIndicatorRuleCoverageType
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


