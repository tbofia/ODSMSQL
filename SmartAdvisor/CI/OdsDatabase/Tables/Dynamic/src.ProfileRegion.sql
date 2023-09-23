IF OBJECT_ID('src.ProfileRegion', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ProfileRegion
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  SiteCode CHAR (3) NOT NULL ,
			  ProfileRegionID INT NOT NULL ,
			  RegionTypeCode CHAR (2) NULL ,
			  RegionName VARCHAR (50) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ProfileRegion ADD 
     CONSTRAINT PK_ProfileRegion PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, SiteCode, ProfileRegionID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ProfileRegion ON src.ProfileRegion   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
