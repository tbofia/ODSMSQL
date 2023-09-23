IF OBJECT_ID('stg.PractitionerChild', 'U') IS NOT NULL 
	DROP TABLE stg.PractitionerChild  
BEGIN
	CREATE TABLE stg.PractitionerChild
		(
		  SiteCode CHAR (3) NULL,
		  NPI VARCHAR (10) NULL,
		  Qualifier CHAR (2) NULL,
		  IssuingState CHAR (2) NULL,
		  SubSeq SMALLINT NULL,
		  SecondaryID VARCHAR (30) NULL,
		  CreateDate DATETIME NULL,
		  CreateUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

