
IF OBJECT_ID('src.VPNBillableFlags', 'U') IS NULL
BEGIN
	CREATE TABLE src.VPNBillableFlags(
		OdsPostingGroupAuditId INT NOT NULL ,
		OdsCustomerId INT NOT NULL ,
		OdsCreateDate DATETIME2(7) NOT NULL ,
		OdsSnapshotDate DATETIME2(7) NOT NULL ,
		OdsRowIsCurrent BIT NOT NULL ,
		OdsHashbytesValue VARBINARY(8000) NULL,
		DmlOperation CHAR(1) NOT NULL ,
		SOJ nchar(2) NOT NULL,
		NetworkID int NOT NULL,
		ActivityFlag nchar(2) NOT NULL,
		Billable nchar(1) NULL,
		CompanyCode varchar(10) NOT NULL,
		CompanyName varchar(100) NULL,
	)ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (DATA_COMPRESSION = PAGE);
        
 ALTER TABLE src.VPNBillableFlags ADD 
 CONSTRAINT PK_VPNBillableFlags PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,CompanyCode,SOJ,NetworkID,ActivityFlag) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);
 
 ALTER INDEX PK_VPNBillableFlags ON src.VPNBillableFlags REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_VPNBillableFlags'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_VPNBillableFlags ON src.VPNBillableFlags REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

