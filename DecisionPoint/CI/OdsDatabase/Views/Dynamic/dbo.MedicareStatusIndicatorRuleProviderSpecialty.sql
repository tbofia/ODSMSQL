IF OBJECT_ID('dbo.MedicareStatusIndicatorRuleProviderSpecialty', 'V') IS NOT NULL
    DROP VIEW dbo.MedicareStatusIndicatorRuleProviderSpecialty;
GO

CREATE VIEW dbo.MedicareStatusIndicatorRuleProviderSpecialty
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
	,ProviderSpecialty
FROM src.MedicareStatusIndicatorRuleProviderSpecialty
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


