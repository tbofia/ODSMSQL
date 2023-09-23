IF OBJECT_ID('aw.if_AnalysisGroup', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_AnalysisGroup;
GO

CREATE FUNCTION aw.if_AnalysisGroup(
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
	t.AnalysisGroupId,
	t.GroupName
FROM src.AnalysisGroup t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		AnalysisGroupId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.AnalysisGroup
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		AnalysisGroupId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.AnalysisGroupId = s.AnalysisGroupId
WHERE t.DmlOperation <> 'D';

GO


