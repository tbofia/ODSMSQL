IF OBJECT_ID('src.InjuryNature', 'U') IS NULL
    BEGIN
        CREATE TABLE src.InjuryNature
            (
			 OdsPostingGroupAuditId INT NOT NULL ,
			 OdsCustomerId INT NOT NULL ,              
			 OdsCreateDate DATETIME2(7) NOT NULL ,
			 OdsSnapshotDate DATETIME2(7) NOT NULL ,
			 OdsRowIsCurrent BIT NOT NULL ,
			 OdsHashbytesValue VARBINARY(8000) NULL ,
			 DmlOperation CHAR(1) NOT NULL ,
			 InjuryNatureId TINYINT NOT NULL,
	         InjuryNaturePriority TINYINT NULL,
	         [Description] VARCHAR(100) NULL,
	         NarrativeInformation VARCHAR(max) NULL
           )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.InjuryNature ADD 
        CONSTRAINT PK_InjuryNature PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, InjuryNatureId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_InjuryNature ON src.InjuryNature REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_InjuryNature'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_InjuryNature ON src.InjuryNature REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO



