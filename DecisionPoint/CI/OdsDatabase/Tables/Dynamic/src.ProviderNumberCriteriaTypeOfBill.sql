IF OBJECT_ID('src.ProviderNumberCriteriaTypeOfBill', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ProviderNumberCriteriaTypeOfBill
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ProviderNumberCriteriaId SMALLINT NOT NULL ,
			  TypeOfBill VARCHAR (4) NOT NULL ,
			  MatchingProfileNumber TINYINT NULL ,
			  AttributeMatchTypeId TINYINT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ProviderNumberCriteriaTypeOfBill ADD 
     CONSTRAINT PK_ProviderNumberCriteriaTypeOfBill PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ProviderNumberCriteriaId, TypeOfBill) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ProviderNumberCriteriaTypeOfBill ON src.ProviderNumberCriteriaTypeOfBill   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
