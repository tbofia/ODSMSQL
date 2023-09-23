IF OBJECT_ID('dbo.if_UdfDataFormat', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_UdfDataFormat;
GO

CREATE FUNCTION dbo.if_UdfDataFormat(
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
	t.UdfDataFormatId,
	t.DataFormatName
FROM src.UdfDataFormat t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		UdfDataFormatId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UdfDataFormat
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		UdfDataFormatId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.UdfDataFormatId = s.UdfDataFormatId
WHERE t.DmlOperation <> 'D';

GO


