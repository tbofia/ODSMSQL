IF OBJECT_ID('stg.AdjustmentApcEndNoteSubCategory', 'U') IS NOT NULL 
	DROP TABLE stg.AdjustmentApcEndNoteSubCategory  
BEGIN
	CREATE TABLE stg.AdjustmentApcEndNoteSubCategory
		(
		  ReasonNumber INT NULL,
		  SubCategoryId VARCHAR (100) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

