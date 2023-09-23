IF OBJECT_ID('dbo.GeneralInterestRuleSetting', 'V') IS NOT NULL
    DROP VIEW dbo.GeneralInterestRuleSetting;
GO

CREATE VIEW dbo.GeneralInterestRuleSetting
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,GeneralInterestRuleBaseTypeId
FROM src.GeneralInterestRuleSetting
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


