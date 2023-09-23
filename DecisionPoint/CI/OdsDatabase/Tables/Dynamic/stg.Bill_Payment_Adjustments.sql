IF OBJECT_ID('stg.Bill_Payment_Adjustments', 'U') IS NOT NULL
DROP TABLE stg.Bill_Payment_Adjustments
BEGIN
	CREATE TABLE stg.Bill_Payment_Adjustments (
		Bill_Payment_Adjustment_ID INT  NULL,
		BillIDNo INT NULL,
		SeqNo SMALLINT NULL,
		InterestFlags INT NULL,
		DateInterestStarts DATETIME NULL,
		DateInterestEnds DATETIME NULL,
		InterestAdditionalInfoReceived DATETIME NULL,
		Interest MONEY NULL,
		Comments VARCHAR(1000) NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO
