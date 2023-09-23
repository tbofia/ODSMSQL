IF OBJECT_ID('src.StateSettingMedicare', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.StateSettingMedicare
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  StateSettingMedicareId INT NOT NULL ,
			  PayPercentOfMedicareFee BIT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.StateSettingMedicare ADD 
     CONSTRAINT PK_StateSettingMedicare PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, StateSettingMedicareId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_StateSettingMedicare ON src.StateSettingMedicare   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
