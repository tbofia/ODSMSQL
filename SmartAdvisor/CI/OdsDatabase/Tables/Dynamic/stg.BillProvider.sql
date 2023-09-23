IF OBJECT_ID('stg.BillProvider', 'U') IS NOT NULL 
	DROP TABLE stg.BillProvider  
BEGIN
	CREATE TABLE stg.BillProvider
		(
		  ClientCode CHAR (4) NULL,
		  BillSeq INT NULL,
		  BillProviderSeq INT NULL,
		  Qualifier CHAR (2) NULL,
		  LastName VARCHAR (40) NULL,
		  FirstName VARCHAR (30) NULL,
		  MiddleName VARCHAR (25) NULL,
		  Suffix VARCHAR (10) NULL,
		  NPI VARCHAR (10) NULL,
		  LicenseNum VARCHAR (30) NULL,
		  DEANum VARCHAR (9) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

