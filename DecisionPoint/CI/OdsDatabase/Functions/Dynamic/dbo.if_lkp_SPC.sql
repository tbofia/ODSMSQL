IF OBJECT_ID('dbo.if_lkp_SPC', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_lkp_SPC;
GO

CREATE FUNCTION dbo.if_lkp_SPC(
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
	t.lkp_SpcId,
	t.LongName,
	t.ShortName,
	t.Mult,
	t.NCD92,
	t.NCD93,
	t.PlusFour,
	t.CbreSpecialtyCode
FROM src.lkp_SPC t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		lkp_SpcId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.lkp_SPC
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		lkp_SpcId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.lkp_SpcId = s.lkp_SpcId
WHERE t.DmlOperation <> 'D';

GO


