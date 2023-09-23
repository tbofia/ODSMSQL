IF OBJECT_ID('dbo.if_ICD_Diagnosis', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ICD_Diagnosis;
GO

CREATE FUNCTION dbo.if_ICD_Diagnosis(
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
	t.Code,
	t.ShortDesc,
	t.Description,
	t.Detailed
FROM src.ICD_Diagnosis t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ICDDiagnosisID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ICD_Diagnosis
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ICDDiagnosisID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ICDDiagnosisID = s.ICDDiagnosisID
WHERE t.DmlOperation <> 'D';

GO


