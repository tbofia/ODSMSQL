IF OBJECT_ID('dbo.BIReportAdjustmentCategoryMapping', 'V') IS NOT NULL
    DROP VIEW dbo.BIReportAdjustmentCategoryMapping;
GO

CREATE VIEW dbo.BIReportAdjustmentCategoryMapping
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
	,Adjustment360SubCategoryId
FROM src.BIReportAdjustmentCategoryMapping
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


