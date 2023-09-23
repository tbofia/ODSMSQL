IF OBJECT_ID('src.VpnSavingTransactionType', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.VpnSavingTransactionType
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  VpnSavingTransactionTypeId INT NOT NULL ,
			  VpnSavingTransactionType VARCHAR (50) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.VpnSavingTransactionType ADD 
     CONSTRAINT PK_VpnSavingTransactionType PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, VpnSavingTransactionTypeId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_VpnSavingTransactionType ON src.VpnSavingTransactionType   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
