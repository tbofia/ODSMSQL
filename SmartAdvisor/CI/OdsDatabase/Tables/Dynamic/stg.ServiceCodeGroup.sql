IF OBJECT_ID('stg.ServiceCodeGroup', 'U') IS NOT NULL 
	DROP TABLE stg.ServiceCodeGroup  
BEGIN
	CREATE TABLE stg.ServiceCodeGroup
		(
		  SiteCode CHAR (3) NULL,
		  GroupType VARCHAR (8) NULL,
		  Family VARCHAR (8) NULL,
		  Revision CHAR (4) NULL,
		  GroupCode VARCHAR (8) NULL,
		  CodeOrder INT NULL,
		  ServiceCode VARCHAR (12) NULL,
		  ServiceCodeType VARCHAR (8) NULL,
		  LinkGroupType VARCHAR (8) NULL,
		  LinkGroupFamily VARCHAR (8) NULL,
		  CodeLevel SMALLINT NULL,
		  GlobalPriority INT NULL,
		  Active CHAR (1) NULL,
		  Comment VARCHAR (2000) NULL,
		  CustomParameters VARCHAR (4000) NULL,
		  CreateDate DATETIME NULL,
		  CreateUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

