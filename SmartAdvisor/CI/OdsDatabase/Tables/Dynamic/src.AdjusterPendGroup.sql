IF OBJECT_ID('src.AdjusterPendGroup', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.AdjusterPendGroup
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClaimSysSubset CHAR (4) NOT NULL ,
			  Adjuster VARCHAR (25) NOT NULL ,
			  PendGroupCode VARCHAR (12) NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.AdjusterPendGroup ADD 
     CONSTRAINT PK_AdjusterPendGroup PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClaimSysSubset, Adjuster, PendGroupCode) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_AdjusterPendGroup ON src.AdjusterPendGroup   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
