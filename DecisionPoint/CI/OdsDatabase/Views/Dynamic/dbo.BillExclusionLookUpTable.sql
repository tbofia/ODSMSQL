IF OBJECT_ID('dbo.BillExclusionLookUpTable', 'V') IS NOT NULL
    DROP VIEW dbo.BillExclusionLookUpTable;
GO

CREATE VIEW dbo.BillExclusionLookUpTable
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ReportID
	,ReportName
FROM src.BillExclusionLookUpTable
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


