IF OBJECT_ID('src.Adjustment3rdPartyEndnoteSubCategory', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Adjustment3rdPartyEndnoteSubCategory
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ReasonNumber INT NOT NULL ,
			  SubCategoryId VARCHAR (100) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Adjustment3rdPartyEndnoteSubCategory ADD 
     CONSTRAINT PK_Adjustment3rdPartyEndnoteSubCategory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ReasonNumber) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Adjustment3rdPartyEndnoteSubCategory ON src.Adjustment3rdPartyEndnoteSubCategory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
