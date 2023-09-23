
IF OBJECT_ID('stg.SupplementBillCustomEndnote', 'U') IS NOT NULL
DROP TABLE stg.SupplementBillCustomEndnote
BEGIN
	CREATE TABLE stg.SupplementBillCustomEndnote (
		BillId INT NULL,
		SequenceNumber SMALLINT NULL,
        LineNumber SMALLINT NULL,
		Endnote INT NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO


