IF OBJECT_ID('stg.RevenueCode', 'U') IS NOT NULL 
	DROP TABLE stg.RevenueCode  
BEGIN
	CREATE TABLE stg.RevenueCode
		(
		  RevenueCode VARCHAR (4) NULL,
		  RevenueCodeSubCategoryId TINYINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

