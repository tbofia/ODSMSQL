IF OBJECT_ID('dbo.if_IcdDiagnosisCodeDictionaryBodyPart', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_IcdDiagnosisCodeDictionaryBodyPart;
GO

CREATE FUNCTION dbo.if_IcdDiagnosisCodeDictionaryBodyPart(
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
	t.NcciBodyPartId
FROM src.IcdDiagnosisCodeDictionaryBodyPart t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DiagnosisCode,
		IcdVersion,
		StartDate,
		NcciBodyPartId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.IcdDiagnosisCodeDictionaryBodyPart
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DiagnosisCode,
		IcdVersion,
		StartDate,
		NcciBodyPartId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DiagnosisCode = s.DiagnosisCode
	AND t.IcdVersion = s.IcdVersion
	AND t.StartDate = s.StartDate
	AND t.NcciBodyPartId = s.NcciBodyPartId
WHERE t.DmlOperation <> 'D';

GO


