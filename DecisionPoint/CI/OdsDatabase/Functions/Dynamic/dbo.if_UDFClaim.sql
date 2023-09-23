IF OBJECT_ID('dbo.if_UDFClaim', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_UDFClaim;
GO

CREATE FUNCTION dbo.if_UDFClaim(
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
	t.ClaimIdNo,
	t.UDFIdNo,
	t.UDFValueText,
	t.UDFValueDecimal,
	t.UDFValueDate
FROM src.UDFClaim t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimIdNo,
		UDFIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UDFClaim
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimIdNo,
		UDFIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimIdNo = s.ClaimIdNo
	AND t.UDFIdNo = s.UDFIdNo
WHERE t.DmlOperation <> 'D';

GO


