IF OBJECT_ID('src.lkp_TS', 'U') IS NULL
    BEGIN
        CREATE TABLE src.lkp_TS
            (
			OdsPostingGroupAuditId INT NOT NULL ,
			OdsCustomerId INT NOT NULL ,
			OdsCreateDate DATETIME2(7) NOT NULL ,
			OdsSnapshotDate DATETIME2(7) NOT NULL ,
			OdsRowIsCurrent BIT NOT NULL ,
			OdsHashbytesValue VARBINARY(8000) NULL ,
			DmlOperation CHAR(1) NOT NULL ,
			ShortName VARCHAR(2) NOT NULL,
			StartDate  DATETIME2(7) NOT NULL,
			EndDate  DATETIME2(7) NULL,
			LongName VARCHAR(100) NULL,
			Global SMALLINT NULL,
			AnesMedDirect SMALLINT NULL,
			AffectsPricing SMALLINT NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.lkp_TS ADD 
        CONSTRAINT PK_lkp_TS PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ShortName, StartDate) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_lkp_TS ON src.lkp_TS REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.lkp_TS')
						AND NAME = 'IsAssistantSurgery' )
	BEGIN
		ALTER TABLE src.lkp_TS ADD IsAssistantSurgery BIT NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.lkp_TS')
						AND NAME = 'IsCoSurgeon' )
	BEGIN
		ALTER TABLE src.lkp_TS ADD IsCoSurgeon BIT NULL ;
	END ; 
GO

 
IF  EXISTS ( SELECT  1
			FROM    sys.columns c 
					INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
			WHERE   object_id = OBJECT_ID(N'src.lkp_TS')
					AND c.name = 'StartDate' 
					AND NOT ( t.name = 'DATETIME2' 
						 AND c.max_length = '7'
						   ) ) 
	--Drop PK key and Index and Alter the Column and Add the PK and Index Back
	BEGIN
		ALTER TABLE src.lkp_TS DROP CONSTRAINT PK_lkp_TS;
		DROP INDEX IF EXISTS PK_lkp_TS ON src.lkp_TS;
		DROP INDEX IF EXISTS IX_ShortName_StartDate_OdsCustomerId_OdsPostingGroupAuditId ON src.lkp_TS;
		DROP INDEX IF EXISTS IX_OdsPostingGroupAuditId_DmlOperation ON src.lkp_TS;
		DROP INDEX IF EXISTS IX_OdsCustomerId_OdsRowIsCurrent ON src.lkp_TS;

		ALTER TABLE src.lkp_TS ALTER COLUMN StartDate DATETIME2(7) NOT NULL ;
		ALTER TABLE src.lkp_TS ADD 
		CONSTRAINT PK_lkp_TS PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ShortName, StartDate) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);
	END ; 
GO		

IF  EXISTS ( SELECT  1
			FROM    sys.columns c 
					INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
			WHERE   object_id = OBJECT_ID(N'src.lkp_TS')
					AND c.name = 'EndDate' 
					AND NOT ( t.name = 'DATETIME2' 
						 AND c.max_length = '7'
						   ) ) 
	BEGIN
		ALTER TABLE src.lkp_TS ALTER COLUMN EndDate DATETIME2(7) NULL ;
	END ; 
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_lkp_TS'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_lkp_TS ON src.lkp_TS REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO



