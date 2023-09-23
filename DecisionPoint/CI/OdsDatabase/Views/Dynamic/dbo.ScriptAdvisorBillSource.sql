IF OBJECT_ID('dbo.ScriptAdvisorBillSource', 'V') IS NOT NULL
    DROP VIEW dbo.ScriptAdvisorBillSource;
GO

CREATE VIEW dbo.ScriptAdvisorBillSource
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillSourceId
	,BillSource
FROM src.ScriptAdvisorBillSource
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


