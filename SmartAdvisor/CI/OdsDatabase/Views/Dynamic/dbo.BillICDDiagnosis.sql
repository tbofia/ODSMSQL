IF OBJECT_ID('dbo.BillICDDiagnosis', 'V') IS NOT NULL
    DROP VIEW dbo.BillICDDiagnosis;
GO

CREATE VIEW dbo.BillICDDiagnosis
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClientCode
	,BillSeq
	,BillDiagnosisSeq
	,ICDDiagnosisID
	,POA
	,BilledICDDiagnosis
	,ICDBillUsageTypeID
FROM src.BillICDDiagnosis
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


