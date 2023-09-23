--SET NOCOUNT ON;

DECLARE @AppVersion VARCHAR(10) ,
    @SchemaName VARCHAR(10) ,
    @TableName VARCHAR(100) ,
    @ProcessId INT,
    @MaxProcessStepId INT,
    @FullSql VARCHAR(MAX) = '' ,
    @IncrementalSql VARCHAR(MAX) = '' ,
    @SourceDBName VARCHAR(100) ,
    @SpExecuteSql VARCHAR(100) ,
    @Sql VARCHAR(MAX)

-- Set the source database for Full and Incremental SQL statements

--SET @SourceDBName = 'Mmedical_Ameriprise' -- 8.3
--SET @SourceDBName = 'Mmedical_CSAA' -- 8.4
--SET @SourceDBName = 'Mmedical_Explorer' -- 8.5
--SET @SourceDBName = 'Mmedical_Grange' -- 8.6
--SET @SourceDBName = 'Mmedical_Affirmative' -- 8.7
--SET @SourceDBName = 'Mmedical_Germania' -- 8.8
--SET @SourceDBName = 'Mmedical_AllStateNJ' -- 8.9
SET @SourceDBName = 'MMedical_ProcuraCTG'
-- Get the version of our source database
SET @SpExecuteSql = @SourceDBName + '.sys.sp_executesql'
EXEC @SpExecuteSql N'SELECT TOP 1  @AppVersion = AppVersion FROM dbo.AppVersion WHERE AppVersion IS NOT NULL ORDER BY AppVersionId DESC', N'@AppVersion VARCHAR(10) OUTPUT', @AppVersion = @AppVersion OUTPUT

-- Let's cut off the last two numbers associated with the version
SET @AppVersion = REVERSE(@AppVersion)
 -- Reverse it
SET @AppVersion = SUBSTRING(@AppVersion, CHARINDEX('.', @AppVersion) + 1, LEN(@AppVersion))
 -- Cut off the first number (last, in reverse)
SET @AppVersion = SUBSTRING(@AppVersion, CHARINDEX('.', @AppVersion) + 1, LEN(@AppVersion))
-- -- Cut off the second number (second last, in reverse)
SET @AppVersion = REVERSE(@AppVersion)
 -- Flip it back to normal
PRINT @AppVersion

-- Now, let's get the meta data associated with 
IF OBJECT_ID('tempdb..#TableMetaData', 'U') IS NOT NULL
DROP TABLE #TableMetaData;
CREATE TABLE #TableMetaData
    (
      SchemaName VARCHAR(100) NOT NULL ,
      TableName VARCHAR(MAX) NOT NULL ,
      ColumnName VARCHAR(MAX) NOT NULL ,
      ColumnOrder INT NOT NULL ,
      IsPrimaryKey BIT NOT NULL ,
      IsVarcharOrChar BIT NOT NULL
    )

SET @Sql = 'SELECT  s.name AS SchemaName ,
        t.name AS TableName ,
        c.name AS ColumnName ,
        c.column_id AS ColumnOrder ,
        ISNULL(i.is_primary_key, 0) AS IsPrimaryKey ,
		CASE WHEN ty.name IN (''char'', ''varchar'', ''nchar'', ''nvarchar'') THEN 1 ELSE 0 END AS IsVarcharOrChar
FROM    ' + @SourceDBName + '.sys.objects t
        INNER JOIN ' + @SourceDBName + '.sys.columns c ON t.object_id = c.object_id
        INNER JOIN ' + @SourceDBName + '.sys.schemas s ON t.schema_id = s.schema_id
		INNER JOIN ' + @SourceDBName + '.sys.types ty ON c.system_type_id = ty.system_type_id AND c.user_type_id = ty.user_type_id
        LEFT OUTER JOIN ( SELECT    ic1.object_id ,
                                    ic1.column_id ,
                                    i1.is_primary_key
                          FROM      ' + @SourceDBName + '.sys.indexes i1
                                    INNER JOIN ' + @SourceDBName + '.sys.index_columns ic1 ON i1.object_id = ic1.object_id
                                                                        AND i1.index_id = ic1.index_id
                          WHERE     i1.is_primary_key = 1 ) AS i ON c.object_id = i.object_id
                                                                    AND c.column_id = i.column_id
WHERE   s.name IN (''dbo'', ''dm'')
		AND t.type IN (''U'',''V'')
        AND t.name IN (''BILL_HDR'',''CLAIMANT'') -- ********* SPECIFY TABLE NAMES *************
        
