IF OBJECT_ID('src.DemandPackage', 'U') IS NULL
    BEGIN
        CREATE TABLE src.DemandPackage
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  DemandPackageId int NOT NULL,
			  DemandClaimantId int NULL,
			  RequestedByUserName varchar(15) NULL,
			  DateTimeReceived datetimeoffset(7) NULL,
			  CorrelationId varchar(36) NULL,
			  [PageCount] smallint NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.DemandPackage ADD 
        CONSTRAINT PK_DemandPackage PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,DemandPackageId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_DemandPackage ON src.DemandPackage REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_DemandPackage'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_DemandPackage ON src.DemandPackage REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
