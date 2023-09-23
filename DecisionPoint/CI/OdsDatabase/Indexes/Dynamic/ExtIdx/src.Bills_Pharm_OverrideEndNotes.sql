IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.Bills_Pharm_OverrideEndNotes')
	AND NAME = 'IX_OdsCustomerId_OdsRowIsCurrent_BillIdNo_Line_No_DmlOperation')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent_BillIdNo_Line_No_DmlOperation
ON src.Bills_Pharm_OverrideEndNotes(OdsCustomerId,OdsRowIsCurrent,BillIdNo,Line_No,DmlOperation)
WITH (DATA_COMPRESSION = PAGE);
GO
