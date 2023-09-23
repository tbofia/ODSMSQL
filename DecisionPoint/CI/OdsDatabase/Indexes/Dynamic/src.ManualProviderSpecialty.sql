IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.ManualProviderSpecialty')
	AND NAME = 'IX_ManualProviderId_Specialty_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_ManualProviderId_Specialty_OdsCustomerId_OdsPostingGroupAuditId 
ON src.ManualProviderSpecialty (ManualProviderId,Specialty, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.ManualProviderSpecialty')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.ManualProviderSpecialty(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (ManualProviderId,Specialty);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.ManualProviderSpecialty')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.ManualProviderSpecialty(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,ManualProviderId,Specialty);
GO

