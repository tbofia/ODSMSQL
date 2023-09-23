IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.Adjustment3rdPartyEndnoteSubCategory')
	AND NAME = 'IX_ReasonNumber_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_ReasonNumber_OdsCustomerId_OdsPostingGroupAuditId 
ON src.Adjustment3rdPartyEndnoteSubCategory (ReasonNumber, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.Adjustment3rdPartyEndnoteSubCategory')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.Adjustment3rdPartyEndnoteSubCategory(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (ReasonNumber);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.Adjustment3rdPartyEndnoteSubCategory')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.Adjustment3rdPartyEndnoteSubCategory(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,ReasonNumber);
GO

