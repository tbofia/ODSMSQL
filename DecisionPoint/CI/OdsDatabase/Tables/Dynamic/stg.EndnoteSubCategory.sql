IF OBJECT_ID('stg.EndnoteSubCategory', 'U') IS NOT NULL 
	DROP TABLE stg.EndnoteSubCategory  
BEGIN
	CREATE TABLE stg.EndnoteSubCategory
		(
		  EndnoteSubCategoryId TINYINT NULL,
		  Description VARCHAR (50) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

