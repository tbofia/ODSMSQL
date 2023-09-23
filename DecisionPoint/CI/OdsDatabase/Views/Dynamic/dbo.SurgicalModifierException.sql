IF OBJECT_ID('dbo.SurgicalModifierException', 'V') IS NOT NULL
    DROP VIEW dbo.SurgicalModifierException;
GO

CREATE VIEW dbo.SurgicalModifierException
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,Modifier
	,State
	,CoverageType
	,StartDate
	,EndDate
FROM src.SurgicalModifierException
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


