IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.CMS_Zip2Region')
	AND NAME = 'IX_StartDate_ZIP_Code_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_StartDate_ZIP_Code_OdsCustomerId_OdsPostingGroupAuditId 
ON src.CMS_Zip2Region (StartDate,ZIP_Code, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.CMS_Zip2Region')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.CMS_Zip2Region(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (StartDate,ZIP_Code);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.CMS_Zip2Region')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.CMS_Zip2Region(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,StartDate,ZIP_Code);
GO

