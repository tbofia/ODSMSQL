
IF OBJECT_ID('src.StateSettingsOregon', 'U') IS NULL
    BEGIN
        CREATE TABLE src.StateSettingsOregon
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  StateSettingsOregonId TINYINT NOT NULL,
			  ApplyOregonFeeSchedule BIT NULL
              
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.StateSettingsOregon ADD 
        CONSTRAINT PK_StateSettingsOregon PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, StateSettingsOregonId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_StateSettingsOregon ON src.StateSettingsOregon REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

