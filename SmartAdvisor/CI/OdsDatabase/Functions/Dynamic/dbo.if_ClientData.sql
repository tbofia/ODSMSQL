IF OBJECT_ID('dbo.if_ClientData', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ClientData;
GO

CREATE FUNCTION dbo.if_ClientData(
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
	t.TypeCode,
	t.SubType,
	t.SubSeq,
	t.NumData,
	t.TextData,
	t.CreateDate,
	t.CreateUserID,
	t.ModDate,
	t.ModUserID
FROM src.ClientData t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		TypeCode,
		SubType,
		SubSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ClientData
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		TypeCode,
		SubType,
		SubSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.TypeCode = s.TypeCode
	AND t.SubType = s.SubType
	AND t.SubSeq = s.SubSeq
WHERE t.DmlOperation <> 'D';

GO


