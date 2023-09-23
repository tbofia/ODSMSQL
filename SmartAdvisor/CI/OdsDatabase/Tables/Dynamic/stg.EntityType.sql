IF OBJECT_ID('stg.EntityType', 'U') IS NOT NULL 
	DROP TABLE stg.EntityType  
BEGIN
	CREATE TABLE stg.EntityType
		(
		  EntityTypeID INT NULL,
		  EntityTypeKey NVARCHAR (250) NULL,
		  Description NVARCHAR (MAX) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

