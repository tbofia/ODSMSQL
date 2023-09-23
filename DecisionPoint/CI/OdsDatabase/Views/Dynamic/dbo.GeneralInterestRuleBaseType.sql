IF OBJECT_ID('dbo.GeneralInterestRuleBaseType', 'V') IS NOT NULL
    DROP VIEW dbo.GeneralInterestRuleBaseType;
GO

CREATE VIEW dbo.GeneralInterestRuleBaseType
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
	,GeneralInterestRuleBaseTypeName
FROM src.GeneralInterestRuleBaseType
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


