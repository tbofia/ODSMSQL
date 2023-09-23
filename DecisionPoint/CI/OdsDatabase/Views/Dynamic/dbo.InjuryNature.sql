IF OBJECT_ID('dbo.InjuryNature', 'V') IS NOT NULL
    DROP VIEW dbo.InjuryNature;
GO

CREATE VIEW dbo.InjuryNature
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,InjuryNatureId
	,InjuryNaturePriority
	,Description
	,NarrativeInformation
FROM src.InjuryNature
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


