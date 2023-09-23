IF OBJECT_ID('dbo.if_WFlow', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_WFlow;
GO

CREATE FUNCTION dbo.if_WFlow(
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
	t.WFlowSeq,
	t.Description,
	t.RecordStatus,
	t.EntityTypeCode,
	t.CreateUserID,
	t.CreateDate,
	t.ModUserID,
	t.ModDate,
	t.InitialTaskSeq,
	t.PauseTaskSeq
FROM src.WFlow t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		WFlowSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.WFlow
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		WFlowSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.WFlowSeq = s.WFlowSeq
WHERE t.DmlOperation <> 'D';

GO


