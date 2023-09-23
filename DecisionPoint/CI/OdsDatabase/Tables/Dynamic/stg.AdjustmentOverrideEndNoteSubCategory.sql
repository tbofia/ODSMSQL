IF OBJECT_ID('stg.AdjustmentOverrideEndNoteSubCategory', 'U') IS NOT NULL 
	DROP TABLE stg.AdjustmentOverrideEndNoteSubCategory  
BEGIN
	CREATE TABLE stg.AdjustmentOverrideEndNoteSubCategory
		(
		  ReasonNumber INT NULL,
		  SubCategoryId VARCHAR (100) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

