IF OBJECT_ID('dbo.ProviderNumberCriteriaTypeOfBill', 'V') IS NOT NULL
    DROP VIEW dbo.ProviderNumberCriteriaTypeOfBill;
GO

CREATE VIEW dbo.ProviderNumberCriteriaTypeOfBill
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
	,TypeOfBill
	,MatchingProfileNumber
	,AttributeMatchTypeId
FROM src.ProviderNumberCriteriaTypeOfBill
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


