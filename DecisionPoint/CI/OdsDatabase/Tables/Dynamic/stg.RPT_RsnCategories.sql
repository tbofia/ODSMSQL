IF OBJECT_ID('stg.RPT_RsnCategories', 'U') IS NOT NULL
DROP TABLE stg.RPT_RsnCategories
BEGIN
	CREATE TABLE stg.RPT_RsnCategories (
		CategoryIdNo SMALLINT NULL,
		CatDesc VARCHAR(50) NULL,
		Priority SMALLINT NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO


