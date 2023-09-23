
IF OBJECT_ID('stg.ApportionmentEndnote', 'U') IS NOT NULL
DROP TABLE stg.ApportionmentEndnote
BEGIN
	CREATE TABLE stg.ApportionmentEndnote (
		ApportionmentEndnote INT NULL,
        ShortDescription VARCHAR(50) NULL,
        LongDescription VARCHAR(500) NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO
