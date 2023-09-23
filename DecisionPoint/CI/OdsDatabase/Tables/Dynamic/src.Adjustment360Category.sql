IF OBJECT_ID('src.Adjustment360Category', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Adjustment360Category
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  Adjustment360CategoryId INT NOT NULL ,
			  Name VARCHAR (50) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Adjustment360Category ADD 
     CONSTRAINT PK_Adjustment360Category PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Adjustment360CategoryId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Adjustment360Category ON src.Adjustment360Category   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
