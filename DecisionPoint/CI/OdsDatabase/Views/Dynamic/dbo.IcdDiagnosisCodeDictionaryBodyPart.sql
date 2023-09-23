IF OBJECT_ID('dbo.IcdDiagnosisCodeDictionaryBodyPart', 'V') IS NOT NULL
    DROP VIEW dbo.IcdDiagnosisCodeDictionaryBodyPart;
GO

CREATE VIEW dbo.IcdDiagnosisCodeDictionaryBodyPart
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
	,NcciBodyPartId
FROM src.IcdDiagnosisCodeDictionaryBodyPart
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


