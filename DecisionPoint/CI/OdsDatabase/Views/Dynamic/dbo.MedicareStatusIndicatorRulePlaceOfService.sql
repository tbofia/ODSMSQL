IF OBJECT_ID('dbo.MedicareStatusIndicatorRulePlaceOfService', 'V') IS NOT NULL
    DROP VIEW dbo.MedicareStatusIndicatorRulePlaceOfService;
GO

CREATE VIEW dbo.MedicareStatusIndicatorRulePlaceOfService
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
	,PlaceOfService
FROM src.MedicareStatusIndicatorRulePlaceOfService
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


