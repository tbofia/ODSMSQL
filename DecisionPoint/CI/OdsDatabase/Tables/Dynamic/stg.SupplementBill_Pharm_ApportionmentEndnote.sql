
IF OBJECT_ID('stg.SupplementBill_Pharm_ApportionmentEndnote', 'U') IS NOT NULL
DROP TABLE stg.SupplementBill_Pharm_ApportionmentEndnote
BEGIN
	CREATE TABLE stg.SupplementBill_Pharm_ApportionmentEndnote (
		BillId INT NULL,
		SequenceNumber SMALLINT NULL,
        LineNumber SMALLINT NULL,
        Endnote INT NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO
