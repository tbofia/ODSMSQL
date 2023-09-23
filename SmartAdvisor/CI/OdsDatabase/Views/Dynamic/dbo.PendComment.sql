IF OBJECT_ID('dbo.PendComment', 'V') IS NOT NULL
    DROP VIEW dbo.PendComment;
GO

CREATE VIEW dbo.PendComment
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
	,PendCommentSeq
	,PendComment
	,CreateUserID
	,CreateDate
	,CreatedByExternalUserName
FROM src.PendComment
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


