IF OBJECT_ID('src.PPOProfileHistory', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.PPOProfileHistory
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  PPOProfileHistorySeq BIGINT NOT NULL ,
			  RecordDeleted BIT NULL ,
			  LogDateTime DATETIME NULL ,
			  loginame NVARCHAR (256) NULL ,
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

     ALTER TABLE src.PPOProfileHistory ADD 
     CONSTRAINT PK_PPOProfileHistory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, PPOProfileHistorySeq, SiteCode, PPOProfileID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_PPOProfileHistory ON src.PPOProfileHistory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
