IF OBJECT_ID('src.PPOProfileNetworksHistory', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.PPOProfileNetworksHistory
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  PPOProfileNetworksHistorySeq BIGINT NOT NULL ,
			  RecordDeleted BIT NULL ,
			  LogDateTime DATETIME NULL ,
			  loginame NVARCHAR (256) NULL ,
			  PPOProfileSiteCode CHAR (3) NOT NULL ,
			  PPOProfileID INT NOT NULL ,
			  ProfileRegionSiteCode CHAR (3) NOT NULL ,
			  ProfileRegionID INT NOT NULL ,
			  NetworkOrder SMALLINT NOT NULL ,
			  PPONetworkID CHAR (2) NULL ,
			  SearchLogic CHAR (1) NULL ,
			  Verification CHAR (1) NULL ,
			  EffectiveDate DATETIME NOT NULL ,
			  TerminationDate DATETIME NULL ,
			  JurisdictionInd CHAR (1) NULL ,
			  JurisdictionInsurerSeq INT NULL ,
			  JurisdictionUseOnly CHAR (1) NULL ,
			  PPOSSTinReq CHAR (1) NULL ,
			  PPOSSLicReq CHAR (1) NULL ,
			  DefaultExtendedSearches SMALLINT NULL ,
			  DefaultExtendedFilters SMALLINT NULL ,
			  SeveredTies CHAR (1) NULL ,
			  POS VARCHAR (500) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.PPOProfileNetworksHistory ADD 
     CONSTRAINT PK_PPOProfileNetworksHistory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, PPOProfileNetworksHistorySeq, PPOProfileSiteCode, PPOProfileID, ProfileRegionSiteCode, ProfileRegionID, NetworkOrder, EffectiveDate) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_PPOProfileNetworksHistory ON src.PPOProfileNetworksHistory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
