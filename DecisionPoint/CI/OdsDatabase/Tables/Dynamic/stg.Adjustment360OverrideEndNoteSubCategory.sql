IF OBJECT_ID('stg.Adjustment360OverrideEndNoteSubCategory', 'U') IS NOT NULL 
	DROP TABLE stg.Adjustment360OverrideEndNoteSubCategory  
BEGIN
	CREATE TABLE stg.Adjustment360OverrideEndNoteSubCategory
		(
		  ReasonNumber INT NULL,
		  SubCategoryId INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

