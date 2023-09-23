IF OBJECT_ID('src.rsn_REASONS', 'U') IS NULL
    BEGIN
        CREATE TABLE src.rsn_REASONS
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              ReasonNumber INT NOT NULL ,
              CV_Type VARCHAR(2) NULL ,
              ShortDesc VARCHAR(50) NULL ,
              LongDesc VARCHAR(MAX) NULL ,
              CategoryIdNo INT NULL ,
              COAIndex SMALLINT NULL ,
              OverrideEndnote INT NULL ,
              HardEdit SMALLINT NULL ,
              SpecialProcessing BIT NULL ,
              EndnoteActionId TINYINT NULL ,
              RetainForEapg BIT NULL
            )
        ON  DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.rsn_REASONS ADD 
        CONSTRAINT PK_rsn_REASONS PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ReasonNumber) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_rsn_REASONS ON src.rsn_REASONS REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END;
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.rsn_REASONS')
                        AND NAME = 'EndnoteActionId' )
    BEGIN
        ALTER TABLE src.rsn_REASONS ADD EndnoteActionId TINYINT NULL;
    END;
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.rsn_REASONS')
                        AND NAME = 'RetainForEapg' )
    BEGIN
        ALTER TABLE src.rsn_REASONS ADD RetainForEapg BIT NULL;
    END;
GO

IF EXISTS ( SELECT  1
            FROM    sys.columns c
                    INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
            WHERE   c.object_id = OBJECT_ID(N'src.rsn_REASONS')
                    AND c.name = 'ShortDesc'
                    AND NOT ( t.name = 'VARCHAR'
                              AND c.max_length = 50
                            ) )
    BEGIN
        ALTER TABLE src.rsn_REASONS ALTER COLUMN ShortDesc VARCHAR(50) NULL;
    END;
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_rsn_REASONS'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_rsn_REASONS ON src.rsn_REASONS REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

