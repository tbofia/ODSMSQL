IF OBJECT_ID('stg.Adjuster', 'U') IS NOT NULL 
	DROP TABLE stg.Adjuster  
BEGIN
	CREATE TABLE stg.Adjuster
		(
		  ClaimSysSubSet CHAR (4) NULL,
		  Adjuster VARCHAR (25) NULL,
		  FirstName VARCHAR (20) NULL,
		  LastName VARCHAR (20) NULL,
		  MInitial CHAR (1) NULL,
		  Title VARCHAR (20) NULL,
		  Address1 VARCHAR (30) NULL,
		  Address2 VARCHAR (30) NULL,
		  City VARCHAR (20) NULL,
		  State CHAR (2) NULL,
		  Zip VARCHAR (9) NULL,
		  PhoneNum VARCHAR (20) NULL,
		  PhoneNumExt VARCHAR (10) NULL,
		  FaxNum VARCHAR (20) NULL,
		  Email VARCHAR (128) NULL,
		  CreateDate DATETIME NULL,
		  CreateUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

