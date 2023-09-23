IF OBJECT_ID('dbo.if_rsn_REASONS', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_rsn_REASONS;
GO

CREATE FUNCTION dbo.if_rsn_REASONS(
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
	t.ReasonNumber,
	t.CV_Type,
	t.ShortDesc,
	t.LongDesc,
	t.CategoryIdNo,
	t.COAIndex,
	t.OverrideEndnote,
	t.HardEdit,
	t.SpecialProcessing,
	t.EndnoteActionId,
	t.RetainForEapg
FROM src.rsn_REASONS t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReasonNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.rsn_REASONS
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReasonNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReasonNumber = s.ReasonNumber
WHERE t.DmlOperation <> 'D';

GO


