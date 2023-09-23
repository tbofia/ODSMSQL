
IF OBJECT_ID('src.UDFLevelChangeTracking', 'U') IS NULL
    BEGIN
        CREATE TABLE src.UDFLevelChangeTracking
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  UDFLevelChangeTrackingId INT NOT NULL,
			  EntityType INT NULL,
			  EntityId INT NULL,
			  CorrelationId VARCHAR(50) NULL,
			  UDFId INT NULL,  
			  PreviousValue VARCHAR(MAX) NULL,
			  UpdatedValue VARCHAR(MAX) NULL,
              UserId INT NULL,
			  ChangeDate DATETIME2 NULL              
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.UDFLevelChangeTracking ADD 
        CONSTRAINT PK_UDFLevelChangeTracking PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, UDFLevelChangeTrackingId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_UDFLevelChangeTracking ON src.UDFLevelChangeTracking REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO
