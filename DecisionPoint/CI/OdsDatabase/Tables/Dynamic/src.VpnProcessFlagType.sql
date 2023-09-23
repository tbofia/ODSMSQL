IF OBJECT_ID('src.VpnProcessFlagType', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.VpnProcessFlagType
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  VpnProcessFlagTypeId SMALLINT NOT NULL ,
			  VpnProcessFlagType VARCHAR (50) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.VpnProcessFlagType ADD 
     CONSTRAINT PK_VpnProcessFlagType PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, VpnProcessFlagTypeId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_VpnProcessFlagType ON src.VpnProcessFlagType   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
