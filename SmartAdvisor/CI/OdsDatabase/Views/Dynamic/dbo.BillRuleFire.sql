IF OBJECT_ID('dbo.BillRuleFire', 'V') IS NOT NULL
    DROP VIEW dbo.BillRuleFire;
GO

CREATE VIEW dbo.BillRuleFire
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClientCode
	,BillSeq
	,LineSeq
	,RuleID
	,RuleType
	,DateRuleFired
	,Validated
	,ValidatedUserID
	,DateValidated
	,PendToID
	,RuleSeverity
	,WFTaskSeq
	,ChildTargetSubset
	,ChildTargetSeq
	,CapstoneRuleID
FROM src.BillRuleFire
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


