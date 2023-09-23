IF OBJECT_ID('src.StateSettingsHawaii', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.StateSettingsHawaii
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  StateSettingsHawaiiId INT NOT NULL ,
			  PhysicalMedicineLimitOption SMALLINT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.StateSettingsHawaii ADD 
     CONSTRAINT PK_StateSettingsHawaii PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, StateSettingsHawaiiId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_StateSettingsHawaii ON src.StateSettingsHawaii   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
