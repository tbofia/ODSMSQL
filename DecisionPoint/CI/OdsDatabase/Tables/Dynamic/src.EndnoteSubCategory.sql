IF OBJECT_ID('src.EndnoteSubCategory', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.EndnoteSubCategory
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  EndnoteSubCategoryId TINYINT NOT NULL ,
			  Description VARCHAR (50) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.EndnoteSubCategory ADD 
     CONSTRAINT PK_EndnoteSubCategory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, EndnoteSubCategoryId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_EndnoteSubCategory ON src.EndnoteSubCategory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
