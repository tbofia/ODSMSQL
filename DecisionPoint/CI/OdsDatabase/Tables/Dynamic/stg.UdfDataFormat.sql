IF OBJECT_ID('stg.UdfDataFormat', 'U') IS NOT NULL 
	DROP TABLE stg.UdfDataFormat  
BEGIN
	CREATE TABLE stg.UdfDataFormat
		(
		  UdfDataFormatId SMALLINT NULL,
		  DataFormatName VARCHAR (30) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

