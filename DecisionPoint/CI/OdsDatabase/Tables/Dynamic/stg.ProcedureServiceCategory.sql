IF OBJECT_ID('stg.ProcedureServiceCategory', 'U') IS NOT NULL 
	DROP TABLE stg.ProcedureServiceCategory  
BEGIN
	CREATE TABLE stg.ProcedureServiceCategory
		(
		  ProcedureServiceCategoryId TINYINT NULL,
		  ProcedureServiceCategoryName VARCHAR (50) NULL,
		  ProcedureServiceCategoryDescription VARCHAR (100) NULL,
		  LegacyTableName VARCHAR (100) NULL,
		  LegacyBitValue INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

