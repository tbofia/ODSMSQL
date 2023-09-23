IF OBJECT_ID('dbo.if_EncounterType', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_EncounterType;
GO

CREATE FUNCTION dbo.if_EncounterType(
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
	t.EncounterTypeId,
	t.EncounterTypePriority,
	t.Description,
	t.NarrativeInformation
FROM src.EncounterType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		EncounterTypeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EncounterType
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		EncounterTypeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.EncounterTypeId = s.EncounterTypeId
WHERE t.DmlOperation <> 'D';

GO


