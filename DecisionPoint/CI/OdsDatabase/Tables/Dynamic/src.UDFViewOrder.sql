IF OBJECT_ID('src.UDFViewOrder', 'U') IS NULL
BEGIN
    CREATE TABLE src.UDFViewOrder
        (
          OdsPostingGroupAuditId INT NOT NULL ,
          OdsCustomerId INT NOT NULL ,
          OdsCreateDate DATETIME2(7) NOT NULL ,
          OdsSnapshotDate DATETIME2(7) NOT NULL ,
          OdsRowIsCurrent BIT NOT NULL ,
          OdsHashbytesValue VARBINARY(8000) NULL,
          DmlOperation CHAR(1) NOT NULL ,
          OfficeId INT NOT NULL ,
          UDFIdNo INT NOT NULL ,
          ViewOrder SMALLINT NULL 
        ) ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (DATA_COMPRESSION = PAGE);

    ALTER TABLE src.UDFViewOrder ADD 
    CONSTRAINT PK_UDFViewOrder PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, OfficeId, UDFIdNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_UDFViewOrder ON src.UDFViewOrder REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_UDFViewOrder'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_UDFViewOrder ON src.UDFViewOrder REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
