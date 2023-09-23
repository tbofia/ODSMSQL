IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.Practitioner')
	AND NAME = 'IX_SiteCode_NPI_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_SiteCode_NPI_OdsCustomerId_OdsPostingGroupAuditId 
ON src.Practitioner (SiteCode,NPI, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.Practitioner')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.Practitioner(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (SiteCode,NPI);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.Practitioner')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.Practitioner(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,SiteCode,NPI);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.Practitioner')
	AND NAME = N'IX_OdsPostingGroupAuditId')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId
ON src.Practitioner(OdsPostingGroupAuditId)
INCLUDE (OdsCustomerId,OdsRowIsCurrent,OdsHashbytesValue,SiteCode,NPI);
GO


