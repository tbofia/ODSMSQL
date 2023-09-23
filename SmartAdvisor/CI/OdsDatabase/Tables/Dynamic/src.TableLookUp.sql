IF OBJECT_ID('src.TableLookUp', 'U') IS NULL
    BEGIN
        CREATE TABLE src.TableLookUp
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              TableCode CHAR(4) NOT NULL,
              TypeCode CHAR(4) NOT NULL,
              Code CHAR(12) NOT NULL,
              SiteCode CHAR(3) NOT NULL,
              OldCode VARCHAR(12) NULL,
              ShortDesc VARCHAR(40) NULL,
              Source CHAR(1) NULL,
              Priority SMALLINT NULL,
              LongDesc VARCHAR(6000) NULL,
              OwnerApp CHAR(1) NULL,
              RecordStatus CHAR(1) NULL,
			  CreateDate DATETIME NULL,
			  CreateUserID CHAR(2) NULL,
			  ModDate DATETIME NULL,
			  ModUserID VARCHAR(2) NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.TableLookUp ADD 
        CONSTRAINT PK_TableLookUp PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,TableCode,TypeCode,Code,SiteCode) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);
		
		ALTER INDEX PK_TableLookUp ON src.TableLookUp REBUILD WITH(STATISTICS_INCREMENTAL = ON);

	END
GO

