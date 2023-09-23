IF OBJECT_ID('aw.EventLogDetail', 'V') IS NOT NULL
    DROP VIEW aw.EventLogDetail;
GO

CREATE VIEW aw.EventLogDetail
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,EventLogDetailId
	,EventLogId
	,PropertyName
	,OldValue
	,NewValue
FROM src.EventLogDetail
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


