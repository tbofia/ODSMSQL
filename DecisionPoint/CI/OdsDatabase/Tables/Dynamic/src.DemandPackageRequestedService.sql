IF OBJECT_ID('src.DemandPackageRequestedService', 'U') IS NULL
    BEGIN
        CREATE TABLE src.DemandPackageRequestedService
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  DemandPackageRequestedServiceId int NOT NULL,
	          DemandPackageId int NULL,
	          ReviewRequestOptions nvarchar(max) NULL
	          
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.DemandPackageRequestedService ADD 
        CONSTRAINT PK_DemandPackageRequestedService PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,DemandPackageRequestedServiceId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_DemandPackageRequestedService ON src.DemandPackageRequestedService REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_DemandPackageRequestedService'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_DemandPackageRequestedService ON src.DemandPackageRequestedService REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

