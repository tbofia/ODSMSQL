IF OBJECT_ID('stg.Adjustment3rdPartyEndnoteSubCategory', 'U') IS NOT NULL 
	DROP TABLE stg.Adjustment3rdPartyEndnoteSubCategory  
BEGIN
	CREATE TABLE stg.Adjustment3rdPartyEndnoteSubCategory
		(
		  ReasonNumber INT NULL,
		  SubCategoryId VARCHAR (100) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

