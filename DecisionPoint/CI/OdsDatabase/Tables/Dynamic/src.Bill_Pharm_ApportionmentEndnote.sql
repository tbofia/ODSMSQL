
IF OBJECT_ID('src.Bill_Pharm_ApportionmentEndnote', 'U') IS NULL
    BEGIN
        CREATE TABLE src.Bill_Pharm_ApportionmentEndnote
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              BillId INT NOT NULL,
              LineNumber SMALLINT NOT NULL,
              Endnote INT NOT NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Bill_Pharm_ApportionmentEndnote ADD 
        CONSTRAINT PK_Bill_Pharm_ApportionmentEndnote PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillId , LineNumber, Endnote) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Bill_Pharm_ApportionmentEndnote ON src.Bill_Pharm_ApportionmentEndnote REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO
