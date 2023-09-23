IF OBJECT_ID('stg.Drugs', 'U') IS NOT NULL 
	DROP TABLE stg.Drugs  
BEGIN
	CREATE TABLE stg.Drugs
		(
		  DrugCode CHAR (4) NULL,
		  DrugsDescription VARCHAR (20) NULL,
		  Disp VARCHAR (20) NULL,
		  DrugType CHAR (1) NULL,
		  Cat CHAR (1) NULL,
		  UpdateFlag CHAR (1) NULL,
		  Uv INT NULL,
		  CreateDate DATETIME NULL,
		  CreateUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

