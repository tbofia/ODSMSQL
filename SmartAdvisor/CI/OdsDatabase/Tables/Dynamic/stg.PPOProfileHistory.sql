IF OBJECT_ID('stg.PPOProfileHistory', 'U') IS NOT NULL 
	DROP TABLE stg.PPOProfileHistory  
BEGIN
	CREATE TABLE stg.PPOProfileHistory
		(
		  PPOProfileHistorySeq BIGINT NULL,
		  RecordDeleted BIT NULL,
		  LogDateTime DATETIME NULL,
		  loginame NVARCHAR (256) NULL,
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

