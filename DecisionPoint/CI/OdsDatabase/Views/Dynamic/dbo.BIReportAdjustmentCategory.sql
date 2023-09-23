IF OBJECT_ID('dbo.BIReportAdjustmentCategory', 'V') IS NOT NULL
    DROP VIEW dbo.BIReportAdjustmentCategory;
GO

CREATE VIEW dbo.BIReportAdjustmentCategory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BIReportAdjustmentCategoryId
	,Name
	,Description
	,DisplayPriority
FROM src.BIReportAdjustmentCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


