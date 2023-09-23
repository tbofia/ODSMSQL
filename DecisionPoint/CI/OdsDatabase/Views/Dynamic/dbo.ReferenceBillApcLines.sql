IF OBJECT_ID('dbo.ReferenceBillApcLines', 'V') IS NOT NULL
    DROP VIEW dbo.ReferenceBillApcLines;
GO

CREATE VIEW dbo.ReferenceBillApcLines
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
	,Line_No
	,PaymentAPC
	,ServiceIndicator
	,PaymentIndicator
	,OutlierAmount
	,PricerAllowed
	,MedicareAmount
FROM src.ReferenceBillApcLines
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


