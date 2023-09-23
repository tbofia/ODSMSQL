IF OBJECT_ID('dbo.if_StateSettingsOregonCoverageType', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_StateSettingsOregonCoverageType;
GO

CREATE FUNCTION dbo.if_StateSettingsOregonCoverageType(
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
	t.StateSettingsOregonId,
	t.CoverageType
FROM src.StateSettingsOregonCoverageType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StateSettingsOregonId,
		CoverageType,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingsOregonCoverageType
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StateSettingsOregonId,
		CoverageType) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StateSettingsOregonId = s.StateSettingsOregonId
	AND t.CoverageType = s.CoverageType
WHERE t.DmlOperation <> 'D';

GO


