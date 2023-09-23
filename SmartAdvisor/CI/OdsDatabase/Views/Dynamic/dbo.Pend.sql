IF OBJECT_ID('dbo.Pend', 'V') IS NOT NULL
    DROP VIEW dbo.Pend;
GO

CREATE VIEW dbo.Pend
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClientCode
	,BillSeq
	,PendSeq
	,PendDate
	,ReleaseFlag
	,PendToID
	,Priority
	,ReleaseDate
	,ReasonCode
	,PendByUserID
	,ReleaseByUserID
	,AutoPendFlag
	,RuleID
	,WFTaskSeq
	,ReleasedByExternalUserName
FROM src.Pend
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


