IF OBJECT_ID('src.VPNActivityFlag', 'U') IS NULL
BEGIN
	CREATE TABLE src.VPNActivityFlag(
		OdsPostingGroupAuditId INT NOT NULL ,
		OdsCustomerId INT NOT NULL ,
		OdsCreateDate DATETIME2(7) NOT NULL ,
		OdsSnapshotDate DATETIME2(7) NOT NULL ,
		OdsRowIsCurrent BIT NOT NULL ,
		OdsHashbytesValue VARBINARY(8000) NULL,
		DmlOperation CHAR(1) NOT NULL ,
		Activity_Flag VARCHAR(1) NOT NULL ,
	    AF_Description VARCHAR(50) NULL ,
	    AF_ShortDesc VARCHAR(50) NULL ,
		Data_Source VARCHAR(5) NULL ,
		Default_Billable BIT NULL ,
		Credit BIT NULL
	)ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (DATA_COMPRESSION = PAGE);
        
 ALTER TABLE src.VPNActivityFlag ADD 
 CONSTRAINT PK_VPNActivityFlag PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,Activity_Flag) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);
 
 ALTER INDEX PK_VPNActivityFlag ON src.VPNActivityFlag REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_VPNActivityFlag'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_VPNActivityFlag ON src.VPNActivityFlag REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO


