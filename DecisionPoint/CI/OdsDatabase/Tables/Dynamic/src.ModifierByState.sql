IF OBJECT_ID('src.ModifierByState', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ModifierByState
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  State VARCHAR (2) NOT NULL ,
			  ProcedureServiceCategoryId TINYINT NOT NULL ,
			  ModifierDictionaryId INT NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ModifierByState ADD 
     CONSTRAINT PK_ModifierByState PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, State, ProcedureServiceCategoryId, ModifierDictionaryId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ModifierByState ON src.ModifierByState   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
