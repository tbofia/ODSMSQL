IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.CbreToDpEndnoteMapping')
	AND NAME = 'IX_Endnote_EndnoteTypeId_CbreEndnote_PricingState_PricingMethodId_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_Endnote_EndnoteTypeId_CbreEndnote_PricingState_PricingMethodId_OdsCustomerId_OdsPostingGroupAuditId 
ON src.CbreToDpEndnoteMapping (Endnote,EndnoteTypeId,CbreEndnote,PricingState,PricingMethodId, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.CbreToDpEndnoteMapping')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.CbreToDpEndnoteMapping(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (Endnote,EndnoteTypeId,CbreEndnote,PricingState,PricingMethodId);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.CbreToDpEndnoteMapping')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.CbreToDpEndnoteMapping(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,Endnote,EndnoteTypeId,CbreEndnote,PricingState,PricingMethodId);
GO

