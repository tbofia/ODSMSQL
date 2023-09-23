IF OBJECT_ID('dbo.SentryRuleTypeCriteria', 'V') IS NOT NULL
    DROP VIEW dbo.SentryRuleTypeCriteria;
GO

CREATE VIEW dbo.SentryRuleTypeCriteria
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,RuleTypeId
	,CriteriaId
FROM src.SentryRuleTypeCriteria
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


