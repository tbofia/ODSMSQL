IF OBJECT_ID('src.UDFListValues', 'U') IS NULL
BEGIN
    CREATE TABLE src.UDFListValues
        (
          OdsPostingGroupAuditId INT NOT NULL ,
          OdsCustomerId INT NOT NULL ,
          OdsCreateDate DATETIME2(7) NOT NULL ,
          OdsSnapshotDate DATETIME2(7) NOT NULL ,
          OdsRowIsCurrent BIT NOT NULL ,
          OdsHashbytesValue VARBINARY(8000) NULL,
          DmlOperation CHAR(1) NOT NULL ,
          ListValueIdNo INT NOT NULL ,
          UDFIdNo INT NULL ,
          SeqNo SMALLINT NULL ,
          ListValue VARCHAR(50) NULL ,
          DefaultValue SMALLINT NULL 
        ) ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (DATA_COMPRESSION = PAGE);

    ALTER TABLE src.UDFListValues ADD 
    CONSTRAINT PK_UDFListValues PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ListValueIdNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_UDFListValues ON src.UDFListValues REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_UDFListValues'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_UDFListValues ON src.UDFListValues REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
