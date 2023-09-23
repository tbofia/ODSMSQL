IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.UDFViewOrder')
	AND NAME = 'IX_OfficeId_UDFIdNo_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_OfficeId_UDFIdNo_OdsCustomerId_OdsPostingGroupAuditId 
ON src.UDFViewOrder (OfficeId,UDFIdNo, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.UDFViewOrder')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.UDFViewOrder(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (OfficeId,UDFIdNo);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.UDFViewOrder')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.UDFViewOrder(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,OfficeId,UDFIdNo);
GO

