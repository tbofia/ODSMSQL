
IF OBJECT_ID('stg.Bill_Pharm_ApportionmentEndnote', 'U') IS NOT NULL
DROP TABLE stg.Bill_Pharm_ApportionmentEndnote
BEGIN
	CREATE TABLE stg.Bill_Pharm_ApportionmentEndnote (
		BillId INT NULL,
        LineNumber SMALLINT NULL,
        Endnote INT NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO
