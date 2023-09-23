IF OBJECT_ID('src.NcciBodyPartToHybridBodyPartTranslation', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.NcciBodyPartToHybridBodyPartTranslation
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  NcciBodyPartId TINYINT NOT NULL ,
			  HybridBodyPartId SMALLINT NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.NcciBodyPartToHybridBodyPartTranslation ADD 
     CONSTRAINT PK_NcciBodyPartToHybridBodyPartTranslation PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, NcciBodyPartId, HybridBodyPartId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_NcciBodyPartToHybridBodyPartTranslation ON src.NcciBodyPartToHybridBodyPartTranslation   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
