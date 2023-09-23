IF OBJECT_ID('dbo.if_CMT_ICD9', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CMT_ICD9;
GO

CREATE FUNCTION dbo.if_CMT_ICD9(
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
	t.BillIDNo,
	t.SeqNo,
	t.ICD9,
	t.IcdVersion
FROM src.CMT_ICD9 t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIDNo,
		SeqNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CMT_ICD9
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIDNo,
		SeqNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIDNo = s.BillIDNo
	AND t.SeqNo = s.SeqNo
WHERE t.DmlOperation <> 'D';

GO


