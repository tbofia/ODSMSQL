IF OBJECT_ID('src.BillControl', 'U') IS NULL
    BEGIN
        CREATE TABLE src.BillControl
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              ClientCode CHAR(4) NOT NULL,
              BillSeq INT NOT NULL,
              BillControlSeq SMALLINT NOT NULL,
              ModDate DATETIME NULL,
              CreateDate DATETIME NULL,
              Control CHAR(1) NULL,
              ExternalID VARCHAR(50) NULL,
              BatchNumber BIGINT NULL,
              ModUserID CHAR(2) NULL,
              ExternalID2 VARCHAR(50) NULL,
              Message VARCHAR(500) NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.BillControl ADD 
        CONSTRAINT PK_BillControl PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,ClientCode,BillSeq,BillControlSeq) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);
		
		ALTER INDEX PK_BillControl ON src.BillControl REBUILD WITH(STATISTICS_INCREMENTAL = ON);

	END
GO

IF EXISTS ( SELECT  1
            FROM    sys.columns c
                    INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
            WHERE   c.object_id = OBJECT_ID(N'src.BillControl')
                    AND c.name = 'ExternalID'
                    AND NOT ( t.name = 'VARCHAR'
                              AND c.max_length = 50
                            ) )
    BEGIN
        ALTER TABLE src.BillControl ALTER COLUMN ExternalID VARCHAR(50) NULL;
    END;
GO

IF EXISTS ( SELECT  1
            FROM    sys.columns c
                    INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
            WHERE   c.object_id = OBJECT_ID(N'src.BillControl')
                    AND c.name = 'ExternalID2'
                    AND NOT ( t.name = 'VARCHAR'
                              AND c.max_length = 50
                            ) )
    BEGIN
        ALTER TABLE src.BillControl ALTER COLUMN ExternalID2 VARCHAR(50) NULL;
    END;
GO

