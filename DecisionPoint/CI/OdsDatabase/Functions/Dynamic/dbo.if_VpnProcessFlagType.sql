IF OBJECT_ID('dbo.if_VpnProcessFlagType', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_VpnProcessFlagType;
GO

CREATE FUNCTION dbo.if_VpnProcessFlagType(
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
	t.VpnProcessFlagTypeId,
	t.VpnProcessFlagType
FROM src.VpnProcessFlagType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		VpnProcessFlagTypeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.VpnProcessFlagType
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		VpnProcessFlagTypeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.VpnProcessFlagTypeId = s.VpnProcessFlagTypeId
WHERE t.DmlOperation <> 'D';

GO


