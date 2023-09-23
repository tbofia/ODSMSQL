IF OBJECT_ID('src.Bill_History', 'U') IS NULL
    BEGIN
        CREATE TABLE src.Bill_History
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              BillIdNo INT NOT NULL ,
              SeqNo INT NOT NULL ,
              DateCommitted DATETIME NULL ,
              AmtCommitted MONEY NULL ,
              UserId VARCHAR(15) NULL ,
              AmtCoPay MONEY NULL ,
              AmtDeductible MONEY NULL ,
              Flags INT NULL ,
              AmtSalesTax MONEY NULL ,
              AmtOtherTax MONEY NULL ,
              DeductibleOverride BIT NULL ,
			  PricingState VARCHAR(2) NULL,
			  ApportionmentPercentage DECIMAL(5,2) NULL,
			  FloridaDeductibleRuleEligible BIT NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Bill_History ADD 
        CONSTRAINT PK_Bill_History PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIdNo, SeqNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Bill_History ON src.Bill_History REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Add column to src.Bill_History.
IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.Bill_History')
                        AND NAME = 'PricingState' )
BEGIN
    ALTER TABLE src.Bill_History ADD PricingState VARCHAR(2) NULL
END
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.Bill_History')
                        AND NAME = 'ApportionmentPercentage' )
BEGIN
    ALTER TABLE src.Bill_History ADD ApportionmentPercentage DECIMAL(5,2) NULL
END
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bill_History')
						AND NAME = 'FloridaDeductibleRuleEligible' )
	BEGIN
		ALTER TABLE src.Bill_History ADD FloridaDeductibleRuleEligible BIT NULL ;
	END ; 
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Bill_History'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Bill_History ON src.Bill_History REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
