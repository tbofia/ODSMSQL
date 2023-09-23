IF OBJECT_ID('dbo.ClaimICDDiagnosis', 'V') IS NOT NULL
    DROP VIEW dbo.ClaimICDDiagnosis;
GO

CREATE VIEW dbo.ClaimICDDiagnosis
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClaimSysSubSet
	,ClaimSeq
	,ClaimDiagnosisSeq
	,ICDDiagnosisID
FROM src.ClaimICDDiagnosis
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


