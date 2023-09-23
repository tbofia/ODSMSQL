IF OBJECT_ID('stg.Bills_Pharm_CTG_Endnotes', 'U') IS NOT NULL
DROP TABLE stg.Bills_Pharm_CTG_Endnotes
BEGIN
	CREATE TABLE stg.Bills_Pharm_CTG_Endnotes (
		BillIDNo INT NULL
		,LINE_NO SMALLINT NULL
		,EndNote SMALLINT NULL
		,RuleType VARCHAR(2) NULL
		,RuleId INT NULL
		,PreCertAction SMALLINT NULL
		,PercentDiscount REAL NULL
		,ActionId SMALLINT NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
