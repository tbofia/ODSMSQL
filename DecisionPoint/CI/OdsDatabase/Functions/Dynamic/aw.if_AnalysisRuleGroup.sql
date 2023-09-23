IF OBJECT_ID('aw.if_AnalysisRuleGroup', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_AnalysisRuleGroup;
GO

CREATE FUNCTION aw.if_AnalysisRuleGroup(
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
	t.AnalysisRuleGroupId,
	t.AnalysisRuleId,
	t.AnalysisGroupId
FROM src.AnalysisRuleGroup t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		AnalysisRuleGroupId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.AnalysisRuleGroup
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		AnalysisRuleGroupId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.AnalysisRuleGroupId = s.AnalysisRuleGroupId
WHERE t.DmlOperation <> 'D';

GO


