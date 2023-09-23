IF OBJECT_ID('src.pa_PlaceOfService', 'U') IS NULL
    BEGIN
        CREATE TABLE src.pa_PlaceOfService
            (
			OdsPostingGroupAuditId INT NOT NULL ,
			OdsCustomerId INT NOT NULL ,
			OdsCreateDate DATETIME2(7) NOT NULL ,
			OdsSnapshotDate DATETIME2(7) NOT NULL ,
			OdsRowIsCurrent BIT NOT NULL ,
			OdsHashbytesValue VARBINARY(8000) NULL ,
			DmlOperation CHAR(1) NOT NULL ,
			POS SMALLINT NOT NULL,
			Description VARCHAR(255) NULL,
			Facility SMALLINT NULL,
			MHL SMALLINT NULL,
			PlusFour SMALLINT NULL,
			Institution INT NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.pa_PlaceOfService ADD 
        CONSTRAINT PK_pa_PlaceOfService PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, POS) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_pa_PlaceOfService ON src.pa_PlaceOfService REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_pa_PlaceOfService'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_pa_PlaceOfService ON src.pa_PlaceOfService REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
