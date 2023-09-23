IF OBJECT_ID('src.lkp_SPC', 'U') IS NULL
    BEGIN
        CREATE TABLE src.lkp_SPC
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              lkp_SpcId INT NOT NULL ,
              LongName VARCHAR(50) NULL ,
              ShortName VARCHAR(4) NULL ,
              Mult MONEY NULL ,
              NCD92 SMALLINT NULL ,
              NCD93 SMALLINT NULL ,
              PlusFour SMALLINT NULL 
              
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.lkp_SPC ADD 
        CONSTRAINT PK_lkp_SPC PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, lkp_SpcId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_lkp_SPC ON src.lkp_SPC REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- The following fields became nullable in v1.1
IF EXISTS ( SELECT  1
            FROM    sys.columns
            WHERE   object_id = OBJECT_ID('src.lkp_SPC')
                    AND name = 'LongName'
                    AND is_nullable = 0 )
    ALTER TABLE src.lkp_SPC ALTER COLUMN Longname VARCHAR(50) NULL;
GO

IF EXISTS ( SELECT  1
            FROM    sys.columns
            WHERE   object_id = OBJECT_ID('src.lkp_SPC')
                    AND name = 'ShortName'
                    AND is_nullable = 0 )
    ALTER TABLE src.lkp_SPC ALTER COLUMN ShortName VARCHAR(4) NULL;
GO

IF EXISTS ( SELECT  1
            FROM    sys.columns
            WHERE   object_id = OBJECT_ID('src.lkp_SPC')
                    AND name = 'Mult'
                    AND is_nullable = 0 )
    ALTER TABLE src.lkp_SPC ALTER COLUMN Mult MONEY NULL;
GO

IF EXISTS ( SELECT  1
            FROM    sys.columns
            WHERE   object_id = OBJECT_ID('src.lkp_SPC')
                    AND name = 'NCD92'
                    AND is_nullable = 0 )
    ALTER TABLE src.lkp_SPC ALTER COLUMN NCD92 SMALLINT NULL;
GO

IF EXISTS ( SELECT  1
            FROM    sys.columns
            WHERE   object_id = OBJECT_ID('src.lkp_SPC')
                    AND name = 'NCD93'
                    AND is_nullable = 0 )
    ALTER TABLE src.lkp_SPC ALTER COLUMN NCD93 SMALLINT NULL;
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.lkp_SPC')
						AND NAME = 'CbreSpecialtyCode' )
	BEGIN
		ALTER TABLE src.lkp_SPC ADD CbreSpecialtyCode VARCHAR(12) NULL ;
	END ; 
GO


-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_lkp_SPC'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_lkp_SPC ON src.lkp_SPC REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

