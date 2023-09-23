IF OBJECT_ID('dbo.AdjusterPendGroup', 'V') IS NOT NULL
    DROP VIEW dbo.AdjusterPendGroup;
GO

CREATE VIEW dbo.AdjusterPendGroup
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClaimSysSubset
	,Adjuster
	,PendGroupCode
FROM src.AdjusterPendGroup
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


