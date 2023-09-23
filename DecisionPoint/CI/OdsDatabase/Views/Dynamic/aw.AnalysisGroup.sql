IF OBJECT_ID('aw.AnalysisGroup', 'V') IS NOT NULL
    DROP VIEW aw.AnalysisGroup;
GO

CREATE VIEW aw.AnalysisGroup
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,AnalysisGroupId
	,GroupName
FROM src.AnalysisGroup
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


