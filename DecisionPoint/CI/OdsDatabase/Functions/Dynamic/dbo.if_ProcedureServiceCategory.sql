IF OBJECT_ID('dbo.if_ProcedureServiceCategory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ProcedureServiceCategory;
GO

CREATE FUNCTION dbo.if_ProcedureServiceCategory(
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
	t.ProcedureServiceCategoryId,
	t.ProcedureServiceCategoryName,
	t.ProcedureServiceCategoryDescription,
	t.LegacyTableName,
	t.LegacyBitValue
FROM src.ProcedureServiceCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProcedureServiceCategoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProcedureServiceCategory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProcedureServiceCategoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProcedureServiceCategoryId = s.ProcedureServiceCategoryId
WHERE t.DmlOperation <> 'D';

GO


