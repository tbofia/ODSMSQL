IF NOT EXISTS (
SELECT *
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.BILLS_Endnotes')
	AND NAME = N'IX_OdsRowIsCurrent_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsRowIsCurrent_DmlOperation
ON src.BILLS_Endnotes (OdsRowIsCurrent,DmlOperation,OdsCustomerId)
INCLUDE (BillIDNo,LINE_NO,EndNote)
WITH (DATA_COMPRESSION = PAGE);
GO

