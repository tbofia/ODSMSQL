
IF OBJECT_ID('stg.SupplementBillApportionmentEndnote', 'U') IS NOT NULL
DROP TABLE stg.SupplementBillApportionmentEndnote
BEGIN
	CREATE TABLE stg.SupplementBillApportionmentEndnote (
		BillId INT NULL,
		SequenceNumber SMALLINT NULL,
        LineNumber SMALLINT NULL,
        Endnote INT NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO
