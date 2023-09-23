IF OBJECT_ID('dbo.WFlow', 'V') IS NOT NULL
    DROP VIEW dbo.WFlow;
GO

CREATE VIEW dbo.WFlow
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,WFlowSeq
	,Description
	,RecordStatus
	,EntityTypeCode
	,CreateUserID
	,CreateDate
	,ModUserID
	,ModDate
	,InitialTaskSeq
	,PauseTaskSeq
FROM src.WFlow
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


