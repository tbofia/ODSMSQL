IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.PolicyInsurer')
	AND NAME = 'IX_ClaimSysSubset_PolicySeq_Jurisdiction_InsurerType_EffectiveDate_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_ClaimSysSubset_PolicySeq_Jurisdiction_InsurerType_EffectiveDate_OdsCustomerId_OdsPostingGroupAuditId 
ON src.PolicyInsurer (ClaimSysSubset,PolicySeq,Jurisdiction,InsurerType,EffectiveDate, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.PolicyInsurer')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.PolicyInsurer(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (ClaimSysSubset,PolicySeq,Jurisdiction,InsurerType,EffectiveDate);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.PolicyInsurer')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.PolicyInsurer(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,ClaimSysSubset,PolicySeq,Jurisdiction,InsurerType,EffectiveDate);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.PolicyInsurer')
	AND NAME = N'IX_OdsPostingGroupAuditId')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId
ON src.PolicyInsurer(OdsPostingGroupAuditId)
INCLUDE (OdsCustomerId,OdsRowIsCurrent,OdsHashbytesValue,ClaimSysSubset,PolicySeq,Jurisdiction,InsurerType,EffectiveDate);
GO


