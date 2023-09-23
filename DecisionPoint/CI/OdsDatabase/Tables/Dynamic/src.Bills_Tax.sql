IF OBJECT_ID('src.Bills_Tax', 'U') IS NULL
    BEGIN
        CREATE TABLE src.Bills_Tax
            (
			OdsPostingGroupAuditId INT NOT NULL ,
			OdsCustomerId INT NOT NULL ,
			OdsCreateDate DATETIME2(7) NOT NULL ,
			OdsSnapshotDate DATETIME2(7) NOT NULL ,
			OdsRowIsCurrent BIT NOT NULL ,
			OdsHashbytesValue VARBINARY(8000) NULL ,
			DmlOperation CHAR(1) NOT NULL ,
			BillsTaxId INT NOT NULL,
			TableType SMALLINT NULL,
			BillIdNo INT NULL,
			Line_No SMALLINT NULL,
			SeqNo SMALLINT NULL,
			TaxTypeId SMALLINT NULL,
			ImportTaxRate DECIMAL(5, 5) NULL,
			Tax MONEY NULL,
			OverridenTax MONEY NULL,
			ImportTaxAmount MONEY NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Bills_Tax ADD 
        CONSTRAINT PK_Bills_Tax PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillsTaxId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Bills_Tax ON src.Bills_Tax REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Bills_Tax'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Bills_Tax ON src.Bills_Tax REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
