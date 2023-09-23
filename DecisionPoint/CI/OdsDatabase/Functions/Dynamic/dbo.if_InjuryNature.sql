IF OBJECT_ID('dbo.if_InjuryNature', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_InjuryNature;
GO

CREATE FUNCTION dbo.if_InjuryNature(
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
	t.InjuryNatureId,
	t.InjuryNaturePriority,
	t.Description,
	t.NarrativeInformation
FROM src.InjuryNature t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		InjuryNatureId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.InjuryNature
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		InjuryNatureId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.InjuryNatureId = s.InjuryNatureId
WHERE t.DmlOperation <> 'D';

GO


