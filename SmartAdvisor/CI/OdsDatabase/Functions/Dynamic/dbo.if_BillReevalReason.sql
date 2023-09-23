IF OBJECT_ID('dbo.if_BillReevalReason', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillReevalReason;
GO

CREATE FUNCTION dbo.if_BillReevalReason(
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
	t.BillReevalReasonCode,
	t.SiteCode,
	t.BillReevalReasonCategorySeq,
	t.ShortDescription,
	t.LongDescription,
	t.Active,
	t.CreateDate,
	t.CreateUserID,
	t.ModDate,
	t.ModUserID
FROM src.BillReevalReason t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillReevalReasonCode,
		SiteCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillReevalReason
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillReevalReasonCode,
		SiteCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillReevalReasonCode = s.BillReevalReasonCode
	AND t.SiteCode = s.SiteCode
WHERE t.DmlOperation <> 'D';

GO


