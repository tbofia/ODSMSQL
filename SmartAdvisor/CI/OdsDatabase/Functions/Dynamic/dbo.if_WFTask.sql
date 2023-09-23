IF OBJECT_ID('dbo.if_WFTask', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_WFTask;
GO

CREATE FUNCTION dbo.if_WFTask(
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
	t.WFTaskSeq,
	t.WFLowSeq,
	t.WFTaskRegistrySeq,
	t.Name,
	t.Parameter1,
	t.RecordStatus,
	t.NodeLeft,
	t.NodeTop,
	t.CreateUserID,
	t.CreateDate,
	t.ModUserID,
	t.ModDate,
	t.NoPrior,
	t.NoRestart,
	t.ParameterX,
	t.DefaultPendGroup,
	t.Configuration
FROM src.WFTask t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		WFTaskSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.WFTask
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		WFTaskSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.WFTaskSeq = s.WFTaskSeq
WHERE t.DmlOperation <> 'D';

GO


