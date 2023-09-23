IF OBJECT_ID('stg.Adjustment360ApcEndNoteSubCategory', 'U') IS NOT NULL 
	DROP TABLE stg.Adjustment360ApcEndNoteSubCategory  
BEGIN
	CREATE TABLE stg.Adjustment360ApcEndNoteSubCategory
		(
		  ReasonNumber INT NULL,
		  SubCategoryId INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

