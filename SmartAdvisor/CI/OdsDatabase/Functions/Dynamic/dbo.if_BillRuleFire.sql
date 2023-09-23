IF OBJECT_ID('dbo.if_BillRuleFire', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillRuleFire;
GO

CREATE FUNCTION dbo.if_BillRuleFire(
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
	t.LineSeq,
	t.RuleID,
	t.RuleType,
	t.DateRuleFired,
	t.Validated,
	t.ValidatedUserID,
	t.DateValidated,
	t.PendToID,
	t.RuleSeverity,
	t.WFTaskSeq,
	t.ChildTargetSubset,
	t.ChildTargetSeq,
	t.CapstoneRuleID
FROM src.BillRuleFire t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		BillSeq,
		LineSeq,
		RuleID,
		ChildTargetSubset,
		ChildTargetSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillRuleFire
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		BillSeq,
		LineSeq,
		RuleID,
		ChildTargetSubset,
		ChildTargetSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.BillSeq = s.BillSeq
	AND t.LineSeq = s.LineSeq
	AND t.RuleID = s.RuleID
	AND t.ChildTargetSubset = s.ChildTargetSubset
	AND t.ChildTargetSeq = s.ChildTargetSeq
WHERE t.DmlOperation <> 'D';

GO


