IF OBJECT_ID('dbo.if_BillICD', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillICD;
GO

CREATE FUNCTION dbo.if_BillICD(
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
	t.BillICDSeq,
	t.CodeType,
	t.ICDCode,
	t.CodeDate,
	t.POA
FROM src.BillICD t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		BillSeq,
		BillICDSeq,
		CodeType,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillICD
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		BillSeq,
		BillICDSeq,
		CodeType) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.BillSeq = s.BillSeq
	AND t.BillICDSeq = s.BillICDSeq
	AND t.CodeType = s.CodeType
WHERE t.DmlOperation <> 'D';

GO


