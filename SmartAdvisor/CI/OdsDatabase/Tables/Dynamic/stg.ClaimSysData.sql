IF OBJECT_ID('stg.ClaimSysData', 'U') IS NOT NULL 
	DROP TABLE stg.ClaimSysData  
BEGIN
	CREATE TABLE stg.ClaimSysData
		(
		  ClaimSysSubset CHAR (4) NULL,
		  TypeCode CHAR (6) NULL,
		  SubType CHAR (12) NULL,
		  SubSeq SMALLINT NULL,
		  NumData NUMERIC (18,6) NULL,
		  TextData VARCHAR (6000) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

