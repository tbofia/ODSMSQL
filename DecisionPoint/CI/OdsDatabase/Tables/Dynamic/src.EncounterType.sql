IF OBJECT_ID('src.EncounterType', 'U') IS NULL
    BEGIN
        CREATE TABLE src.EncounterType
            (
			 OdsPostingGroupAuditId INT NOT NULL ,
			 OdsCustomerId INT NOT NULL ,              
			 OdsCreateDate DATETIME2(7) NOT NULL ,
			 OdsSnapshotDate DATETIME2(7) NOT NULL ,
			 OdsRowIsCurrent BIT NOT NULL ,
			 OdsHashbytesValue VARBINARY(8000) NULL ,
			 DmlOperation CHAR(1) NOT NULL ,
			 EncounterTypeId TINYINT NOT NULL,
	         EncounterTypePriority TINYINT NULL,
	         [Description] VARCHAR(100) NULL,
	         NarrativeInformation VARCHAR(max) NULL
           )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.EncounterType ADD 
        CONSTRAINT PK_EncounterType PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, EncounterTypeId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_EncounterType ON src.EncounterType REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_EncounterType'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_EncounterType ON src.EncounterType REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO



