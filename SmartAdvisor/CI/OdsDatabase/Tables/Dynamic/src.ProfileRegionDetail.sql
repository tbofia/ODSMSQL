IF OBJECT_ID('src.ProfileRegionDetail', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ProfileRegionDetail
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ProfileRegionSiteCode CHAR (3) NOT NULL ,
			  ProfileRegionID INT NOT NULL ,
			  ZipCodeFrom CHAR (5) NOT NULL ,
			  ZipCodeTo CHAR (5) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ProfileRegionDetail ADD 
     CONSTRAINT PK_ProfileRegionDetail PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ProfileRegionSiteCode, ProfileRegionID, ZipCodeFrom) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ProfileRegionDetail ON src.ProfileRegionDetail   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
