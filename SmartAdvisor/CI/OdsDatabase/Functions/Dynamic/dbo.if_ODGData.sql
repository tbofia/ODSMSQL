IF OBJECT_ID('dbo.if_ODGData', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ODGData;
GO

CREATE FUNCTION dbo.if_ODGData(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ICDDiagnosisID,
	t.ProcedureCode,
	t.ICDDescription,
	t.ProcedureDescription,
	t.IncidenceRate,
	t.ProcedureFrequency,
	t.Visits25Perc,
	t.Visits50Perc,
	t.Visits75Perc,
	t.VisitsMean,
	t.CostsMean,
	t.AutoApprovalCode,
	t.PaymentFlag,
	t.CostPerVisit
FROM src.ODGData t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ICDDiagnosisID,
		ProcedureCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ODGData
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ICDDiagnosisID,
		ProcedureCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ICDDiagnosisID = s.ICDDiagnosisID
	AND t.ProcedureCode = s.ProcedureCode
WHERE t.DmlOperation <> 'D';

GO


