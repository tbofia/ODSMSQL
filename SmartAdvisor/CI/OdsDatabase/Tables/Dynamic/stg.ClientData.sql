IF OBJECT_ID('stg.ClientData', 'U') IS NOT NULL 
	DROP TABLE stg.ClientData  
BEGIN
	CREATE TABLE stg.ClientData
		(
		  ClientCode CHAR (4) NULL,
		  TypeCode CHAR (6) NULL,
		  SubType CHAR (12) NULL,
		  SubSeq SMALLINT NULL,
		  NumData NUMERIC (18,6) NULL,
		  TextData VARCHAR (6000) NULL,
		  CreateDate DATETIME NULL,
		  CreateUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

