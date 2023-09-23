IF OBJECT_ID('src.TreatmentCategory', 'U') IS NULL
    BEGIN
        CREATE TABLE src.TreatmentCategory
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  TreatmentCategoryId tinyint NOT NULL,
	          Category varchar(50) NULL,
	          Metadata nvarchar(max) NULL
	          
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.TreatmentCategory ADD 
        CONSTRAINT PK_TreatmentCategoryId PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,TreatmentCategoryId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_TreatmentCategoryId ON src.TreatmentCategory REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_TreatmentCategoryId'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_TreatmentCategoryId ON src.TreatmentCategory REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
