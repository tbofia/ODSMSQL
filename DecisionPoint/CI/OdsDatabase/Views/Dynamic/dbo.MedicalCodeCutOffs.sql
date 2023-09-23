IF OBJECT_ID('dbo.MedicalCodeCutOffs', 'V') IS NOT NULL
    DROP VIEW dbo.MedicalCodeCutOffs;
GO

CREATE VIEW dbo.MedicalCodeCutOffs
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CodeTypeID
	,CodeType
	,Code
	,FormType
	,MaxChargedPerUnit
	,MaxUnitsPerEncounter
FROM src.MedicalCodeCutOffs
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


