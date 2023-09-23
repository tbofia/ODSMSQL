IF OBJECT_ID('stg.PPOProfile', 'U') IS NOT NULL 
	DROP TABLE stg.PPOProfile  
BEGIN
	CREATE TABLE stg.PPOProfile
		(
		  SiteCode CHAR (3) NULL,
		  PPOProfileID INT NULL,
		  ProfileDesc VARCHAR (50) NULL,
		  CreateDate DATETIME NULL,
		  CreateUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  SmartSearchPageMax SMALLINT NULL,
		  JurisdictionStackExclusive CHAR (1) NULL,
		  ReevalFullStackWhenOrigAllowNoHit CHAR (1) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

