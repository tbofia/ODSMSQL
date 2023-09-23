IF OBJECT_ID('stg.Bills_Tax', 'U') IS NOT NULL
DROP TABLE stg.Bills_Tax
BEGIN
	CREATE TABLE stg.Bills_Tax (
		BillsTaxId INT  NULL,
		TableType SMALLINT  NULL,
		BillIdNo INT  NULL,
		Line_No SMALLINT  NULL,
		SeqNo SMALLINT NULL,
		TaxTypeId SMALLINT  NULL,
		ImportTaxRate DECIMAL(5, 5) NULL,
		Tax MONEY NULL,
		OverridenTax MONEY NULL,
		ImportTaxAmount MONEY NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO
