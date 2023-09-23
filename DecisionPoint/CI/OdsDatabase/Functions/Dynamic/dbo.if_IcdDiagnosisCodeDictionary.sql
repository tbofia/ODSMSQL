IF OBJECT_ID('dbo.if_IcdDiagnosisCodeDictionary', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_IcdDiagnosisCodeDictionary;
GO

CREATE FUNCTION dbo.if_IcdDiagnosisCodeDictionary(
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
	t.IcdVersion,
	t.StartDate,
	t.EndDate,
	t.NonSpecific,
	t.Traumatic,
	t.Duration,
	t.Description,
	t.DiagnosisFamilyId,
	t.DiagnosisSeverityId,
	t.LateralityId,
	t.TotalCharactersRequired,
	t.PlaceholderRequired,
	t.Flags,
	t.AdditionalDigits,
	t.Colossus,
	t.InjuryNatureId,
	t.EncounterSubcategoryId
FROM src.IcdDiagnosisCodeDictionary t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DiagnosisCode,
		IcdVersion,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.IcdDiagnosisCodeDictionary
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DiagnosisCode,
		IcdVersion,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DiagnosisCode = s.DiagnosisCode
	AND t.IcdVersion = s.IcdVersion
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D';

GO


