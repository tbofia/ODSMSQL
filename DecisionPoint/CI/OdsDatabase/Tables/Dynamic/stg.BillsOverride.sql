IF OBJECT_ID('stg.BillsOverride', 'U') IS NOT NULL
DROP TABLE stg.BillsOverride
BEGIN
	CREATE TABLE stg.BillsOverride(
		BillsOverrideID INT NULL,
		BillIDNo INT NULL,
		LINE_NO SMALLINT NULL,
		UserId INT NULL,
		DateSaved DATETIME NULL,
		AmountBefore MONEY NULL,
		AmountAfter MONEY NULL,
		CodesOverrode VARCHAR(50) NULL,
		SeqNo INT NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO
