
IF OBJECT_ID('src.StateSettingsOregonCoverageType', 'U') IS NULL
    BEGIN
        CREATE TABLE src.StateSettingsOregonCoverageType
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  StateSettingsOregonId TINYINT NOT NULL,
			  CoverageType VARCHAR(2) NOT NULL
              
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.StateSettingsOregonCoverageType ADD 
        CONSTRAINT PK_StateSettingsOregonCoverageType PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, StateSettingsOregonId, CoverageType) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_StateSettingsOregonCoverageType ON src.StateSettingsOregonCoverageType REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO
