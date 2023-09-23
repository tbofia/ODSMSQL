IF OBJECT_ID('src.Bills_Pharm_Endnotes', 'U') IS NULL
    BEGIN
        CREATE TABLE src.Bills_Pharm_Endnotes
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL , 
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              BillIDNo INT NOT NULL ,
              LINE_NO SMALLINT NOT NULL ,
              EndNote SMALLINT NOT NULL ,
              Referral VARCHAR(200) NULL ,
              PercentDiscount REAL NULL ,
              ActionId SMALLINT NULL ,
			  EndnoteTypeId TINYINT CONSTRAINT DF_Bills_Pharm_Endnotes_EndnoteTypeId DEFAULT(1) NOT NULL
             
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Bills_Pharm_Endnotes ADD 
        CONSTRAINT PK_Bills_Pharm_Endnotes PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIDNo, LINE_NO, EndNote, EndnoteTypeId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Bills_Pharm_Endnotes ON src.Bills_Pharm_Endnotes REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID('src.Bills_Pharm_Endnotes')
                        AND name = 'Referral'
                        AND max_length = 200 )
ALTER TABLE src.Bills_Pharm_Endnotes 
ALTER COLUMN Referral VARCHAR(200) NULL
GO

--Add Code Block to Check
/*
	if primary key does not exist
		1. rename old table
		2. create a new table
		3. create new primary key
		4. partition
		5. update hashbyte
		6. switch partition.
*/
IF NOT EXISTS ( SELECT 1
			FROM sys.indexes AS i 
			INNER JOIN sys.index_columns AS ic 
				ON i.OBJECT_ID = ic.OBJECT_ID 
				AND i.index_id = ic.index_id 
				AND i.is_primary_key = 1 
				AND ic.OBJECT_ID = OBJECT_ID('src.Bills_Pharm_Endnotes')
			INNER JOIN sys.columns AS c 
				ON ic.object_id = c.object_id 
				AND ic.column_id = c.column_id
				AND c.name = 'EndnoteTypeId' )
