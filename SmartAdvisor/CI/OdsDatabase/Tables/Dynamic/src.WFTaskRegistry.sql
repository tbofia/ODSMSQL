IF OBJECT_ID('src.WFTaskRegistry', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.WFTaskRegistry
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  WFTaskRegistrySeq INT NOT NULL ,
			  EntityTypeCode CHAR (2) NULL ,
			  Description VARCHAR (50) NULL ,
			  Action VARCHAR (50) NULL ,
			  SmallImageResID INT NULL ,
			  LargeImageResID INT NULL ,
			  PersistBefore CHAR (1) NULL ,
			  NAction VARCHAR (512) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.WFTaskRegistry ADD 
     CONSTRAINT PK_WFTaskRegistry PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, WFTaskRegistrySeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_WFTaskRegistry ON src.WFTaskRegistry   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
