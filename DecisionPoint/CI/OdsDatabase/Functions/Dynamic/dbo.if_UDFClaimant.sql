IF OBJECT_ID('dbo.if_UDFClaimant', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_UDFClaimant;
GO

CREATE FUNCTION dbo.if_UDFClaimant(
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
	t.CmtIdNo,
	t.UDFIdNo,
	t.UDFValueText,
	t.UDFValueDecimal,
	t.UDFValueDate
FROM src.UDFClaimant t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CmtIdNo,
		UDFIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UDFClaimant
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CmtIdNo,
		UDFIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CmtIdNo = s.CmtIdNo
	AND t.UDFIdNo = s.UDFIdNo
WHERE t.DmlOperation <> 'D';

GO


