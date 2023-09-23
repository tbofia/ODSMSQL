IF OBJECT_ID('aw.EventLog', 'V') IS NOT NULL
    DROP VIEW aw.EventLog;
GO

CREATE VIEW aw.EventLog
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,EventLogId
	,ObjectName
	,ObjectId
	,UserName
	,LogDate
	,ActionName
	,OrganizationId
FROM src.EventLog
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


