IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.BIReportAdjustmentCategoryMapping')
	AND NAME = 'IX_BIReportAdjustmentCategoryId_Adjustment360SubCategoryId_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_BIReportAdjustmentCategoryId_Adjustment360SubCategoryId_OdsCustomerId_OdsPostingGroupAuditId 
ON src.BIReportAdjustmentCategoryMapping (BIReportAdjustmentCategoryId,Adjustment360SubCategoryId, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.BIReportAdjustmentCategoryMapping')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.BIReportAdjustmentCategoryMapping(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (BIReportAdjustmentCategoryId,Adjustment360SubCategoryId);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.BIReportAdjustmentCategoryMapping')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.BIReportAdjustmentCategoryMapping(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,BIReportAdjustmentCategoryId,Adjustment360SubCategoryId);
GO

