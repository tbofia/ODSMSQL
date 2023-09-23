
IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.BillsOverride')
	AND NAME = 'IX_OdsCustomerId_OdsRowIsCurrent_BillIDNo_LINE_NO_DateSaved')

CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent_BillIDNo_LINE_NO_DateSaved
ON src.BillsOverride (OdsCustomerId,OdsRowIsCurrent,BillIDNo,LINE_NO,DateSaved)
INCLUDE (DmlOperation,AmountAfter)
WITH (DATA_COMPRESSION = PAGE);
GO

