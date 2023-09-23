IF OBJECT_ID('dbo.if_Icd10DiagnosisVersion', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Icd10DiagnosisVersion;
GO

CREATE FUNCTION dbo.if_Icd10DiagnosisVersion(
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
	t.DiagnosisCode,
	t.StartDate,
	t.EndDate,
	t.NonSpecific,
	t.Traumatic,
	t.Duration,
	t.Description,
	t.DiagnosisFamilyId,
	t.TotalCharactersRequired,
	t.PlaceholderRequired
FROM src.Icd10DiagnosisVersion t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DiagnosisCode,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Icd10DiagnosisVersion
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DiagnosisCode,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DiagnosisCode = s.DiagnosisCode
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D';

GO


