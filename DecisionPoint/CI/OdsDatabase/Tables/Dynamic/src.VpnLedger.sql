IF OBJECT_ID('src.VpnLedger', 'U') IS NULL
BEGIN
	CREATE TABLE src.VpnLedger (
		OdsPostingGroupAuditId INT NOT NULL
		,OdsCustomerId INT NOT NULL
		,OdsCreateDate DATETIME2(7) NOT NULL
		,OdsSnapshotDate DATETIME2(7) NOT NULL
		,OdsRowIsCurrent BIT NOT NULL
		,OdsHashbytesValue VARBINARY(8000) NULL
		,DmlOperation CHAR(1) NOT NULL
		,TransactionID BIGINT NOT NULL
		,TransactionTypeID INT NULL
		,BillIdNo INT NULL
		,Line_No SMALLINT NULL
		,Charged MONEY NULL
		,DPAllowed MONEY NULL
		,VPNAllowed MONEY NULL
		,Savings MONEY NULL
		,Credits MONEY NULL
		,HasOverride BIT NULL
		,EndNotes NVARCHAR(200)
		,NetworkIdNo INT NULL
		,ProcessFlag SMALLINT NULL
		,LineType INT NULL
		,DateTimeStamp DATETIME NULL
		,SeqNo INT NULL
		,VPN_Ref_Line_No SMALLINT NULL
		,SpecialProcessing BIT NULL
		,CreateDate DATETIME2 NULL
		,LastChangedOn DATETIME2 NULL
		) ON DP_Ods_PartitionScheme (OdsCustomerId)
		WITH (DATA_COMPRESSION = PAGE);

	ALTER TABLE src.VpnLedger ADD CONSTRAINT PK_VpnLedger PRIMARY KEY CLUSTERED (
		OdsPostingGroupAuditId
		,OdsCustomerId
		,TransactionID
		)
		WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_VpnLedger ON src.VpnLedger REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.VpnLedger')
						AND NAME = 'AdjustedCharged' )
	BEGIN
		ALTER TABLE src.VpnLedger ADD AdjustedCharged DECIMAL(19,4) NULL ;
	END ; 
GO


-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_VpnLedger'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_VpnLedger ON src.VpnLedger REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO


