IF OBJECT_ID('src.Practitioner', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Practitioner
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  SiteCode CHAR (3) NOT NULL ,
			  NPI VARCHAR (10) NOT NULL ,
			  EntityTypeCode CHAR (1) NULL ,
			  Name VARCHAR (150) NULL ,
			  FirstName VARCHAR (25) NULL ,
			  LastName VARCHAR (35) NULL ,
			  MiddleName VARCHAR (25) NULL ,
			  Suffix VARCHAR (10) NULL ,
			  NameOther VARCHAR (150) NULL ,
			  MailingAddress1 VARCHAR (30) NULL ,
			  MailingAddress2 VARCHAR (30) NULL ,
			  MailingCity VARCHAR (30) NULL ,
			  MailingState CHAR (2) NULL ,
			  MailingZip VARCHAR (9) NULL ,
			  PracticeAddress1 VARCHAR (30) NULL ,
			  PracticeAddress2 VARCHAR (30) NULL ,
			  PracticeCity VARCHAR (30) NULL ,
			  PracticeState CHAR (2) NULL ,
			  PracticeZip VARCHAR (9) NULL ,
			  EnumerationDate DATETIME NULL ,
			  DeactivationReasonCode CHAR (1) NULL ,
			  DeactivationDate DATETIME NULL ,
			  ReactivationDate DATETIME NULL ,
			  Gender CHAR (1) NULL ,
			  CreateDate DATETIME NULL ,
			  CreateUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Practitioner ADD 
     CONSTRAINT PK_Practitioner PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, SiteCode, NPI) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Practitioner ON src.Practitioner   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
