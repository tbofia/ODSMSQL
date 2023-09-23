IF OBJECT_ID('src.PPORateType', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.PPORateType
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  RateTypeCode CHAR (8) NOT NULL ,
			  PPONetworkID CHAR (2) NULL ,
			  Category CHAR (1) NULL ,
			  Priority CHAR (1) NULL ,
			  VBColor SMALLINT NULL ,
			  RateTypeDescription VARCHAR (70) NULL ,
			  Explanation VARCHAR (6000) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.PPORateType ADD 
     CONSTRAINT PK_PPORateType PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, RateTypeCode) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_PPORateType ON src.PPORateType   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
