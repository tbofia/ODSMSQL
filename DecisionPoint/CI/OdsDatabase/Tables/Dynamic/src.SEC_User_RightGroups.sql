IF OBJECT_ID('src.SEC_User_RightGroups', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.SEC_User_RightGroups
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  SECUserRightGroupId INT NOT NULL ,
			  UserId INT NULL ,
			  RightGroupId INT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.SEC_User_RightGroups ADD 
     CONSTRAINT PK_SEC_User_RightGroups PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, SECUserRightGroupId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_SEC_User_RightGroups ON src.SEC_User_RightGroups   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
