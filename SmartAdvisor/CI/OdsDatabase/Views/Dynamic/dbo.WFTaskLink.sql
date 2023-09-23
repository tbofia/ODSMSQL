IF OBJECT_ID('dbo.WFTaskLink', 'V') IS NOT NULL
    DROP VIEW dbo.WFTaskLink;
GO

CREATE VIEW dbo.WFTaskLink
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,FromTaskSeq
	,LinkWhen
	,ToTaskSeq
FROM src.WFTaskLink
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


