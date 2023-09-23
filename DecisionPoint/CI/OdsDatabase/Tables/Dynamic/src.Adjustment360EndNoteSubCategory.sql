IF OBJECT_ID('src.Adjustment360EndNoteSubCategory', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Adjustment360EndNoteSubCategory
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
			  EndnoteTypeId TINYINT CONSTRAINT DF_Adjustment360EndNoteSubCategory_EndnoteTypeId DEFAULT(1) NOT NULL
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Adjustment360EndNoteSubCategory ADD 
     CONSTRAINT PK_Adjustment360EndNoteSubCategory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ReasonNumber, EndnoteTypeId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Adjustment360EndNoteSubCategory ON src.Adjustment360EndNoteSubCategory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO

 IF NOT EXISTS ( SELECT 1
			FROM sys.indexes AS i 
			INNER JOIN sys.index_columns AS ic 
				ON i.OBJECT_ID = ic.OBJECT_ID 
				AND i.index_id = ic.index_id 
				AND i.is_primary_key = 1 
				AND ic.OBJECT_ID = OBJECT_ID('src.Adjustment360EndNoteSubCategory')
			INNER JOIN sys.columns AS c 
				ON ic.object_id = c.object_id 
				AND ic.column_id = c.column_id
				AND c.name = 'EndnoteTypeId' )
BEGIN
	SET XACT_ABORT ON;

	--Drop PK
	ALTER TABLE src.Adjustment360EndNoteSubCategory
	DROP CONSTRAINT PK_Adjustment360EndNoteSubCategory;

	--Add new Column if not exists
	 IF NOT EXISTS ( SELECT  1
				FROM    sys.columns c 
				WHERE   object_id = OBJECT_ID(N'src.Adjustment360EndNoteSubCategory')
					AND NAME =  'EndnoteTypeId' )
	BEGIN
		ALTER TABLE src.Adjustment360EndNoteSubCategory ADD EndnoteTypeId TINYINT CONSTRAINT DF_Adjustment360EndNoteSubCategory_EndnoteTypeId DEFAULT(1) NOT NULL;
	END 

	--recreate pk
	ALTER TABLE src.Adjustment360EndNoteSubCategory ADD 
    CONSTRAINT PK_Adjustment360EndNoteSubCategory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ReasonNumber, EndnoteTypeId) WITH (DATA_COMPRESSION = PAGE) ON
    DP_Ods_PartitionScheme(OdsCustomerId);

    ALTER INDEX PK_Adjustment360EndNoteSubCategory ON src.Adjustment360EndNoteSubCategory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
END


-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1 
                FROM sys.stats
                WHERE name = 'PK_Adjustment360EndNoteSubCategory' 
                AND is_incremental = 1)  
BEGIN
ALTER INDEX PK_Adjustment360EndNoteSubCategory ON src.Adjustment360EndNoteSubCategory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 

END ;
GO


