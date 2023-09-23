IF OBJECT_ID('stg.ExtractCat', 'U') IS NOT NULL
DROP TABLE stg.ExtractCat
BEGIN
	CREATE TABLE stg.ExtractCat (
		CatIdNo INT NULL
		,Description VARCHAR(50) NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
