IF OBJECT_ID('src.ProviderNumberCriteriaRevenueCode', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ProviderNumberCriteriaRevenueCode
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ProviderNumberCriteriaId SMALLINT NOT NULL ,
			  RevenueCode VARCHAR (4) NOT NULL ,
			  MatchingProfileNumber TINYINT NULL ,
			  AttributeMatchTypeId TINYINT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ProviderNumberCriteriaRevenueCode ADD 
     CONSTRAINT PK_ProviderNumberCriteriaRevenueCode PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ProviderNumberCriteriaId, RevenueCode) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ProviderNumberCriteriaRevenueCode ON src.ProviderNumberCriteriaRevenueCode   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
