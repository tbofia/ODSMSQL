IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.SupplementPreCtgDeniedLinesEligibleToPenalty')
	AND NAME = 'IX_BillIdNo_LineNumber_CtgPenaltyTypeId_SeqNo_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_BillIdNo_LineNumber_CtgPenaltyTypeId_SeqNo_OdsCustomerId_OdsPostingGroupAuditId 
ON src.SupplementPreCtgDeniedLinesEligibleToPenalty (BillIdNo,LineNumber,CtgPenaltyTypeId,SeqNo, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.SupplementPreCtgDeniedLinesEligibleToPenalty')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.SupplementPreCtgDeniedLinesEligibleToPenalty(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (BillIdNo,LineNumber,CtgPenaltyTypeId,SeqNo);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.SupplementPreCtgDeniedLinesEligibleToPenalty')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.SupplementPreCtgDeniedLinesEligibleToPenalty(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,BillIdNo,LineNumber,CtgPenaltyTypeId,SeqNo);
GO

