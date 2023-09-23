IF OBJECT_ID('dbo.if_UDFProvider', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_UDFProvider;
GO

CREATE FUNCTION dbo.if_UDFProvider(
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
	t.PvdIdNo,
	t.UDFIdNo,
	t.UDFValueText,
	t.UDFValueDecimal,
	t.UDFValueDate
FROM src.UDFProvider t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PvdIdNo,
		UDFIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UDFProvider
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PvdIdNo,
		UDFIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PvdIdNo = s.PvdIdNo
	AND t.UDFIdNo = s.UDFIdNo
WHERE t.DmlOperation <> 'D';

GO


