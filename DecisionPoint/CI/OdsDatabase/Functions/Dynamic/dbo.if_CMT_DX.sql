IF OBJECT_ID('dbo.if_CMT_DX', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CMT_DX;
GO

CREATE FUNCTION dbo.if_CMT_DX(
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
	t.DX,
	t.SeqNum,
	t.POA,
	t.IcdVersion
FROM src.CMT_DX t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIDNo,
		DX,
		IcdVersion,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CMT_DX
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIDNo,
		DX,
		IcdVersion) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIDNo = s.BillIDNo
	AND t.DX = s.DX
	AND t.IcdVersion = s.IcdVersion
WHERE t.DmlOperation <> 'D';

GO


