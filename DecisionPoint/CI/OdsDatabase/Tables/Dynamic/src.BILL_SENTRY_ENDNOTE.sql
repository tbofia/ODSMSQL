IF OBJECT_ID('src.BILL_SENTRY_ENDNOTE', 'U') IS NULL
BEGIN
    CREATE TABLE src.BILL_SENTRY_ENDNOTE
        (
          OdsPostingGroupAuditId INT NOT NULL ,
          OdsCustomerId INT NOT NULL ,
          OdsCreateDate DATETIME2(7) NOT NULL ,
          OdsSnapshotDate DATETIME2(7) NOT NULL ,
          OdsRowIsCurrent BIT NOT NULL ,
          OdsHashbytesValue VARBINARY(8000) NULL,
          DmlOperation CHAR(1) NOT NULL ,
          BillID INT NOT NULL ,
          Line INT NOT NULL ,
          RuleID INT NOT NULL ,
          PercentDiscount REAL NULL ,
          ActionId SMALLINT NULL 
        ) ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (DATA_COMPRESSION = PAGE);

    ALTER TABLE src.BILL_SENTRY_ENDNOTE ADD 
    CONSTRAINT PK_BILL_SENTRY_ENDNOTE PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillID, Line, RuleID) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_BILL_SENTRY_ENDNOTE ON src.BILL_SENTRY_ENDNOTE REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_BILL_SENTRY_ENDNOTE'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_BILL_SENTRY_ENDNOTE ON src.BILL_SENTRY_ENDNOTE REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
