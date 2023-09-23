IF OBJECT_ID('dbo.ICD_Diagnosis', 'V') IS NOT NULL
    DROP VIEW dbo.ICD_Diagnosis;
GO

CREATE VIEW dbo.ICD_Diagnosis
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ICDDiagnosisID
	,Code
	,ShortDesc
	,Description
	,Detailed
FROM src.ICD_Diagnosis
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


