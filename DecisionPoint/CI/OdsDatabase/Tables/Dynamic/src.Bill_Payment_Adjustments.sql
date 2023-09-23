IF OBJECT_ID('src.Bill_Payment_Adjustments', 'U') IS NULL
    BEGIN
        CREATE TABLE src.Bill_Payment_Adjustments
            (
			OdsPostingGroupAuditId INT NOT NULL ,
			OdsCustomerId INT NOT NULL ,
			OdsCreateDate DATETIME2(7) NOT NULL ,
			OdsSnapshotDate DATETIME2(7) NOT NULL ,
			OdsRowIsCurrent BIT NOT NULL ,
			OdsHashbytesValue VARBINARY(8000) NULL ,
			DmlOperation CHAR(1) NOT NULL ,
			Bill_Payment_Adjustment_ID int NOT NULL,
			BillIDNo INT NULL,
			SeqNo SMALLINT NULL,
			InterestFlags INT NULL,
			DateInterestStarts DATETIME NULL,
			DateInterestEnds DATETIME NULL,
			InterestAdditionalInfoReceived DATETIME NULL,
			Interest MONEY NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Bill_Payment_Adjustments ADD 
        CONSTRAINT PK_Bill_Payment_Adjustments PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Bill_Payment_Adjustment_ID) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Bill_Payment_Adjustments ON src.Bill_Payment_Adjustments REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO
IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.Bill_Payment_Adjustments')
                        AND NAME = 'Comments' )
BEGIN
    ALTER TABLE src.Bill_Payment_Adjustments ADD Comments VARCHAR(1000) NULL 
END
GO


-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Bill_Payment_Adjustments'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Bill_Payment_Adjustments ON src.Bill_Payment_Adjustments REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
