IF OBJECT_ID('src.Adjustment3603rdPartyEndNoteSubCategory', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Adjustment3603rdPartyEndNoteSubCategory
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ReasonNumber INT NOT NULL ,
			  SubCategoryId INT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Adjustment3603rdPartyEndNoteSubCategory ADD 
     CONSTRAINT PK_Adjustment3603rdPartyEndNoteSubCategory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ReasonNumber) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Adjustment3603rdPartyEndNoteSubCategory ON src.Adjustment3603rdPartyEndNoteSubCategory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
