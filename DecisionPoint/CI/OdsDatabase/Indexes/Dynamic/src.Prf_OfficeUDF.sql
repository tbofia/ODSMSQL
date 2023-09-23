IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.Prf_OfficeUDF')
	AND NAME = 'IX_OfficeId_UDFIdNo_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_OfficeId_UDFIdNo_OdsCustomerId_OdsPostingGroupAuditId 
ON src.Prf_OfficeUDF (OfficeId,UDFIdNo, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.Prf_OfficeUDF')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.Prf_OfficeUDF(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (OfficeId,UDFIdNo);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.Prf_OfficeUDF')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.Prf_OfficeUDF(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,OfficeId,UDFIdNo);
GO

