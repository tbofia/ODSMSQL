IF OBJECT_ID('stg.Adjustment360EndNoteSubCategory', 'U') IS NOT NULL 
	DROP TABLE stg.Adjustment360EndNoteSubCategory  
BEGIN
	CREATE TABLE stg.Adjustment360EndNoteSubCategory
		(
		  ReasonNumber INT NULL,
		  SubCategoryId INT NULL,
		  EndnoteTypeId TINYINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

