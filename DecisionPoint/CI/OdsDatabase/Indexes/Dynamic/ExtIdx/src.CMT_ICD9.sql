IF NOT EXISTS (
SELECT *
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.CMT_ICD9')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent_SeqNo_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent_SeqNo_DmlOperation
ON src.CMT_ICD9 (OdsCustomerId,OdsRowIsCurrent,SeqNo,DmlOperation)
INCLUDE (BillIDNo,ICD9)
GO

