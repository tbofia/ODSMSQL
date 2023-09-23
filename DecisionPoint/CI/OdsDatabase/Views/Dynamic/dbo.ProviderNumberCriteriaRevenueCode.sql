IF OBJECT_ID('dbo.ProviderNumberCriteriaRevenueCode', 'V') IS NOT NULL
    DROP VIEW dbo.ProviderNumberCriteriaRevenueCode;
GO

CREATE VIEW dbo.ProviderNumberCriteriaRevenueCode
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ProviderNumberCriteriaId
	,RevenueCode
	,MatchingProfileNumber
	,AttributeMatchTypeId
FROM src.ProviderNumberCriteriaRevenueCode
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


