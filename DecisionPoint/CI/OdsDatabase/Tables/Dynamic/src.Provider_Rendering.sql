IF OBJECT_ID('src.Provider_Rendering', 'U') IS NULL
BEGIN
    CREATE TABLE src.Provider_Rendering
        (
          OdsPostingGroupAuditId INT NOT NULL ,
          OdsCustomerId INT NOT NULL ,
          OdsCreateDate DATETIME2(7) NOT NULL ,
          OdsSnapshotDate DATETIME2(7) NOT NULL ,
          OdsRowIsCurrent BIT NOT NULL ,
          OdsHashbytesValue VARBINARY(8000) NULL,
          DmlOperation CHAR(1) NOT NULL ,
          PvdIDNo INT NOT NULL ,
          RenderingAddr1 VARCHAR(55) NULL ,
          RenderingAddr2 VARCHAR(55) NULL ,
          RenderingCity VARCHAR(30) NULL ,
          RenderingState VARCHAR(2) NULL ,
          RenderingZip VARCHAR(12) NULL 
        ) ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (DATA_COMPRESSION = PAGE);

    ALTER TABLE src.Provider_Rendering ADD 
    CONSTRAINT PK_Provider_Rendering PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, PvdIDNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_Provider_Rendering ON src.Provider_Rendering REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Provider_Rendering'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Provider_Rendering ON src.Provider_Rendering REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
