IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.DemandPackageRequestedService')
	AND NAME = 'IX_DemandPackageRequestedServiceId_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_DemandPackageRequestedServiceId_OdsCustomerId_OdsPostingGroupAuditId 
ON src.DemandPackageRequestedService (DemandPackageRequestedServiceId, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.DemandPackageRequestedService')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.DemandPackageRequestedService(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (DemandPackageRequestedServiceId);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.DemandPackageRequestedService')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.DemandPackageRequestedService(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,DemandPackageRequestedServiceId);
GO

