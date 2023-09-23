IF OBJECT_ID('src.UDF_Sentry_Criteria', 'U') IS NULL
BEGIN
    CREATE TABLE src.UDF_Sentry_Criteria
        (
          OdsPostingGroupAuditId INT NOT NULL ,
          OdsCustomerId INT NOT NULL ,
          OdsCreateDate DATETIME2(7) NOT NULL ,
          OdsSnapshotDate DATETIME2(7) NOT NULL ,
          OdsRowIsCurrent BIT NOT NULL ,
          OdsHashbytesValue VARBINARY(8000) NULL,
          DmlOperation CHAR(1) NOT NULL ,
          UdfIdNo INT NULL ,
          CriteriaID INT NOT NULL ,
          ParentName VARCHAR(50) NULL ,
          Name VARCHAR(50) NULL ,
          Description VARCHAR(1000) NULL ,
          Operators VARCHAR(50) NULL ,
          PredefinedValues VARCHAR(MAX) NULL ,
          ValueDataType VARCHAR(50) NULL ,
          ValueFormat VARCHAR(50) NULL 
        ) ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (DATA_COMPRESSION = PAGE);

    ALTER TABLE src.UDF_Sentry_Criteria ADD 
    CONSTRAINT PK_UDF_Sentry_Criteria PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, CriteriaID) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_UDF_Sentry_Criteria ON src.UDF_Sentry_Criteria REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_UDF_Sentry_Criteria'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_UDF_Sentry_Criteria ON src.UDF_Sentry_Criteria REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
