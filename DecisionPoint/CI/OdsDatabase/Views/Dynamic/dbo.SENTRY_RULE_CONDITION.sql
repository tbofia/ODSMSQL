IF OBJECT_ID('dbo.SENTRY_RULE_CONDITION', 'V') IS NOT NULL
    DROP VIEW dbo.SENTRY_RULE_CONDITION;
GO

CREATE VIEW dbo.SENTRY_RULE_CONDITION
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,RuleID
	,LineNumber
	,GroupFlag
	,CriteriaID
	,Operator
	,ConditionValue
	,AndOr
	,UdfConditionId
FROM src.SENTRY_RULE_CONDITION
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


