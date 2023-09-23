IF OBJECT_ID('dbo.WFQueue', 'V') IS NOT NULL
    DROP VIEW dbo.WFQueue;
GO

CREATE VIEW dbo.WFQueue
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,EntityTypeCode
	,EntitySubset
	,EntitySeq
	,WFTaskSeq
	,PriorWFTaskSeq
	,Status
	,Priority
	,CreateUserID
	,CreateDate
	,ModUserID
	,ModDate
	,TaskMessage
	,Parameter1
	,ContextID
	,PriorStatus
FROM src.WFQueue
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


