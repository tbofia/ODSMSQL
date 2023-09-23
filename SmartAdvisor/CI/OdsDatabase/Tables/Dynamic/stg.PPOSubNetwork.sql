IF OBJECT_ID('stg.PPOSubNetwork', 'U') IS NOT NULL 
	DROP TABLE stg.PPOSubNetwork  
BEGIN
	CREATE TABLE stg.PPOSubNetwork
		(
		  PPONetworkID CHAR (2) NULL,
		  GroupCode CHAR (3) NULL,
		  GroupName VARCHAR (40) NULL,
		  ExternalID VARCHAR (30) NULL,
		  SiteCode CHAR (3) NULL,
		  CreateDate DATETIME NULL,
		  CreateUserID VARCHAR (2) NULL,
		  ModDate DATETIME NULL,
		  ModUserID VARCHAR (2) NULL,
		  Street1 VARCHAR (30) NULL,
		  Street2 VARCHAR (30) NULL,
		  City VARCHAR (15) NULL,
		  State CHAR (2) NULL,
		  Zip VARCHAR (10) NULL,
		  PhoneNum VARCHAR (20) NULL,
		  EmailAddress VARCHAR (255) NULL,
		  WebSite VARCHAR (255) NULL,
		  TIN VARCHAR (9) NULL,
		  Comment VARCHAR (4000) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

