
IF OBJECT_ID('stg.BillCustomEndnote', 'U') IS NOT NULL
DROP TABLE stg.BillCustomEndnote
BEGIN
	CREATE TABLE stg.BillCustomEndnote (
		BillId INT NULL,
        LineNumber SMALLINT NULL,
		Endnote INT NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO


