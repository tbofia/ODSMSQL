IF OBJECT_ID('src.SEC_RightGroups', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.SEC_RightGroups
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  RightGroupId INT NOT NULL ,
			  RightGroupName VARCHAR (50) NULL ,
			  RightGroupDescription VARCHAR (150) NULL ,
			  CreatedDate DATETIME NULL ,
			  CreatedBy VARCHAR (50) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.SEC_RightGroups ADD 
     CONSTRAINT PK_SEC_RightGroups PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, RightGroupId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_SEC_RightGroups ON src.SEC_RightGroups   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
