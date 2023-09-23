IF OBJECT_ID('dbo.Bills_Tax', 'V') IS NOT NULL
    DROP VIEW dbo.Bills_Tax;
GO

CREATE VIEW dbo.Bills_Tax
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillsTaxId
	,TableType
	,BillIdNo
	,Line_No
	,SeqNo
	,TaxTypeId
	,ImportTaxRate
	,Tax
	,OverridenTax
	,ImportTaxAmount
FROM src.Bills_Tax
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


