IF OBJECT_ID('stg.RevenueCodeSubcategory', 'U') IS NOT NULL
DROP TABLE stg.RevenueCodeSubcategory;
BEGIN
	CREATE TABLE stg.RevenueCodeSubcategory(
		RevenueCodeSubcategoryId TINYINT NULL,
		RevenueCodeCategoryId TINYINT NULL,
		Description VARCHAR(100) NULL,
		NarrativeInformation VARCHAR(1000) NULL,
		DmlOperation CHAR(1) NOT NULL 
		)
END
GO
