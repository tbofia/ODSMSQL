IF OBJECT_ID('dbo.ODGData', 'V') IS NOT NULL
    DROP VIEW dbo.ODGData;
GO

CREATE VIEW dbo.ODGData
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
	,ProcedureCode
	,ICDDescription
	,ProcedureDescription
	,IncidenceRate
	,ProcedureFrequency
	,Visits25Perc
	,Visits50Perc
	,Visits75Perc
	,VisitsMean
	,CostsMean
	,AutoApprovalCode
	,PaymentFlag
	,CostPerVisit
FROM src.ODGData
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


