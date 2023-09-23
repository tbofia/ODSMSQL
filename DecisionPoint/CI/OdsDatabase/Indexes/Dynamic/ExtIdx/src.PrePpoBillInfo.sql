IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.PrePpoBillInfo')
	AND NAME = 'IX_PrePpoBillInfo_DateSentToPPO')
	
CREATE NONCLUSTERED INDEX IX_PrePpoBillInfo_DateSentToPPO 
ON src.PrePpoBillInfo(BillSnapshot ASC,OdsRowIsCurrent ASC,DmlOperation ASC,OdsCustomerId ASC)
INCLUDE ( BillIDNo,DateSentToPPO,LINE_NO,PharmacyLine)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.PrePpoBillInfo')
	AND NAME = 'IX_OdsRowIsCurrent_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsRowIsCurrent_DmlOperation
ON src.PrePpoBillInfo (OdsRowIsCurrent,DmlOperation)
INCLUDE (OdsCustomerId,BillIDNo,LINE_NO,OVER_RIDE,ALLOWED,ANALYZED,PharmacyLine,Endnotes,PrePPOBillInfoID)
WITH (DATA_COMPRESSION = PAGE);
GO

