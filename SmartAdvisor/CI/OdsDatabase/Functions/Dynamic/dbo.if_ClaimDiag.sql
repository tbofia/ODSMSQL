IF OBJECT_ID('dbo.if_ClaimDiag', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ClaimDiag;
GO

CREATE FUNCTION dbo.if_ClaimDiag(
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
	t.ClaimSysSubSet,
	t.ClaimSeq,
	t.ClaimDiagSeq,
	t.DiagCode
FROM src.ClaimDiag t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimSysSubSet,
		ClaimSeq,
		ClaimDiagSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ClaimDiag
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimSysSubSet,
		ClaimSeq,
		ClaimDiagSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimSysSubSet = s.ClaimSysSubSet
	AND t.ClaimSeq = s.ClaimSeq
	AND t.ClaimDiagSeq = s.ClaimDiagSeq
WHERE t.DmlOperation <> 'D';

GO


