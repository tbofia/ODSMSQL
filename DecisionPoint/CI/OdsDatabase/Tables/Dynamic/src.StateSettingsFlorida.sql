IF OBJECT_ID('src.StateSettingsFlorida', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.StateSettingsFlorida
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  StateSettingsFloridaId INT NOT NULL ,
			  ClaimantInitialServiceOption SMALLINT NULL ,
			  ClaimantInitialServiceDays SMALLINT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.StateSettingsFlorida ADD 
     CONSTRAINT PK_StateSettingsFlorida PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, StateSettingsFloridaId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_StateSettingsFlorida ON src.StateSettingsFlorida   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
