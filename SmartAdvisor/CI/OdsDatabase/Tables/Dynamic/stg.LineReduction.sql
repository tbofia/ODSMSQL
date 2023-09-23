IF OBJECT_ID('stg.LineReduction', 'U') IS NOT NULL 
	DROP TABLE stg.LineReduction  
BEGIN
	CREATE TABLE stg.LineReduction
		(
		  ClientCode CHAR (4) NULL,
		  BillSeq INT NULL,
		  LineSeq SMALLINT NULL,
		  ReductionCode SMALLINT NULL,
		  ReductionAmount MONEY NULL,
		  OverrideAmount MONEY NULL,
		  ModUserID CHAR (2) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

