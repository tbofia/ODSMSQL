IF OBJECT_ID('dbo.Jurisdiction', 'V') IS NOT NULL
    DROP VIEW dbo.Jurisdiction;
GO

CREATE VIEW dbo.Jurisdiction
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,JurisdictionID
	,Name
	,POSTableCode
	,TOSTableCode
	,TOBTableCode
	,ProvTypeTableCode
	,Hospital
	,ProvSpclTableCode
	,DaysToPay
	,DaysToPayQualify
	,OutPatientFS
	,ProcFileVer
	,AnestUnit
	,AnestRndUp
	,AnestFormat
	,StateMandateSSN
	,ICDEdition
	,ICD10ComplianceDate
	,eBillsDaysToPay
	,eBillsDaysToPayQualify
	,DisputeDaysToPay
	,DisputeDaysToPayQualify
FROM src.Jurisdiction
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


