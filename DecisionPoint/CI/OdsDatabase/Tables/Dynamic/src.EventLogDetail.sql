IF OBJECT_ID('src.EventLogDetail', 'U') IS NULL
    BEGIN
        CREATE TABLE src.EventLogDetail
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  EventLogDetailId int NOT NULL,
	          EventLogId int NULL,
	          PropertyName varchar(50) NULL,
	          OldValue varchar(max) NULL,
	          NewValue varchar(max) NULL
	          
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.EventLogDetail ADD 
        CONSTRAINT PK_EventLogDetail PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,EventLogDetailId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_EventLogDetail ON src.EventLogDetail REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_EventLogDetail'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_EventLogDetail ON src.EventLogDetail REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
