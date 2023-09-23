IF OBJECT_ID('dbo.Prf_CustomIcdAction', 'V') IS NOT NULL
    DROP VIEW dbo.Prf_CustomIcdAction;
GO

CREATE VIEW dbo.Prf_CustomIcdAction
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CustomIcdActionId
	,ProfileId
	,IcdVersionId
	,Action
	,StartDate
	,EndDate
FROM src.Prf_CustomIcdAction
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


