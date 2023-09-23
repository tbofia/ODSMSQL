IF OBJECT_ID('dbo.UDFBill', 'V') IS NOT NULL
    DROP VIEW dbo.UDFBill;
GO

CREATE VIEW dbo.UDFBill
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
	,UDFIdNo
	,UDFValueText
	,UDFValueDecimal
	,UDFValueDate
FROM src.UDFBill
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


