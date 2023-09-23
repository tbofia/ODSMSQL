IF OBJECT_ID('stg.CTG_Endnotes', 'U') IS NOT NULL 
	DROP TABLE stg.CTG_Endnotes  
BEGIN
	CREATE TABLE stg.CTG_Endnotes
		(
		  Endnote INT NULL,
		  ShortDesc VARCHAR (50) NULL,
		  LongDesc VARCHAR (500) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

