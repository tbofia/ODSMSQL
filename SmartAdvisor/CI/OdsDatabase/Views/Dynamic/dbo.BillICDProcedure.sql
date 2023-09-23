IF OBJECT_ID('dbo.BillICDProcedure', 'V') IS NOT NULL
    DROP VIEW dbo.BillICDProcedure;
GO

CREATE VIEW dbo.BillICDProcedure
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
	,BillProcedureSeq
	,ICDProcedureID
	,CodeDate
	,BilledICDProcedure
	,ICDBillUsageTypeID
FROM src.BillICDProcedure
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


