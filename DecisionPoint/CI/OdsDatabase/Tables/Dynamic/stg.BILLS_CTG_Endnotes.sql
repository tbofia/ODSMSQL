IF OBJECT_ID('stg.BILLS_CTG_Endnotes', 'U') IS NOT NULL
DROP TABLE stg.BILLS_CTG_EndNotes
BEGIN
	CREATE TABLE stg.BILLS_CTG_Endnotes (
		BillIdNo INT NULL
		,Line_No SMALLINT NULL
		,Endnote INT NULL
		,RuleType VARCHAR(2) NULL
		,RuleId INT NULL
		,PreCertAction SMALLINT NULL
		,PercentDiscount REAL NULL
		,ActionId SMALLINT NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
