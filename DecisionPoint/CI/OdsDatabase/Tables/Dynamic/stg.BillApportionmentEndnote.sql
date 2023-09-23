
IF OBJECT_ID('stg.BillApportionmentEndnote', 'U') IS NOT NULL
DROP TABLE stg.BillApportionmentEndnote
BEGIN
	CREATE TABLE stg.BillApportionmentEndnote (
		BillId INT NULL,
        LineNumber SMALLINT NULL,
        Endnote INT NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO
