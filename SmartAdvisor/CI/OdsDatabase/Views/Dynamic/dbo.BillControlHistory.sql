IF OBJECT_ID('dbo.BillControlHistory', 'V') IS NOT NULL
    DROP VIEW dbo.BillControlHistory;
GO

CREATE VIEW dbo.BillControlHistory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillControlHistorySeq
	,ClientCode
	,BillSeq
	,BillControlSeq
	,CreateDate
	,Control
	,ExternalID
	,EDIBatchLogSeq
	,Deleted
	,ModUserID
	,ExternalID2
	,Message
FROM src.BillControlHistory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


