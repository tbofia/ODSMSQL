IF OBJECT_ID('dbo.if_ScriptAdvisorBillSource', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ScriptAdvisorBillSource;
GO

CREATE FUNCTION dbo.if_ScriptAdvisorBillSource(
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
	t.BillSourceId,
	t.BillSource
FROM src.ScriptAdvisorBillSource t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillSourceId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ScriptAdvisorBillSource
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillSourceId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillSourceId = s.BillSourceId
WHERE t.DmlOperation <> 'D';

GO


