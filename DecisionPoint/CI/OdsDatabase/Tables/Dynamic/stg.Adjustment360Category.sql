IF OBJECT_ID('stg.Adjustment360Category', 'U') IS NOT NULL 
	DROP TABLE stg.Adjustment360Category  
BEGIN
	CREATE TABLE stg.Adjustment360Category
		(
		  Adjustment360CategoryId INT NULL,
		  Name VARCHAR (50) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

