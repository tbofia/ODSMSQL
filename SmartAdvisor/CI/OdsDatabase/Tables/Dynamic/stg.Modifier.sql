IF OBJECT_ID('stg.Modifier', 'U') IS NOT NULL 
	DROP TABLE stg.Modifier  
BEGIN
	CREATE TABLE stg.Modifier
		(
		  Jurisdiction CHAR (2) NULL,
		  Code VARCHAR (6) NULL,
		  SiteCode CHAR (3) NULL,
		  Func CHAR (1) NULL,
		  Val CHAR (3) NULL,
		  ModType CHAR (1) NULL,
		  GroupCode CHAR (2) NULL,
		  ModDescription VARCHAR (30) NULL,
		  ModComment1 VARCHAR (70) NULL,
		  ModComment2 VARCHAR (70) NULL,
		  CreateDate DATETIME NULL,
		  CreateUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  Statute VARCHAR (30) NULL,
		  Remark1 VARCHAR (6) NULL,
		  RemarkQualifier1 VARCHAR (2) NULL,
		  Remark2 VARCHAR (6) NULL,
		  RemarkQualifier2 VARCHAR (2) NULL,
		  Remark3 VARCHAR (6) NULL,
		  RemarkQualifier3 VARCHAR (2) NULL,
		  Remark4 VARCHAR (6) NULL,
		  RemarkQualifier4 VARCHAR (2) NULL,
		  CBREReasonID INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

