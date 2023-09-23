IF OBJECT_ID('dbo.if_cpt_DX_DICT', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_cpt_DX_DICT;
GO

CREATE FUNCTION dbo.if_cpt_DX_DICT(
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
	t.ICD9,
	t.StartDate,
	t.EndDate,
	t.Flags,
	t.NonSpecific,
	t.AdditionalDigits,
	t.Traumatic,
	t.DX_DESC,
	t.Duration,
	t.Colossus,
	t.DiagnosisFamilyId
FROM src.cpt_DX_DICT t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ICD9,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.cpt_DX_DICT
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ICD9,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ICD9 = s.ICD9
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D';

GO


