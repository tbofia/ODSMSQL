IF OBJECT_ID('dbo.if_BillData', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillData;
GO

CREATE FUNCTION dbo.if_BillData(
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
	t.ClientCode,
	t.BillSeq,
	t.TypeCode,
	t.SubType,
	t.SubSeq,
	t.NumData,
	t.TextData,
	t.ModDate,
	t.ModUserID,
	t.CreateDate,
	t.CreateUserID
FROM src.BillData t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		BillSeq,
		TypeCode,
		SubType,
		SubSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillData
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		BillSeq,
		TypeCode,
		SubType,
		SubSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.BillSeq = s.BillSeq
	AND t.TypeCode = s.TypeCode
	AND t.SubType = s.SubType
	AND t.SubSeq = s.SubSeq
WHERE t.DmlOperation <> 'D';

GO


