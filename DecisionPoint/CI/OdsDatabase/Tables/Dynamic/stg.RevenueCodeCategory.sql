IF OBJECT_ID('stg.RevenueCodeCategory', 'U') IS NOT NULL
DROP TABLE stg.RevenueCodeCategory
BEGIN
	CREATE TABLE stg.RevenueCodeCategory	(
		RevenueCodeCategoryId TINYINT  NULL,
		Description VARCHAR(100) NULL,
		NarrativeInformation VARCHAR(1000) NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO
