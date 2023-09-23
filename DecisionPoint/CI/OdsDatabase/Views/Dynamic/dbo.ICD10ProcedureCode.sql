IF OBJECT_ID('dbo.ICD10ProcedureCode', 'V') IS NOT NULL
    DROP VIEW dbo.ICD10ProcedureCode;
GO

CREATE VIEW dbo.ICD10ProcedureCode
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ICDProcedureCode
	,StartDate
	,EndDate
	,Description
	,PASGrpNo
FROM src.ICD10ProcedureCode
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


