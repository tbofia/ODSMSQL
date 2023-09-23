
IF OBJECT_ID('src.ApportionmentEndnote', 'U') IS NULL
    BEGIN
        CREATE TABLE src.ApportionmentEndnote
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              ApportionmentEndnote INT NOT NULL,
              ShortDescription VARCHAR(50) NULL,
              LongDescription VARCHAR(500) NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.ApportionmentEndnote ADD 
        CONSTRAINT PK_ApportionmentEndnote PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ApportionmentEndnote) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_ApportionmentEndnote ON src.ApportionmentEndnote REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO
