IF OBJECT_ID('dbo.if_ModifierToProcedureCode', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ModifierToProcedureCode;
GO

CREATE FUNCTION dbo.if_ModifierToProcedureCode(
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
	t.ProcedureCode,
	t.Modifier,
	t.StartDate,
	t.EndDate,
	t.SojFlag,
	t.RequiresGuidelineReview,
	t.Reference,
	t.Comments
FROM src.ModifierToProcedureCode t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProcedureCode,
		Modifier,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ModifierToProcedureCode
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProcedureCode,
		Modifier,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProcedureCode = s.ProcedureCode
	AND t.Modifier = s.Modifier
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D';

GO