BEGIN
	SET XACT_ABORT ON;

	

	--1. rename old table
	EXEC sp_rename 'src.Bills_Pharm_Endnotes.PK_Bills_Pharm_Endnotes', 'PK_Bills_Pharm_Endnotes_bak', N'INDEX'
	EXEC sp_rename 'src.Bills_Pharm_Endnotes', 'Bills_Pharm_Endnotes_bak'

	--2. create a new table with partition
	IF OBJECT_ID('src.Bills_Pharm_Endnotes', 'U') IS NULL
    BEGIN
        CREATE TABLE src.Bills_Pharm_Endnotes
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              BillIDNo INT NOT NULL ,
              LINE_NO SMALLINT NOT NULL ,
              EndNote SMALLINT NOT NULL ,
              Referral VARCHAR(200) NULL ,
              PercentDiscount REAL NULL ,
              ActionId SMALLINT NULL ,
			  EndnoteTypeId TINYINT CONSTRAINT DF_Bills_Pharm_Endnotes_EndnoteTypeId DEFAULT(1) NOT NULL

            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Bills_Pharm_Endnotes ADD 
        CONSTRAINT PK_Bills_Pharm_Endnotes PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIDNo, LINE_NO, EndNote, EndnoteTypeId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Bills_Pharm_Endnotes ON src.Bills_Pharm_Endnotes REBUILD WITH(STATISTICS_INCREMENTAL = ON);
	END

	--3. for each partition, update EndnoteTypeId and OdsHashbytesValue, then switch partition
	IF OBJECT_ID('tempdb..#partitions','U') IS NOT NULL
		DROP TABLE #partitions;
	
	SELECT partition_number, SUM(rows) AS Rows 
	INTO #partitions
	FROM sys.partitions p
	JOIN sys.tables t
		ON p.object_id = t.object_id
		AND SCHEMA_NAME(t.schema_id) = 'src'
		AND t.name = 'Bills_Pharm_Endnotes_bak'
		AND p.rows != 0
		AND p.index_id = 1
	GROUP BY partition_number
	ORDER BY Rows DESC;


	DECLARE @partition_number INT;

	DECLARE PARTITION_CURSOR CURSOR FOR 
	SELECT partition_number
	FROM #partitions;

	OPEN PARTITION_CURSOR

	FETCH NEXT FROM PARTITION_CURSOR INTO @partition_number

	WHILE @@FETCH_STATUS=0
	BEGIN
		BEGIN TRANSACTION T1;
		--3.1 update EndnoteTypeId and OdsHashbytesValue
		IF EXISTS( SELECT 1 FROM sys.tables t WHERE SCHEMA_NAME(t.schema_id) = 'stg' and t.name = 'Bills_Pharm_Endnotes_bak')
		DROP TABLE stg.Bills_Pharm_Endnotes_bak
		
		CREATE TABLE stg.Bills_Pharm_Endnotes_bak
			(
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              BillIDNo INT NOT NULL ,
              LINE_NO SMALLINT NOT NULL ,
              EndNote SMALLINT NOT NULL ,
              Referral VARCHAR(200) NULL ,
              PercentDiscount REAL NULL ,
              ActionId SMALLINT NULL ,
			  EndnoteTypeId TINYINT CONSTRAINT DF_Bills_Pharm_Endnotes_EndnoteTypeId DEFAULT(1) NOT NULL

            )ON DP_Ods_PartitionScheme(OdsCustomerId)
			WITH (
                 DATA_COMPRESSION = PAGE);
		
		--Create clustered index on stg table.
		ALTER TABLE stg.Bills_Pharm_Endnotes_bak ADD 
        CONSTRAINT PK_Bills_Pharm_Endnotes PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIDNo, LINE_NO, EndNote, EndnoteTypeId) WITH (DATA_COMPRESSION = PAGE);

		--Insert Data
		INSERT stg.Bills_Pharm_Endnotes_bak
		(
			OdsPostingGroupAuditId
		  ,OdsCustomerId
		  ,OdsCreateDate
		  ,OdsSnapshotDate
		  ,OdsRowIsCurrent
		  ,OdsHashbytesValue
		  ,DmlOperation
		  ,BillIDNo
		  ,LINE_NO
		  ,EndNote
		  ,Referral
		  ,PercentDiscount
		  ,ActionId
		  ,EndnoteTypeId
		)
		SELECT 
			OdsPostingGroupAuditId
		  ,OdsCustomerId
		  ,OdsCreateDate
		  ,OdsSnapshotDate
		  ,OdsRowIsCurrent
		  ,HASHBYTES('SHA1', (SELECT [BillIDNo]
									,[LINE_NO]
									,[EndNote]
									,[Referral]
									,[PercentDiscount]
									,[ActionId]
									,1 AS EndnoteTypeId FOR XML RAW)) AS OdsHashbytesValue
		  ,DmlOperation
		  ,BillIDNo
		  ,LINE_NO
		  ,EndNote
		  ,Referral
		  ,PercentDiscount
		  ,ActionId
		  ,1
		FROM src.Bills_Pharm_Endnotes_bak
		WHERE OdsCustomerId = @partition_number
		ORDER BY OdsPostingGroupAuditId, OdsCustomerId, BillIDNo, LINE_NO, EndNote;

		--4.2 switch partition
		DECLARE @SQL VARCHAR(MAX) = '';

		SET @SQL = '
		ALTER TABLE stg.Bills_Pharm_Endnotes_bak SWITCH PARTITION ' + CAST(@partition_number AS VARCHAR(10)) + ' TO src.Bills_Pharm_Endnotes PARTITION ' + CAST(@partition_number AS VARCHAR(10)) + '
		DROP TABLE stg.Bills_Pharm_Endnotes_bak ';

		EXEC(@SQL);

		COMMIT TRANSACTION T1;

		FETCH NEXT FROM PARTITION_CURSOR INTO @partition_number
		

	END

	CLOSE PARTITION_CURSOR;  
	DEALLOCATE PARTITION_CURSOR;

	--DROP TABLE src.Bills_Pharm_Endnotes_bak;

	
END



-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Bills_Pharm_Endnotes'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Bills_Pharm_Endnotes ON src.Bills_Pharm_Endnotes REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO


