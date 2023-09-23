IF OBJECT_ID('dbo.if_Medispan', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Medispan;
GO

CREATE FUNCTION dbo.if_Medispan(
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
	t.NDC,
	t.DEA,
	t.Name1,
	t.Name2,
	t.Name3,
	t.Strength,
	t.Unit,
	t.Pkg,
	t.Factor,
	t.GenericDrug,
	t.Desicode,
	t.Rxotc,
	t.GPI,
	t.Awp1,
	t.Awp0,
	t.Awp2,
	t.EffectiveDt2,
	t.EffectiveDt1,
	t.EffectiveDt0,
	t.FDAEquivalence,
	t.NDCFormat,
	t.RestrictDrugs,
	t.GPPC,
	t.Status,
	t.UpdateDate,
	t.AAWP,
	t.GAWP,
	t.RepackagedCode
FROM src.Medispan t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		NDC,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Medispan
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		NDC) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.NDC = s.NDC
WHERE t.DmlOperation <> 'D';

GO


