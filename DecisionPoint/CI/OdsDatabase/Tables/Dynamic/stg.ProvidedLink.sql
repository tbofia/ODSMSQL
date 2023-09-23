IF OBJECT_ID('stg.ProvidedLink', 'U') IS NOT NULL 
	DROP TABLE stg.ProvidedLink  
BEGIN
	CREATE TABLE stg.ProvidedLink
		(
		  ProvidedLinkId INT NULL,
		  Title VARCHAR (100) NULL,
		  URL VARCHAR (150) NULL,
		  OrderIndex TINYINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

