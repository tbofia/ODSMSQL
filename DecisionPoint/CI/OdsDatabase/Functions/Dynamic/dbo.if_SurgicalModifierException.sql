IF OBJECT_ID('dbo.if_SurgicalModifierException', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SurgicalModifierException;
GO

CREATE FUNCTION dbo.if_SurgicalModifierException(
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
	t.Modifier,
	t.State,
	t.CoverageType,
	t.StartDate,
	t.EndDate
FROM src.SurgicalModifierException t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Modifier,
		State,
		CoverageType,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SurgicalModifierException
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Modifier,
		State,
		CoverageType,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Modifier = s.Modifier
	AND t.State = s.State
	AND t.CoverageType = s.CoverageType
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D';

GO


