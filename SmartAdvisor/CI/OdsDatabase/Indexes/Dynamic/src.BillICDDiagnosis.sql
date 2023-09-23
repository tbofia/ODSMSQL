IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.BillICDDiagnosis')
	AND NAME = 'IX_ClientCode_BillSeq_BillDiagnosisSeq_ICDBillUsageTypeID_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_ClientCode_BillSeq_BillDiagnosisSeq_ICDBillUsageTypeID_OdsCustomerId_OdsPostingGroupAuditId 
ON src.BillICDDiagnosis (ClientCode,BillSeq,BillDiagnosisSeq,ICDBillUsageTypeID, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.BillICDDiagnosis')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.BillICDDiagnosis(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (ClientCode,BillSeq,BillDiagnosisSeq,ICDBillUsageTypeID);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.BillICDDiagnosis')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.BillICDDiagnosis(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,ClientCode,BillSeq,BillDiagnosisSeq,ICDBillUsageTypeID);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.BillICDDiagnosis')
	AND NAME = N'IX_OdsPostingGroupAuditId')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId
ON src.BillICDDiagnosis(OdsPostingGroupAuditId)
INCLUDE (OdsCustomerId,OdsRowIsCurrent,OdsHashbytesValue,ClientCode,BillSeq,BillDiagnosisSeq,ICDBillUsageTypeID);
GO


