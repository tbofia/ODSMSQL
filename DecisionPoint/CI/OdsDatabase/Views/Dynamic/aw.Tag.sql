IF OBJECT_ID('aw.Tag', 'V') IS NOT NULL
    DROP VIEW aw.Tag;
GO

CREATE VIEW aw.Tag
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,TagId
	,NAME
	,DateCreated
	,DateModified
	,CreatedBy
	,ModifiedBy
FROM src.Tag
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


