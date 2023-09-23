IF OBJECT_ID('src.SEC_User_OfficeGroups', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.SEC_User_OfficeGroups
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  SECUserOfficeGroupId INT NOT NULL ,
			  UserId INT NULL ,
			  OffcGroupId INT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.SEC_User_OfficeGroups ADD 
     CONSTRAINT PK_SEC_User_OfficeGroups PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, SECUserOfficeGroupId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_SEC_User_OfficeGroups ON src.SEC_User_OfficeGroups   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
