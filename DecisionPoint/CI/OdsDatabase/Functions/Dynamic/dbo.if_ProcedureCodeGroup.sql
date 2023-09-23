IF OBJECT_ID('dbo.if_ProcedureCodeGroup', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ProcedureCodeGroup;
GO

CREATE FUNCTION dbo.if_ProcedureCodeGroup(
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
	t.MajorCategory,
	t.MinorCategory
FROM src.ProcedureCodeGroup t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProcedureCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProcedureCodeGroup
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProcedureCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProcedureCode = s.ProcedureCode
WHERE t.DmlOperation <> 'D';

GO


