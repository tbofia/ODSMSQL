IF OBJECT_ID('src.ProviderSys', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ProviderSys
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ProviderSubset CHAR (4) NOT NULL ,
			  ProviderSubSetDesc VARCHAR (30) NULL ,
			  ProviderAccess CHAR (1) NULL ,
			  TaxAddrRequired CHAR (1) NULL ,
			  AllowDummyProviders CHAR (1) NULL ,
			  CascadeUpdatesOnImport CHAR (1) NULL ,
			  RootExtIDOverrideDelimiter CHAR (1) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ProviderSys ADD 
     CONSTRAINT PK_ProviderSys PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ProviderSubset) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ProviderSys ON src.ProviderSys   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
