IF OBJECT_ID('aw.if_AnalysisRuleThreshold', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_AnalysisRuleThreshold;
GO

CREATE FUNCTION aw.if_AnalysisRuleThreshold(
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
	t.AnalysisRuleThresholdId,
	t.AnalysisRuleId,
	t.ThresholdKey,
	t.ThresholdValue,
	t.CreateDate,
	t.LastChangedOn
FROM src.AnalysisRuleThreshold t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		AnalysisRuleThresholdId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.AnalysisRuleThreshold
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		AnalysisRuleThresholdId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.AnalysisRuleThresholdId = s.AnalysisRuleThresholdId
WHERE t.DmlOperation <> 'D';

GO


