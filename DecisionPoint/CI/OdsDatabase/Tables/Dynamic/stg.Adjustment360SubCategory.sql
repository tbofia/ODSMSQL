IF OBJECT_ID('stg.Adjustment360SubCategory', 'U') IS NOT NULL 
	DROP TABLE stg.Adjustment360SubCategory  
BEGIN
	CREATE TABLE stg.Adjustment360SubCategory
		(
		  Adjustment360SubCategoryId INT NULL,
		  Name VARCHAR (50) NULL,
		  Adjustment360CategoryId INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

