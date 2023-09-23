IF OBJECT_ID('dbo.if_BillICDProcedure', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillICDProcedure;
GO

CREATE FUNCTION dbo.if_BillICDProcedure(
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
	t.BillProcedureSeq,
	t.ICDProcedureID,
	t.CodeDate,
	t.BilledICDProcedure,
	t.ICDBillUsageTypeID
FROM src.BillICDProcedure t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		BillSeq,
		BillProcedureSeq,
		ICDBillUsageTypeID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillICDProcedure
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		BillSeq,
		BillProcedureSeq,
		ICDBillUsageTypeID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.BillSeq = s.BillSeq
	AND t.BillProcedureSeq = s.BillProcedureSeq
	AND t.ICDBillUsageTypeID = s.ICDBillUsageTypeID
WHERE t.DmlOperation <> 'D';

GO


