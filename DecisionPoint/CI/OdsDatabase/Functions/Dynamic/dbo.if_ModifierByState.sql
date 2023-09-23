IF OBJECT_ID('dbo.if_ModifierByState', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ModifierByState;
GO

CREATE FUNCTION dbo.if_ModifierByState(
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
	t.State,
	t.ProcedureServiceCategoryId,
	t.ModifierDictionaryId
FROM src.ModifierByState t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		State,
		ProcedureServiceCategoryId,
		ModifierDictionaryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ModifierByState
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		State,
		ProcedureServiceCategoryId,
		ModifierDictionaryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.State = s.State
	AND t.ProcedureServiceCategoryId = s.ProcedureServiceCategoryId
	AND t.ModifierDictionaryId = s.ModifierDictionaryId
WHERE t.DmlOperation <> 'D';

GO


