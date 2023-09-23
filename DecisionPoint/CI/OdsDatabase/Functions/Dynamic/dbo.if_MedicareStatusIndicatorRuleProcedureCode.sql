IF OBJECT_ID('dbo.if_MedicareStatusIndicatorRuleProcedureCode', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_MedicareStatusIndicatorRuleProcedureCode;
GO

CREATE FUNCTION dbo.if_MedicareStatusIndicatorRuleProcedureCode(
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
	t.MedicareStatusIndicatorRuleId,
	t.ProcedureCode
FROM src.MedicareStatusIndicatorRuleProcedureCode t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		ProcedureCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.MedicareStatusIndicatorRuleProcedureCode
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		ProcedureCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.MedicareStatusIndicatorRuleId = s.MedicareStatusIndicatorRuleId
	AND t.ProcedureCode = s.ProcedureCode
WHERE t.DmlOperation <> 'D';

GO


