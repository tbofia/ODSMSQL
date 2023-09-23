IF OBJECT_ID('dbo.if_ClaimData', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ClaimData;
GO

CREATE FUNCTION dbo.if_ClaimData(
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
	t.ClaimSysSubset,
	t.ClaimSeq,
	t.TypeCode,
	t.SubType,
	t.SubSeq,
	t.NumData,
	t.TextData,
	t.CreateDate,
	t.CreateUserID,
	t.ModDate,
	t.ModUserID
FROM src.ClaimData t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimSysSubset,
		ClaimSeq,
		TypeCode,
		SubType,
		SubSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ClaimData
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimSysSubset,
		ClaimSeq,
		TypeCode,
		SubType,
		SubSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimSysSubset = s.ClaimSysSubset
	AND t.ClaimSeq = s.ClaimSeq
	AND t.TypeCode = s.TypeCode
	AND t.SubType = s.SubType
	AND t.SubSeq = s.SubSeq
WHERE t.DmlOperation <> 'D';

GO


