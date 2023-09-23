IF OBJECT_ID('dbo.CustomerBillExclusion', 'V') IS NOT NULL
    DROP VIEW dbo.CustomerBillExclusion;
GO

CREATE VIEW dbo.CustomerBillExclusion
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillIdNo
	,Customer
	,ReportID
	,CreateDate
FROM src.CustomerBillExclusion
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


