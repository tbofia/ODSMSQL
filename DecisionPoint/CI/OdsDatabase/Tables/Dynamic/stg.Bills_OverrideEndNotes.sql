IF OBJECT_ID('stg.BILLS_OverrideEndnotes', 'U') IS NOT NULL
DROP TABLE stg.BILLS_OverrideEndnotes
BEGIN
	CREATE TABLE stg.BILLS_OverrideEndnotes (
		OverrideEndNoteID INT NULL
		,BillIdNo INT NULL
		,Line_No SMALLINT NULL
		,OverrideEndNote SMALLINT NULL
		,PercentDiscount REAL NULL
		,ActionId SMALLINT NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
