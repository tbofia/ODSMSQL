IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.CriticalAccessHospitalInpatientRevenueCode')
	AND NAME = 'IX_RevenueCode_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_RevenueCode_OdsCustomerId_OdsPostingGroupAuditId 
ON src.CriticalAccessHospitalInpatientRevenueCode (RevenueCode, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.CriticalAccessHospitalInpatientRevenueCode')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.CriticalAccessHospitalInpatientRevenueCode(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (RevenueCode);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.CriticalAccessHospitalInpatientRevenueCode')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.CriticalAccessHospitalInpatientRevenueCode(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,RevenueCode);
GO

