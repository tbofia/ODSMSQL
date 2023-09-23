IF OBJECT_ID('src.Adjustment360OverrideEndNoteSubCategory', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Adjustment360OverrideEndNoteSubCategory
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

     ALTER TABLE src.Adjustment360OverrideEndNoteSubCategory ADD 
     CONSTRAINT PK_Adjustment360OverrideEndNoteSubCategory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ReasonNumber) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Adjustment360OverrideEndNoteSubCategory ON src.Adjustment360OverrideEndNoteSubCategory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
