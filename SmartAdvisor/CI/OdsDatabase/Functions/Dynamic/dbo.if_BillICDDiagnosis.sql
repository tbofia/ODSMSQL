IF OBJECT_ID('dbo.if_BillICDDiagnosis', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillICDDiagnosis;
GO

CREATE FUNCTION dbo.if_BillICDDiagnosis(
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
	t.ClientCode,
	t.BillSeq,
	t.BillDiagnosisSeq,
	t.ICDDiagnosisID,
	t.POA,
	t.BilledICDDiagnosis,
	t.ICDBillUsageTypeID
FROM src.BillICDDiagnosis t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		BillSeq,
		BillDiagnosisSeq,
		ICDBillUsageTypeID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillICDDiagnosis
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		BillSeq,
		BillDiagnosisSeq,
		ICDBillUsageTypeID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.BillSeq = s.BillSeq
	AND t.BillDiagnosisSeq = s.BillDiagnosisSeq
	AND t.ICDBillUsageTypeID = s.ICDBillUsageTypeID
WHERE t.DmlOperation <> 'D';

GO


