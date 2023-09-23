IF OBJECT_ID('dbo.if_ClaimICDDiagnosis', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ClaimICDDiagnosis;
GO

CREATE FUNCTION dbo.if_ClaimICDDiagnosis(
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
	t.ClaimSysSubSet,
	t.ClaimSeq,
	t.ClaimDiagnosisSeq,
	t.ICDDiagnosisID
FROM src.ClaimICDDiagnosis t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimSysSubSet,
		ClaimSeq,
		ClaimDiagnosisSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ClaimICDDiagnosis
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimSysSubSet,
		ClaimSeq,
		ClaimDiagnosisSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimSysSubSet = s.ClaimSysSubSet
	AND t.ClaimSeq = s.ClaimSeq
	AND t.ClaimDiagnosisSeq = s.ClaimDiagnosisSeq
WHERE t.DmlOperation <> 'D';

GO


