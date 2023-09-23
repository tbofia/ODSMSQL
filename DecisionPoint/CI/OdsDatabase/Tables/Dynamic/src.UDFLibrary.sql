IF OBJECT_ID('src.UDFLibrary', 'U') IS NULL
BEGIN
    CREATE TABLE src.UDFLibrary
        (
          OdsPostingGroupAuditId INT NOT NULL ,
          OdsCustomerId INT NOT NULL ,
          OdsCreateDate DATETIME2(7) NOT NULL ,
          OdsSnapshotDate DATETIME2(7) NOT NULL ,
          OdsRowIsCurrent BIT NOT NULL ,
          OdsHashbytesValue VARBINARY(8000) NULL,
          DmlOperation CHAR(1) NOT NULL ,
          UDFIdNo INT NOT NULL ,
          UDFName VARCHAR(50) NULL ,
          ScreenType SMALLINT NULL ,
          UDFDescription VARCHAR(1000) NULL ,
          DataFormat SMALLINT NULL ,
          RequiredField SMALLINT NULL ,
          ReadOnly SMALLINT NULL ,
          Invisible SMALLINT NULL ,
          TextMaxLength SMALLINT NULL ,
          TextMask VARCHAR(50) NULL ,
          TextEnforceLength SMALLINT NULL ,
          RestrictRange SMALLINT NULL ,
          MinValDecimal REAL NULL ,
          MaxValDecimal REAL NULL ,
          MinValDate DATETIME NULL ,
          MaxValDate DATETIME NULL ,
          ListAllowMultiple SMALLINT NULL ,
          DefaultValueText VARCHAR(100) NULL ,
          DefaultValueDecimal REAL NULL ,
          DefaultValueDate DATETIME NULL ,
          UseDefault SMALLINT NULL ,
          ReqOnSubmit SMALLINT NULL ,
          IncludeDateButton BIT NULL 
        ) ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (DATA_COMPRESSION = PAGE);

    ALTER TABLE src.UDFLibrary ADD 
    CONSTRAINT PK_UDFLibrary PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, UDFIdNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_UDFLibrary ON src.UDFLibrary REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_UDFLibrary'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_UDFLibrary ON src.UDFLibrary REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

