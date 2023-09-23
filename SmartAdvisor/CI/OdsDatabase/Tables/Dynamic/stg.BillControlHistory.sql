IF OBJECT_ID('stg.BillControlHistory', 'U') IS NOT NULL 
	DROP TABLE stg.BillControlHistory  
BEGIN
	CREATE TABLE stg.BillControlHistory
		(
		  BillControlHistorySeq BIGINT NULL,
		  ClientCode CHAR (4) NULL,
		  BillSeq INT NULL,
		  BillControlSeq SMALLINT NULL,
		  CreateDate DATETIME NULL,
		  Control CHAR (1) NULL,
		  ExternalID VARCHAR (50) NULL,
		  EDIBatchLogSeq BIGINT NULL,
		  Deleted BIT NULL,
		  ModUserID CHAR (2) NULL,
		  ExternalID2 VARCHAR (50) NULL,
		  Message VARCHAR (500) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

