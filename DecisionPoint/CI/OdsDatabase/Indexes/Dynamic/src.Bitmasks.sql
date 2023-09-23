IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.Bitmasks')
	AND NAME = 'IX_TableProgramUsed_AttributeUsed_Decimal_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_TableProgramUsed_AttributeUsed_Decimal_OdsCustomerId_OdsPostingGroupAuditId 
ON src.Bitmasks (TableProgramUsed,AttributeUsed,Decimal, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.Bitmasks')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.Bitmasks(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (TableProgramUsed,AttributeUsed,Decimal);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.Bitmasks')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.Bitmasks(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,TableProgramUsed,AttributeUsed,Decimal);
GO

