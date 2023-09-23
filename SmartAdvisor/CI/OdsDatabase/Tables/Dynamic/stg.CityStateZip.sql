IF OBJECT_ID('stg.CityStateZip', 'U') IS NOT NULL 
	DROP TABLE stg.CityStateZip  
BEGIN
	CREATE TABLE stg.CityStateZip
		(
		  ZipCode CHAR (5) NULL,
		  CtyStKey CHAR (6) NULL,
		  CpyDtlCode CHAR (1) NULL,
		  ZipClsCode CHAR (1) NULL,
		  CtyStName VARCHAR (28) NULL,
		  CtyStNameAbv VARCHAR (13) NULL,
		  CtyStFacCode CHAR (1) NULL,
		  CtyStMailInd CHAR (1) NULL,
		  PreLstCtyKey VARCHAR (6) NULL,
		  PreLstCtyNme VARCHAR (28) NULL,
		  CtyDlvInd CHAR (1) NULL,
		  AutZoneInd CHAR (1) NULL,
		  UnqZipInd CHAR (1) NULL,
		  FinanceNum VARCHAR (6) NULL,
		  StateAbbrv CHAR (2) NULL,
		  CountyNum CHAR (3) NULL,
		  CountyName VARCHAR (25) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

