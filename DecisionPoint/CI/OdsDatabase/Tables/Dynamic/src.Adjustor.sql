IF OBJECT_ID('src.Adjustor', 'U') IS NULL
BEGIN
    CREATE TABLE src.Adjustor
        (
          OdsPostingGroupAuditId INT NOT NULL ,
          OdsCustomerId INT NOT NULL ,
          OdsCreateDate DATETIME2(7) NOT NULL ,
          OdsSnapshotDate DATETIME2(7) NOT NULL ,
          OdsRowIsCurrent BIT NOT NULL ,
          OdsHashbytesValue VARBINARY(8000) NULL,
          DmlOperation CHAR(1) NOT NULL ,
          lAdjIdNo INT NOT NULL ,
          IDNumber VARCHAR(15) NULL ,
          Lastname VARCHAR(30) NULL ,
          FirstName VARCHAR(30) NULL ,
          Address1 VARCHAR(30) NULL ,
          Address2 VARCHAR(30) NULL ,
          City VARCHAR(30) NULL ,
          State VARCHAR(2) NULL ,
          ZipCode VARCHAR(12) NULL ,
          Phone VARCHAR(25) NULL ,
          Fax VARCHAR(25) NULL ,
          Office VARCHAR(120) NULL ,
          EMail VARCHAR(60) NULL ,
          InUse VARCHAR(100) NULL ,
          OfficeIdNo INT NULL ,
          UserId INT NULL ,
          CreateDate DATETIME NULL ,
          LastChangedOn DATETIME NULL 
        ) ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (DATA_COMPRESSION = PAGE);

    ALTER TABLE src.Adjustor ADD 
    CONSTRAINT PK_Adjustor PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, lAdjIdNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_Adjustor ON src.Adjustor REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Alter Office Column size to increase from 30 to 120
ALTER TABLE src.Adjustor
ALTER COLUMN Office VARCHAR(120);
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Adjustor'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Adjustor ON src.Adjustor REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
