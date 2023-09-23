IF OBJECT_ID('src.PlaceOfServiceDictionary', 'U') IS NULL
    BEGIN
        CREATE TABLE src.PlaceOfServiceDictionary
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL , 
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              PlaceOfServiceCode SMALLINT NOT NULL,
			  [Description] VARCHAR(255) NULL,
	          Facility SMALLINT NULL,
	          MHL SMALLINT NULL,
	          PlusFour SMALLINT NULL,
	          Institution INT NULL,
	          StartDate DATETIME2(7) NOT NULL,
	          EndDate DATETIME2(7) NULL
             
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.PlaceOfServiceDictionary ADD 
        CONSTRAINT PK_PlaceOfServiceDictionary PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, PlaceOfServiceCode, StartDate) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_PlaceOfServiceDictionary ON src.PlaceOfServiceDictionary REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_PlaceOfServiceDictionary'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_PlaceOfServiceDictionary ON src.PlaceOfServiceDictionary REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO


