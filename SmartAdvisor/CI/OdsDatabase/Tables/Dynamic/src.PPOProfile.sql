IF OBJECT_ID('src.PPOProfile', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.PPOProfile
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  SiteCode CHAR (3) NOT NULL ,
			  PPOProfileID INT NOT NULL ,
			  ProfileDesc VARCHAR (50) NULL ,
			  CreateDate DATETIME NULL ,
			  CreateUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
			  SmartSearchPageMax SMALLINT NULL ,
			  JurisdictionStackExclusive CHAR (1) NULL ,
			  ReevalFullStackWhenOrigAllowNoHit CHAR (1) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.PPOProfile ADD 
     CONSTRAINT PK_PPOProfile PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, SiteCode, PPOProfileID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_PPOProfile ON src.PPOProfile   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
