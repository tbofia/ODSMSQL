IF OBJECT_ID('stg.BillPPORate', 'U') IS NOT NULL 
	DROP TABLE stg.BillPPORate  
BEGIN
	CREATE TABLE stg.BillPPORate
		(
		  ClientCode CHAR (4) NULL,
		  BillSeq INT NULL,
		  LinkName VARCHAR (12) NULL,
		  RateType VARCHAR (8) NULL,
		  Applied CHAR (1) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

