IF OBJECT_ID('src.TreatmentCategoryRange', 'U') IS NULL
    BEGIN
        CREATE TABLE src.TreatmentCategoryRange
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  TreatmentCategoryRangeId int NOT NULL,
	          TreatmentCategoryId tinyint NULL,
	          StartRange varchar(7) NULL,
	          EndRange varchar(7) NULL
	          
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.TreatmentCategoryRange ADD 
        CONSTRAINT PK_TreatmentCategoryRangeId PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,TreatmentCategoryRangeId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_TreatmentCategoryRangeId ON src.TreatmentCategoryRange REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_TreatmentCategoryRangeId'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_TreatmentCategoryRangeId ON src.TreatmentCategoryRange REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
