IF OBJECT_ID('dbo.if_ICD10ProcedureCode', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ICD10ProcedureCode;
GO

CREATE FUNCTION dbo.if_ICD10ProcedureCode(
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
	t.ICDProcedureCode,
	t.StartDate,
	t.EndDate,
	t.Description,
	t.PASGrpNo
FROM src.ICD10ProcedureCode t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ICDProcedureCode,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ICD10ProcedureCode
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ICDProcedureCode,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ICDProcedureCode = s.ICDProcedureCode
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D';

GO


