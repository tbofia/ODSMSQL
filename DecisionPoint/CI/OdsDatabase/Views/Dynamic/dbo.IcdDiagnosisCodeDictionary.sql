IF OBJECT_ID('dbo.IcdDiagnosisCodeDictionary', 'V') IS NOT NULL
    DROP VIEW dbo.IcdDiagnosisCodeDictionary;
GO

CREATE VIEW dbo.IcdDiagnosisCodeDictionary
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
	,IcdVersion
	,StartDate
	,EndDate
	,NonSpecific
	,Traumatic
	,Duration
	,Description
	,DiagnosisFamilyId
	,DiagnosisSeverityId
	,LateralityId
	,TotalCharactersRequired
	,PlaceholderRequired
	,Flags
	,AdditionalDigits
	,Colossus
	,InjuryNatureId
	,EncounterSubcategoryId
FROM src.IcdDiagnosisCodeDictionary
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


