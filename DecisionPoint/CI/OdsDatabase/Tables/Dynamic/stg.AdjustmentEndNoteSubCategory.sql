IF OBJECT_ID('stg.AdjustmentEndNoteSubCategory', 'U') IS NOT NULL 
	DROP TABLE stg.AdjustmentEndNoteSubCategory  
BEGIN
	CREATE TABLE stg.AdjustmentEndNoteSubCategory
		(
		  ReasonNumber INT NULL,
		  SubCategoryId VARCHAR (100) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