ORDER BY TableName ,
        ColumnOrder'

INSERT  INTO #TableMetaData
        ( SchemaName ,
          TableName ,
          ColumnName ,
          ColumnOrder ,
          IsPrimaryKey ,
		  IsVarcharOrChar
        )
        EXECUTE ( @Sql  )

-- Now, let's start building the Full and Incremental SQL Statements, then update rpt.ProcessStep
DECLARE cr_tables CURSOR
FOR
SELECT DISTINCT
        SchemaName ,
        TableName ,
        P.ProcessId
FROM    #TableMetaData T
INNER JOIN rpt.Process P
ON P.BaseFileName = T.TableName
ORDER BY TableName;

OPEN cr_tables;

FETCH NEXT
    FROM cr_tables
    INTO @SchemaName, @TableName,@ProcessId;

WHILE @@FETCH_STATUS = 0
    BEGIN

-- Full SQL
        SELECT  @FullSql = 'SELECT ' + (SELECT  CHAR(13) + CHAR(10) + ' ' + CASE WHEN IsVarcharOrChar = 1 THEN 'REPLACE(REPLACE(REPLACE('
                                                                                 ELSE ''
                                                                            END + @TableName + '.' + ColumnName + CASE WHEN IsVarcharOrChar = 1 THEN ', ''|'', '' ''), CHAR(13), '' ''), CHAR(10), '' '')'
                                                                                                                       ELSE ''
                                                                                                                  END + ' ,'
                                        FROM    #TableMetaData
                                        WHERE   TableName = @TableName
                                                AND SchemaName = @SchemaName
                                        ORDER BY ColumnOrder
        FOR     XML PATH('') ,
                    TYPE
).value('(./text())[1]', 'VARCHAR(MAX)') + -- This part kind of sucks, but now we have to manually
-- create dummy columns for columns added in subsequent releases
-- Bill_Hdr
CASE WHEN @TableName = 'Bill_Hdr'
          AND NOT EXISTS ( SELECT   1
                           FROM     #TableMetaData
                           WHERE    ColumnName = 'AdmissionType' ) THEN CHAR(13) + CHAR(10) + ' NULL AS AdmissionType ,'
     ELSE ''
END +
CASE WHEN @TableName = 'Bill_Hdr'
          AND NOT EXISTS ( SELECT   1
                           FROM     #TableMetaData
                           WHERE    ColumnName = 'CoverageType' ) THEN CHAR(13) + CHAR(10) + ' NULL AS CoverageType ,'
     ELSE ''
END +
CASE WHEN @TableName = 'Claimant'
          AND NOT EXISTS ( SELECT   1
                           FROM     #TableMetaData
                           WHERE    ColumnName = 'CoverageType' ) THEN CHAR(13) + CHAR(10) + ' NULL AS CoverageType ,'
     ELSE ''
END +
CASE WHEN @TableName = 'rsn_Override'
          AND NOT EXISTS ( SELECT   1
                           FROM     #TableMetaData
                           WHERE    ColumnName = 'SpecialProcessing' ) THEN CHAR(13) + CHAR(10) + ' NULL AS SpecialProcessing ,'
     ELSE ''
END +
CASE WHEN @TableName = 'VpnLedger'
          AND NOT EXISTS ( SELECT   1
                           FROM     #TableMetaData
                           WHERE    ColumnName = 'SpecialProcessing' ) THEN CHAR(13) + CHAR(10) + ' NULL AS SpecialProcessing ,'
     ELSE ''
END
                +'
 ''I''
FROM ~SNAPSHOT~.' + @SchemaName + '.' + @TableName

-- Incremental SQL
        SELECT  @IncrementalSql = 'SELECT ' + (SELECT   CHAR(13) + CHAR(10) + ' ' + CASE WHEN IsVarcharOrChar = 1 THEN 'REPLACE(REPLACE(REPLACE('
                                                                                         ELSE ''
                                                                                    END + CASE WHEN IsPrimaryKey = 1 THEN 'ct.' + ColumnName
                                                                                               ELSE @TableName + '.' + ColumnName
                                                                                          END + CASE WHEN IsVarcharOrChar = 1 THEN ', ''|'', '' ''), CHAR(13), '' ''), CHAR(10), '' '')'
                                                                                                     ELSE ''
                                                                                                END + ' ,'
                                               FROM     #TableMetaData
                                               WHERE    TableName = @TableName
                                                        AND SchemaName = @SchemaName
                                               ORDER BY ColumnOrder
        FOR     XML PATH('') ,
                    TYPE
							).value('(./text())[1]', 'NVARCHAR(MAX)') + -- This part kind of sucks, but now we have to manually
