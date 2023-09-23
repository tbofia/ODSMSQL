IF OBJECT_ID('stg.BILLS_Endnotes', 'U') IS NOT NULL 
	DROP TABLE stg.BILLS_Endnotes  
BEGIN
	CREATE TABLE stg.BILLS_Endnotes
		(
		  BillIDNo INT NULL,
		  LINE_NO SMALLINT NULL,
		  EndNote SMALLINT NULL,
		  Referral VARCHAR (200) NULL,
		  PercentDiscount REAL NULL,
		  ActionId SMALLINT NULL,
		  EndnoteTypeId TINYINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

