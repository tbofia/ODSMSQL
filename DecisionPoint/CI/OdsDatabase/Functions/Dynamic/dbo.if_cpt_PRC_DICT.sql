IF OBJECT_ID('dbo.if_cpt_PRC_DICT', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_cpt_PRC_DICT;
GO

CREATE FUNCTION dbo.if_cpt_PRC_DICT(
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
	t.PRC_CD,
	t.StartDate,
	t.EndDate,
	t.PRC_DESC,
	t.Flags,
	t.Vague,
	t.PerVisit,
	t.PerClaimant,
	t.PerProvider,
	t.BodyFlags,
	t.Colossus,
	t.CMS_Status,
	t.DrugFlag,
	t.CurativeFlag,
	t.ExclPolicyLimit,
	t.SpecNetFlag
FROM src.cpt_PRC_DICT t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PRC_CD,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.cpt_PRC_DICT
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PRC_CD,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PRC_CD = s.PRC_CD
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D';

GO


