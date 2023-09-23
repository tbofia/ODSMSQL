IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.TreatmentCategoryRange')
	AND NAME = 'IX_TreatmentCategoryRangeId_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_TreatmentCategoryRangeId_OdsCustomerId_OdsPostingGroupAuditId 
ON src.TreatmentCategoryRange (TreatmentCategoryRangeId, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.TreatmentCategoryRange')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.TreatmentCategoryRange(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (TreatmentCategoryRangeId);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.TreatmentCategoryRange')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.TreatmentCategoryRange(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,TreatmentCategoryRangeId);
GO

