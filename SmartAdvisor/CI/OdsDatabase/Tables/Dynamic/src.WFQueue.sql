IF OBJECT_ID('src.WFQueue', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.WFQueue
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  EntityTypeCode CHAR (2) NOT NULL ,
			  EntitySubset CHAR (4) NOT NULL ,
			  EntitySeq BIGINT NOT NULL ,
			  WFTaskSeq INT NULL ,
			  PriorWFTaskSeq INT NULL ,
			  Status CHAR (1) NULL ,
			  Priority CHAR (1) NULL ,
			  CreateUserID CHAR (2) NULL ,
			  CreateDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  TaskMessage VARCHAR (500) NULL ,
			  Parameter1 VARCHAR (35) NULL ,
			  ContextID VARCHAR (256) NULL ,
			  PriorStatus CHAR (1) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.WFQueue ADD 
     CONSTRAINT PK_WFQueue PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, EntityTypeCode, EntitySubset, EntitySeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_WFQueue ON src.WFQueue   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO

