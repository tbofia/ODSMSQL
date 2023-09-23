IF OBJECT_ID('dbo.if_Prf_OfficeUDF', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Prf_OfficeUDF;
GO

CREATE FUNCTION dbo.if_Prf_OfficeUDF(
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
	t.OfficeId,
	t.UDFIdNo
FROM src.Prf_OfficeUDF t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		OfficeId,
		UDFIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Prf_OfficeUDF
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		OfficeId,
		UDFIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.OfficeId = s.OfficeId
	AND t.UDFIdNo = s.UDFIdNo
WHERE t.DmlOperation <> 'D';

GO


