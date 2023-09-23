IF OBJECT_ID('src.PPOSubNetwork', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.PPOSubNetwork
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  PPONetworkID CHAR (2) NOT NULL ,
			  GroupCode CHAR (3) NOT NULL ,
			  GroupName VARCHAR (40) NULL ,
			  ExternalID VARCHAR (30) NULL ,
			  SiteCode CHAR (3) NULL ,
			  CreateDate DATETIME NULL ,
			  CreateUserID VARCHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  ModUserID VARCHAR (2) NULL ,
			  Street1 VARCHAR (30) NULL ,
			  Street2 VARCHAR (30) NULL ,
			  City VARCHAR (15) NULL ,
			  State CHAR (2) NULL ,
			  Zip VARCHAR (10) NULL ,
			  PhoneNum VARCHAR (20) NULL ,
			  EmailAddress VARCHAR (255) NULL ,
			  WebSite VARCHAR (255) NULL ,
			  TIN VARCHAR (9) NULL ,
			  Comment VARCHAR (4000) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.PPOSubNetwork ADD 
     CONSTRAINT PK_PPOSubNetwork PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, PPONetworkID, GroupCode) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_PPOSubNetwork ON src.PPOSubNetwork   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
