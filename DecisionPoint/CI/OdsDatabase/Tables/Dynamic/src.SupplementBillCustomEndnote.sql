
IF OBJECT_ID('src.SupplementBillCustomEndnote', 'U') IS NULL
    BEGIN
        CREATE TABLE src.SupplementBillCustomEndnote
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              BillId INT NOT NULL,
			  SequenceNumber SMALLINT NOT NULL ,
              LineNumber SMALLINT NOT NULL,
              Endnote INT NOT NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.SupplementBillCustomEndnote ADD 
        CONSTRAINT PK_SupplementBillCustomEndnote PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillId, SequenceNumber, LineNumber, Endnote) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_SupplementBillCustomEndnote ON src.SupplementBillCustomEndnote REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO


