IF OBJECT_ID('stg.ModifierByState', 'U') IS NOT NULL 
	DROP TABLE stg.ModifierByState  
BEGIN
	CREATE TABLE stg.ModifierByState
		(
		  State VARCHAR (2) NULL,
		  ProcedureServiceCategoryId TINYINT NULL,
		  ModifierDictionaryId INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

