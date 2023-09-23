IF OBJECT_ID('stg.BRERuleCategory', 'U') IS NOT NULL 
	DROP TABLE stg.BRERuleCategory  
BEGIN
	CREATE TABLE stg.BRERuleCategory
		(
		  BRERuleCategoryID VARCHAR (30) NULL,
		  CategoryDescription VARCHAR (500) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