-- create dummy columns for columns added in subsequent releases
-- Bill_Hdr
CASE WHEN @TableName = 'Bill_Hdr'
          AND NOT EXISTS ( SELECT   1
                           FROM     #TableMetaData
                           WHERE    ColumnName = 'AdmissionType' ) THEN CHAR(13) + CHAR(10) + ' NULL AS AdmissionType ,'
     ELSE ''
END +
CASE WHEN @TableName = 'Bill_Hdr'
          AND NOT EXISTS ( SELECT   1
                           FROM     #TableMetaData
                           WHERE    ColumnName = 'CoverageType' ) THEN CHAR(13) + CHAR(10) + ' NULL AS CoverageType ,'
     ELSE ''
END +
CASE WHEN @TableName = 'Claimant'
          AND NOT EXISTS ( SELECT   1
                           FROM     #TableMetaData
                           WHERE    ColumnName = 'CoverageType' ) THEN CHAR(13) + CHAR(10) + ' NULL AS CoverageType ,'
     ELSE ''
END +
CASE WHEN @TableName = 'rsn_Override'
          AND NOT EXISTS ( SELECT   1
                           FROM     #TableMetaData
                           WHERE    ColumnName = 'SpecialProcessing' ) THEN CHAR(13) + CHAR(10) + ' NULL AS SpecialProcessing ,'
     ELSE ''
END +
CASE WHEN @TableName = 'VpnLedger'
          AND NOT EXISTS ( SELECT   1
                           FROM     #TableMetaData
                           WHERE    ColumnName = 'SpecialProcessing' ) THEN CHAR(13) + CHAR(10) + ' NULL AS SpecialProcessing ,'
     ELSE ''
END
                +'
 ct.SYS_CHANGE_OPERATION
FROM ~SNAPSHOT~.' + @SchemaName + '.' + @TableName + '
RIGHT OUTER JOIN CHANGETABLE (CHANGES ~SNAPSHOT~.' + @SchemaName + '.' + @TableName + ', ~PREVIOUSCTVERSION~) AS ct ON ' + STUFF((SELECT    ' ' + 'AND ' + TableName + '.' + ColumnName + ' = ct.' + ColumnName + CHAR(13) + CHAR(10)
                                                                                                                                  FROM      #TableMetaData
                                                                                                                                  WHERE     TableName = @TableName
                                                                                                                                            AND SchemaName = @SchemaName
                                                                                                                                            AND IsPrimaryKey = 1
                                                                                                                                  ORDER BY  ColumnOrder
                FOR                                                                                                              XML PATH('') ,
                                                                                                                                     TYPE
					).value('(./text())[1]', 'NVARCHAR(MAX)'), 1, 5, '')
-- Check If a Record already Exist for the given object and verion
		IF NOT EXISTS (SELECT 1 FROM rpt.ProcessStep WHERE MinAppVersion = @AppVersion AND ProcessId = @ProcessId)  
		BEGIN
			SELECT @MaxProcessStepId  = MAX(ProcessStepId) FROM rpt.ProcessStep
			
			INSERT INTO rpt.ProcessStep
			VALUES (@MaxProcessStepId+1,@ProcessId,'Extract data for '+@TableName,1,NULL,NULL,@AppVersion)
		END
		
        UPDATE  ps
        SET     ps.FullSql = @FullSql ,
                ps.IncrementalSql = CASE WHEN p.IsSnapshot = 0 THEN @IncrementalSql
                                         ELSE NULL
                                    END
        FROM    rpt.ProcessStep ps
                INNER JOIN rpt.PROCESS p ON ps.ProcessId = p.ProcessId
        WHERE   p.BaseFileName = @TableName
                AND ps.MinAppVersion = @AppVersion
--				AND ps.ProcessStepId > @MaxProcessStepId

        FETCH NEXT
    FROM cr_tables
    INTO @SchemaName, @TableName, @ProcessId;

    END

DEALLOCATE cr_tables

/*
UPDATE rpt.ProcessStep
SET	FullSql = REPLACE(FullSql, '''|'', '' ''', '''^|'', ''  ''') ,
	IncrementalSql = REPLACE(IncrementalSql, '''|'', '' ''', '''^|'', ''  ''')
WHERE ProcessId IN (111, 128) -- AnalysisRule, UDF_Sentry_Criteria
*/
