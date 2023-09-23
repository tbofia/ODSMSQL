IF OBJECT_ID('dbo.Icd10DiagnosisVersion', 'V') IS NOT NULL
    DROP VIEW dbo.Icd10DiagnosisVersion;
GO

CREATE VIEW dbo.Icd10DiagnosisVersion
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,DiagnosisCode
	,StartDate
	,EndDate
	,NonSpecific
	,Traumatic
	,Duration
	,Description
	,DiagnosisFamilyId
	,TotalCharactersRequired
	,PlaceholderRequired
FROM src.Icd10DiagnosisVersion
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


