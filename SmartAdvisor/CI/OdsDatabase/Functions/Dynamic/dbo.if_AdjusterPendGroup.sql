IF OBJECT_ID('dbo.if_AdjusterPendGroup', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_AdjusterPendGroup;
GO

CREATE FUNCTION dbo.if_AdjusterPendGroup(
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
	t.ClaimSysSubset,
	t.Adjuster,
	t.PendGroupCode
FROM src.AdjusterPendGroup t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimSysSubset,
		Adjuster,
		PendGroupCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.AdjusterPendGroup
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimSysSubset,
		Adjuster,
		PendGroupCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimSysSubset = s.ClaimSysSubset
	AND t.Adjuster = s.Adjuster
	AND t.PendGroupCode = s.PendGroupCode
WHERE t.DmlOperation <> 'D';

GO


