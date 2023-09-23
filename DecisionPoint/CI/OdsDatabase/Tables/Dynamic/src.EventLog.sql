IF OBJECT_ID('src.EventLog', 'U') IS NULL
    BEGIN
        CREATE TABLE src.EventLog
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  EventLogId int NOT NULL,
	          ObjectName varchar(50) NULL,
	          ObjectId int NULL,
	          UserName varchar(15) NULL,
	          LogDate datetimeoffset(7) NULL,
	          ActionName varchar(20) NULL,
	          OrganizationId nvarchar(100) NULL
	          
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.EventLog ADD 
        CONSTRAINT PK_EventLog PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,EventLogId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_EventLog ON src.EventLog REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_EventLog'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_EventLog ON src.EventLog REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
