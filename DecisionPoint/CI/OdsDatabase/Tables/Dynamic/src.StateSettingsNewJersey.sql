IF OBJECT_ID('src.StateSettingsNewJersey', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.StateSettingsNewJersey
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  StateSettingsNewJerseyId INT NOT NULL ,
			  ByPassEmergencyServices BIT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.StateSettingsNewJersey ADD 
     CONSTRAINT PK_StateSettingsNewJersey PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, StateSettingsNewJerseyId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_StateSettingsNewJersey ON src.StateSettingsNewJersey   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
