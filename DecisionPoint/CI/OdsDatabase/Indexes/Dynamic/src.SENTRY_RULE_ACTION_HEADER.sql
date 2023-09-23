IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.SENTRY_RULE_ACTION_HEADER')
	AND NAME = 'IX_RuleID_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_RuleID_OdsCustomerId_OdsPostingGroupAuditId 
ON src.SENTRY_RULE_ACTION_HEADER (RuleID, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.SENTRY_RULE_ACTION_HEADER')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.SENTRY_RULE_ACTION_HEADER(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (RuleID);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.SENTRY_RULE_ACTION_HEADER')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.SENTRY_RULE_ACTION_HEADER(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,RuleID);
GO

