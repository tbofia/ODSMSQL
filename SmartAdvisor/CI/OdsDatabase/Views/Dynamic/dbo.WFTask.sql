IF OBJECT_ID('dbo.WFTask', 'V') IS NOT NULL
    DROP VIEW dbo.WFTask;
GO

CREATE VIEW dbo.WFTask
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,WFTaskSeq
	,WFLowSeq
	,WFTaskRegistrySeq
	,Name
	,Parameter1
	,RecordStatus
	,NodeLeft
	,NodeTop
	,CreateUserID
	,CreateDate
	,ModUserID
	,ModDate
	,NoPrior
	,NoRestart
	,ParameterX
	,DefaultPendGroup
	,Configuration
FROM src.WFTask
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


