IF OBJECT_ID('dbo.DiagnosisCodeGroup', 'V') IS NOT NULL
    DROP VIEW dbo.DiagnosisCodeGroup;
GO

CREATE VIEW dbo.DiagnosisCodeGroup
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
	,MajorCategory
	,MinorCategory
FROM src.DiagnosisCodeGroup
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


