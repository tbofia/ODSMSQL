IF OBJECT_ID('stg.WFTaskRegistry', 'U') IS NOT NULL 
	DROP TABLE stg.WFTaskRegistry  
BEGIN
	CREATE TABLE stg.WFTaskRegistry
		(
		  WFTaskRegistrySeq INT NULL,
		  EntityTypeCode CHAR (2) NULL,
		  Description VARCHAR (50) NULL,
		  Action VARCHAR (50) NULL,
		  SmallImageResID INT NULL,
		  LargeImageResID INT NULL,
		  PersistBefore CHAR (1) NULL,
		  NAction VARCHAR (512) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

