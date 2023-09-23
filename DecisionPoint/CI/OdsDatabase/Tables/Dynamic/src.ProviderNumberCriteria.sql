IF OBJECT_ID('src.ProviderNumberCriteria', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ProviderNumberCriteria
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ProviderNumberCriteriaId SMALLINT NOT NULL ,
			  ProviderNumber INT NULL ,
			  Priority TINYINT NULL ,
			  FeeScheduleTable CHAR (1) NULL ,
			  StartDate DATETIME2 (7) NULL ,
			  EndDate DATETIME2 (7) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ProviderNumberCriteria ADD 
     CONSTRAINT PK_ProviderNumberCriteria PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ProviderNumberCriteriaId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ProviderNumberCriteria ON src.ProviderNumberCriteria   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
