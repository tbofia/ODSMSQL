IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.Bills_Pharm_CTG_Endnotes')
	AND NAME = 'IX_BillIDNo_LINE_NO_EndNote_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_BillIDNo_LINE_NO_EndNote_OdsCustomerId_OdsPostingGroupAuditId 
ON src.Bills_Pharm_CTG_Endnotes (BillIDNo,LINE_NO,EndNote, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.Bills_Pharm_CTG_Endnotes')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.Bills_Pharm_CTG_Endnotes(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (BillIDNo,LINE_NO,EndNote);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.Bills_Pharm_CTG_Endnotes')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.Bills_Pharm_CTG_Endnotes(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,BillIDNo,LINE_NO,EndNote);
GO

