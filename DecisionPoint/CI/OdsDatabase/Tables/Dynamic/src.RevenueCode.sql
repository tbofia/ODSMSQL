IF OBJECT_ID('src.RevenueCode', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.RevenueCode
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  RevenueCode VARCHAR (4) NOT NULL ,
			  RevenueCodeSubCategoryId TINYINT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.RevenueCode ADD 
     CONSTRAINT PK_RevenueCode PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, RevenueCode) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_RevenueCode ON src.RevenueCode   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
