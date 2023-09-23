IF OBJECT_ID('dbo.if_ClaimSysData', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ClaimSysData;
GO

CREATE FUNCTION dbo.if_ClaimSysData(
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
	t.TypeCode,
	t.SubType,
	t.SubSeq,
	t.NumData,
	t.TextData
FROM src.ClaimSysData t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimSysSubset,
		TypeCode,
		SubType,
		SubSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ClaimSysData
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimSysSubset,
		TypeCode,
		SubType,
		SubSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimSysSubset = s.ClaimSysSubset
	AND t.TypeCode = s.TypeCode
	AND t.SubType = s.SubType
	AND t.SubSeq = s.SubSeq
WHERE t.DmlOperation <> 'D';

GO


