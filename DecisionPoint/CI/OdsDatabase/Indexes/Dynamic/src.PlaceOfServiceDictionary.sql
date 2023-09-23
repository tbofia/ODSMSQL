IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.PlaceOfServiceDictionary')
	AND NAME = 'IX_PlaceOfServiceCode_StartDate_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_PlaceOfServiceCode_StartDate_OdsCustomerId_OdsPostingGroupAuditId 
ON src.PlaceOfServiceDictionary (PlaceOfServiceCode,StartDate, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.PlaceOfServiceDictionary')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.PlaceOfServiceDictionary(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (PlaceOfServiceCode,StartDate);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.PlaceOfServiceDictionary')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.PlaceOfServiceDictionary(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,PlaceOfServiceCode,StartDate);
GO

