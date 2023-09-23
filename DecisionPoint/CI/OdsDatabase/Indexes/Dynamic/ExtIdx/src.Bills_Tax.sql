IF NOT EXISTS (
SELECT *
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.Bills_Tax')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent_TableType_BillIdNo_Line_No_SeqNo_TaxTypeId')

CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent_TableType_BillIdNo_Line_No_SeqNo_TaxTypeId
ON src.Bills_Tax (OdsCustomerId,OdsRowIsCurrent,TableType,BillIdNo,Line_No,SeqNo,TaxTypeId)
INCLUDE (DmlOperation,Tax,OverridenTax)
GO

