IF OBJECT_ID('stg.LineMod', 'U') IS NOT NULL 
	DROP TABLE stg.LineMod  
BEGIN
	CREATE TABLE stg.LineMod
		(
		  ClientCode CHAR (4) NULL,
		  BillSeq INT NULL,
		  LineSeq SMALLINT NULL,
		  ModSeq SMALLINT NULL,
		  UserEntered CHAR (1) NULL,
		  ModSiteCode CHAR (3) NULL,
		  Modifier VARCHAR (6) NULL,
		  ReductionCode SMALLINT NULL,
		  ModSubset CHAR (2) NULL,
		  ModUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  ReasonClientCode CHAR (4) NULL,
		  ReasonBillSeq INT NULL,
		  ReasonLineSeq SMALLINT NULL,
		  ReasonType CHAR (1) NULL,
		  ReasonValue VARCHAR (30) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

