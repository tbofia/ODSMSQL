IF OBJECT_ID('dbo.DeductibleRuleCriteria', 'V') IS NOT NULL
    DROP VIEW dbo.DeductibleRuleCriteria;
GO

CREATE VIEW dbo.DeductibleRuleCriteria
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,DeductibleRuleCriteriaId
	,PricingRuleDateCriteriaId
	,StartDate
	,EndDate
FROM src.DeductibleRuleCriteria
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


