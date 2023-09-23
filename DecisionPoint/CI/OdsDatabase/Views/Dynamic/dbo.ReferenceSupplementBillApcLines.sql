IF OBJECT_ID('dbo.ReferenceSupplementBillApcLines', 'V') IS NOT NULL
    DROP VIEW dbo.ReferenceSupplementBillApcLines;
GO

CREATE VIEW dbo.ReferenceSupplementBillApcLines
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillIdNo
	,SeqNo
	,Line_No
	,PaymentAPC
	,ServiceIndicator
	,PaymentIndicator
	,OutlierAmount
	,PricerAllowed
	,MedicareAmount
FROM src.ReferenceSupplementBillApcLines
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


