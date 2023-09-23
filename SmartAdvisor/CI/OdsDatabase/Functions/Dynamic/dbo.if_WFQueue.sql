IF OBJECT_ID('dbo.if_WFQueue', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_WFQueue;
GO

CREATE FUNCTION dbo.if_WFQueue(
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
	t.EntityTypeCode,
	t.EntitySubset,
	t.EntitySeq,
	t.WFTaskSeq,
	t.PriorWFTaskSeq,
	t.Status,
	t.Priority,
	t.CreateUserID,
	t.CreateDate,
	t.ModUserID,
	t.ModDate,
	t.TaskMessage,
	t.Parameter1,
	t.ContextID,
	t.PriorStatus
FROM src.WFQueue t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		EntityTypeCode,
		EntitySubset,
		EntitySeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.WFQueue
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		EntityTypeCode,
		EntitySubset,
		EntitySeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.EntityTypeCode = s.EntityTypeCode
	AND t.EntitySubset = s.EntitySubset
	AND t.EntitySeq = s.EntitySeq
WHERE t.DmlOperation <> 'D';

GO


