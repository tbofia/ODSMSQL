IF OBJECT_ID('dbo.DeductibleRuleCriteriaCoverageType', 'V') IS NOT NULL
    DROP VIEW dbo.DeductibleRuleCriteriaCoverageType;
GO

CREATE VIEW dbo.DeductibleRuleCriteriaCoverageType
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
	,CoverageType
FROM src.DeductibleRuleCriteriaCoverageType
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


