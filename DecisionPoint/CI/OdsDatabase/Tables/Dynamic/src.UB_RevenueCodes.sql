IF OBJECT_ID('src.UB_RevenueCodes', 'U') IS NULL
    BEGIN
        CREATE TABLE src.UB_RevenueCodes
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL , 
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              RevenueCode VARCHAR(4) NOT NULL,
			  StartDate DATETIME NOT NULL,
			  EndDate DATETIME NULL,
			  PRC_DESC VARCHAR(MAX) NULL,
			  Flags INT NULL,
			  Vague VARCHAR(1) NULL,
			  PerVisit SMALLINT NULL,
			  PerClaimant SMALLINT NULL,
			  PerProvider SMALLINT NULL,
			  BodyFlags INT NULL,
			  DrugFlag SMALLINT NULL,
			  CurativeFlag SMALLINT NULL,
			  RevenueCodeSubCategoryId TINYINT NULL
             
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.UB_RevenueCodes ADD 
        CONSTRAINT PK_UB_RevenueCodes PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, RevenueCode, StartDate) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_UB_RevenueCodes ON src.UB_RevenueCodes REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.UB_RevenueCodes')
                        AND NAME = 'RevenueCodeSubCategoryId' )
    BEGIN
        ALTER TABLE src.UB_RevenueCodes ADD RevenueCodeSubCategoryId TINYINT NULL;
    END;
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_UB_RevenueCodes'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_UB_RevenueCodes ON src.UB_RevenueCodes REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO


