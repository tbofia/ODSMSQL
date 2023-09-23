IF OBJECT_ID('dbo.MedicareStatusIndicatorRuleProcedureCode', 'V') IS NOT NULL
    DROP VIEW dbo.MedicareStatusIndicatorRuleProcedureCode;
GO

CREATE VIEW dbo.MedicareStatusIndicatorRuleProcedureCode
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
	,ProcedureCode
FROM src.MedicareStatusIndicatorRuleProcedureCode
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


