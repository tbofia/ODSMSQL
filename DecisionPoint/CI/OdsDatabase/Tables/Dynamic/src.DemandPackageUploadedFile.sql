IF OBJECT_ID('src.DemandPackageUploadedFile', 'U') IS NULL
    BEGIN
        CREATE TABLE src.DemandPackageUploadedFile
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  DemandPackageUploadedFileId int NOT NULL,
	          DemandPackageId int NULL,
	          [FileName] varchar(255) NULL,
	          Size int NULL,
	          DocStoreId varchar(50) NULL
	          
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.DemandPackageUploadedFile ADD 
        CONSTRAINT PK_DemandPackageUploadedFile PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,DemandPackageUploadedFileId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_DemandPackageUploadedFile ON src.DemandPackageUploadedFile REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_DemandPackageUploadedFile'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_DemandPackageUploadedFile ON src.DemandPackageUploadedFile REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

