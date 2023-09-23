IF OBJECT_ID('src.Prf_OfficeUDF', 'U') IS NULL
BEGIN
    CREATE TABLE src.Prf_OfficeUDF
        (
          OdsPostingGroupAuditId INT NOT NULL ,
          OdsCustomerId INT NOT NULL ,
          OdsCreateDate DATETIME2(7) NOT NULL ,
          OdsSnapshotDate DATETIME2(7) NOT NULL ,
          OdsRowIsCurrent BIT NOT NULL ,
          OdsHashbytesValue VARBINARY(8000) NULL,
          DmlOperation CHAR(1) NOT NULL ,
          OfficeId INT NOT NULL ,
          UDFIdNo INT NOT NULL 
        ) ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (DATA_COMPRESSION = PAGE);

    ALTER TABLE src.Prf_OfficeUDF ADD 
    CONSTRAINT PK_Prf_OfficeUDF PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, OfficeId, UDFIdNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_Prf_OfficeUDF ON src.Prf_OfficeUDF REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Prf_OfficeUDF'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Prf_OfficeUDF ON src.Prf_OfficeUDF REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
