IF OBJECT_ID('dbo.if_UDFListValues', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_UDFListValues;
GO

CREATE FUNCTION dbo.if_UDFListValues(
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
	t.ListValueIdNo,
	t.UDFIdNo,
	t.SeqNo,
	t.ListValue,
	t.DefaultValue
FROM src.UDFListValues t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ListValueIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UDFListValues
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ListValueIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ListValueIdNo = s.ListValueIdNo
WHERE t.DmlOperation <> 'D';

GO


