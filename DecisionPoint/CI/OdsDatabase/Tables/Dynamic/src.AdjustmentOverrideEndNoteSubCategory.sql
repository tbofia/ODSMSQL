IF OBJECT_ID('src.AdjustmentOverrideEndNoteSubCategory', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.AdjustmentOverrideEndNoteSubCategory
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

     ALTER TABLE src.AdjustmentOverrideEndNoteSubCategory ADD 
     CONSTRAINT PK_AdjustmentOverrideEndNoteSubCategory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ReasonNumber) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_AdjustmentOverrideEndNoteSubCategory ON src.AdjustmentOverrideEndNoteSubCategory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
