IF NOT EXISTS (
SELECT *
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.Bill_Payment_Adjustments')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent_DmlOperation
ON src.Bill_Payment_Adjustments (OdsCustomerId,OdsRowIsCurrent,DmlOperation)
INCLUDE (BillIDNo,SeqNo,Interest)
GO
