IF OBJECT_ID('stg.NcciBodyPart', 'U') IS NOT NULL 
	DROP TABLE stg.NcciBodyPart  
BEGIN
	CREATE TABLE stg.NcciBodyPart
		(
		  NcciBodyPartId TINYINT NULL,
		  Description VARCHAR (100) NULL,
		  NarrativeInformation VARCHAR (MAX) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

