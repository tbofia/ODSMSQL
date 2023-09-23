IF OBJECT_ID('stg.Bills_Pharm_OverrideEndnotes', 'U') IS NOT NULL
DROP TABLE stg.Bills_Pharm_OverrideEndnotes
BEGIN
	CREATE TABLE stg.Bills_Pharm_OverrideEndnotes (
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
