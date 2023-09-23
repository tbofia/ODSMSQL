IF OBJECT_ID('stg.BillICD', 'U') IS NOT NULL 
	DROP TABLE stg.BillICD  
BEGIN
	CREATE TABLE stg.BillICD
		(
		  ClientCode CHAR (4) NULL,
		  BillSeq INT NULL,
		  BillICDSeq SMALLINT NULL,
		  CodeType CHAR (1) NULL,
		  ICDCode VARCHAR (8) NULL,
		  CodeDate DATETIME NULL,
		  POA CHAR (1) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

