IF OBJECT_ID('src.EntityType', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.EntityType
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  EntityTypeID INT NOT NULL ,
			  EntityTypeKey NVARCHAR (250) NULL ,
			  Description NVARCHAR (MAX) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.EntityType ADD 
     CONSTRAINT PK_EntityType PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, EntityTypeID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_EntityType ON src.EntityType   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
