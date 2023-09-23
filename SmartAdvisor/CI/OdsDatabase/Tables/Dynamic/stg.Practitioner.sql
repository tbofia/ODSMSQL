IF OBJECT_ID('stg.Practitioner', 'U') IS NOT NULL 
	DROP TABLE stg.Practitioner  
BEGIN
	CREATE TABLE stg.Practitioner
		(
		  SiteCode CHAR (3) NULL,
		  NPI VARCHAR (10) NULL,
		  EntityTypeCode CHAR (1) NULL,
		  Name VARCHAR (150) NULL,
		  FirstName VARCHAR (25) NULL,
		  LastName VARCHAR (35) NULL,
		  MiddleName VARCHAR (25) NULL,
		  Suffix VARCHAR (10) NULL,
		  NameOther VARCHAR (150) NULL,
		  MailingAddress1 VARCHAR (30) NULL,
		  MailingAddress2 VARCHAR (30) NULL,
		  MailingCity VARCHAR (30) NULL,
		  MailingState CHAR (2) NULL,
		  MailingZip VARCHAR (9) NULL,
		  PracticeAddress1 VARCHAR (30) NULL,
		  PracticeAddress2 VARCHAR (30) NULL,
		  PracticeCity VARCHAR (30) NULL,
		  PracticeState CHAR (2) NULL,
		  PracticeZip VARCHAR (9) NULL,
		  EnumerationDate DATETIME NULL,
		  DeactivationReasonCode CHAR (1) NULL,
		  DeactivationDate DATETIME NULL,
		  ReactivationDate DATETIME NULL,
		  Gender CHAR (1) NULL,
		  CreateDate DATETIME NULL,
		  CreateUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

