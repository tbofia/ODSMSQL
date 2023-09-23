IF OBJECT_ID('aw.if_AnalysisRule', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_AnalysisRule;
GO

CREATE FUNCTION aw.if_AnalysisRule(
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
	t.AnalysisRuleId,
	t.Title,
	t.AssemblyQualifiedName,
	t.MethodToInvoke,
	t.DisplayMessage,
	t.DisplayOrder,
	t.IsActive,
	t.CreateDate,
	t.LastChangedOn,
	t.MessageToken
FROM src.AnalysisRule t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		AnalysisRuleId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.AnalysisRule
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		AnalysisRuleId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.AnalysisRuleId = s.AnalysisRuleId
WHERE t.DmlOperation <> 'D';

GO


