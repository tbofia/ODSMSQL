IF OBJECT_ID('src.Adjustment360SubCategory', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Adjustment360SubCategory
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  Adjustment360SubCategoryId INT NOT NULL ,
			  Name VARCHAR (50) NULL ,
			  Adjustment360CategoryId INT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Adjustment360SubCategory ADD 
     CONSTRAINT PK_Adjustment360SubCategory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Adjustment360SubCategoryId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Adjustment360SubCategory ON src.Adjustment360SubCategory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
