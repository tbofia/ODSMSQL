IF OBJECT_ID('dbo.if_DiagnosisCodeGroup', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_DiagnosisCodeGroup;
GO

CREATE FUNCTION dbo.if_DiagnosisCodeGroup(
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
	t.MajorCategory,
	t.MinorCategory
FROM src.DiagnosisCodeGroup t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DiagnosisCode,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.DiagnosisCodeGroup
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


