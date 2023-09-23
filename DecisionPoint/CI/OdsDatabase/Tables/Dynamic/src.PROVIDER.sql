IF OBJECT_ID('src.PROVIDER', 'U') IS NULL
    BEGIN
        CREATE TABLE src.PROVIDER
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,  
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              PvdIDNo INT NOT NULL ,
              PvdMID INT NULL ,
              PvdSource SMALLINT NULL ,
              PvdTIN VARCHAR(15) NULL ,
              PvdLicNo VARCHAR(30) NULL ,
              PvdCertNo VARCHAR(30) NULL ,
              PvdLastName VARCHAR(60) NULL ,
              PvdFirstName VARCHAR(35) NULL ,
              PvdMI VARCHAR(1) NULL ,
              PvdTitle VARCHAR(5) NULL ,
              PvdGroup VARCHAR(60) NULL ,
              PvdAddr1 VARCHAR(55) NULL ,
              PvdAddr2 VARCHAR(55) NULL ,
              PvdCity VARCHAR(30) NULL ,
              PvdState VARCHAR(2) NULL ,
              PvdZip VARCHAR(12) NULL ,
              PvdZipPerf VARCHAR(12) NULL ,
              PvdPhone VARCHAR(25) NULL ,
              PvdFAX VARCHAR(13) NULL ,
              PvdSPC_List VARCHAR(MAX) NULL ,
              PvdAuthNo VARCHAR(30) NULL ,
              PvdSPC_ACD VARCHAR(2) NULL ,
              PvdUpdateCounter SMALLINT NULL ,
              PvdPPO_Provider SMALLINT NULL ,
              PvdFlags INT NULL ,
              PvdERRate MONEY NULL ,
              PvdSubNet VARCHAR(4) NULL ,
              InUse VARCHAR(100) NULL ,
              PvdStatus INT NULL ,
              PvdElectroStartDate DATETIME NULL ,
              PvdElectroEndDate DATETIME NULL ,
              PvdAccredStartDate DATETIME NULL ,
              PvdAccredEndDate DATETIME NULL ,
              PvdRehabStartDate DATETIME NULL ,
              PvdRehabEndDate DATETIME NULL ,
              PvdTraumaStartDate DATETIME NULL ,
              PvdTraumaEndDate DATETIME NULL ,
              OPCERT VARCHAR(7) NULL ,
              PvdDentalStartDate DATETIME NULL ,
              PvdDentalEndDate DATETIME NULL ,
              PvdNPINo VARCHAR(10) NULL ,
              PvdCMSId VARCHAR(6) NULL ,
              CreateDate DATETIME NULL ,
              LastChangedOn DATETIME NULL 
            
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.PROVIDER ADD 
        CONSTRAINT PK_PROVIDER PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, PvdIDNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_PROVIDER ON src.PROVIDER REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO


IF  EXISTS ( SELECT  1
			FROM    sys.columns c 
					INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
			WHERE   object_id = OBJECT_ID(N'src.PROVIDER')
					AND c.name = 'PvdSPC_List' 
					AND NOT ( t.name = 'VARCHAR' 
						 AND c.max_length = '-1'
						   ) ) 
	BEGIN
		ALTER TABLE src.PROVIDER ALTER COLUMN PvdSPC_List VARCHAR(MAX) NULL ;
	END ; 
GO





-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_PROVIDER'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_PROVIDER ON src.PROVIDER REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO





