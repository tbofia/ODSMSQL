IF OBJECT_ID('stg.Adjustment3603rdPartyEndNoteSubCategory', 'U') IS NOT NULL 
	DROP TABLE stg.Adjustment3603rdPartyEndNoteSubCategory  
BEGIN
	CREATE TABLE stg.Adjustment3603rdPartyEndNoteSubCategory
		(
		  ReasonNumber INT NULL,
		  SubCategoryId INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

