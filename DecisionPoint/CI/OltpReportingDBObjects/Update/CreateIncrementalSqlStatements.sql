IF OBJECT_ID('adm.CreateIncrementalSqlStatements') IS NOT NULL
    DROP PROCEDURE adm.CreateIncrementalSqlStatements
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE adm.CreateIncrementalSqlStatements
(
    @ProcessIdTable IntegerTable READONLY
)
AS
BEGIN
    SET NOCOUNT ON;

/* UPDATE adm.ProcessStep.IncrementalSql*/
    DECLARE @Sql NVARCHAR(MAX) ,
        @ProcessStepId INTEGER ,
        @SchemaName NVARCHAR(128) = 'dbo' ,
        @TableName NVARCHAR(128)

    IF OBJECT_ID('tempdb..#TableMetaData', 'U') IS NOT NULL
        DROP TABLE #TableMetaData

    SELECT  tc.ProcessStepId ,
            p.TargetTableName ,
            tc.TargetColumnName ,
            tc.TargetColumnOrder ,
            a.IsPrimaryKey ,
            ps.CheckpointTableId
    INTO    #TableMetaData
    FROM    adm.Process p
            INNER JOIN adm.ProcessStep ps ON p.ProcessId = ps.ProcessId
            INNER JOIN adm.TargetColumn tc ON ps.ProcessStepId = tc.ProcessStepId
            INNER JOIN @ProcessIdTable pid ON p.ProcessId = pid.Id
            INNER JOIN ( SELECT s.name AS SchemaName ,
                                o.name AS TableName ,
                                c.name AS ColumnName ,
                                i.is_primary_key AS IsPrimaryKey
                         FROM   sys.objects o
                                INNER JOIN sys.columns c ON o.object_id = c.object_id
                                INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
                                LEFT OUTER JOIN ( SELECT    ic1.object_id ,
                                                            ic1.column_id ,
                                                            i1.is_primary_key
                                                  FROM      sys.indexes i1
                                                            INNER JOIN sys.index_columns ic1 ON i1.object_id = ic1.object_id
                                                                                                AND i1.index_id = ic1.index_id
                                                  WHERE     i1.is_primary_key = 1 ) AS i ON c.object_id = i.object_id
                                                                                            AND c.column_id = i.column_id ) a ON p.TargetSchemaName = a.SchemaName
                                                                                                                                 AND p.TargetTableName = a.TableName
                                                                                                                                 AND tc.TargetColumnName = a.ColumnName
    WHERE   p.IsIncremental = 1
    ORDER BY p.TargetTableName ,
            tc.TargetColumnOrder

    IF EXISTS ( SELECT TOP 1
                        1
                FROM    #TableMetaData
                WHERE   CheckpointTableId IS NULL )
        RAISERROR('One or more tables are configured as incremental loads, but no checkpoint table is specified', 16, 1);

    DECLARE cr_tables CURSOR
    FOR
    SELECT DISTINCT
            ProcessStepId ,
            TargetTableName
    FROM    #TableMetaData
    ORDER BY ProcessStepId ,
            TargetTableName;

    OPEN cr_tables;

    FETCH NEXT
    FROM cr_tables
    INTO @ProcessStepId, @TableName;

    WHILE @@FETCH_STATUS = 0
        BEGIN
            SELECT  @Sql = 'SELECT ' + REVERSE(STUFF(REVERSE((SELECT    CHAR(13) + CHAR(10) + ' ' + CASE WHEN IsPrimaryKey = 1 THEN 'ct.' + TargetColumnName + ' ,'
                                                                                                             WHEN TargetColumnName = 'DmlOperation' THEN 'ct.SYS_CHANGE_OPERATION ,'
                                                                                                             ELSE @TableName + '.' + TargetColumnName + ' ,'
                                                                                                        END
                                                              FROM      #TableMetaData
                                                              WHERE     TargetTableName = @TableName
                                                              ORDER BY  TargetColumnOrder
                                                     FOR     XML PATH('') ,
                                                                 TYPE
							).value('(./text())[1]', 'NVARCHAR(MAX)')), 1, 2, '')) + '
FROM ~SNAPSHOT~.' + @SchemaName + '.' + @TableName + '
RIGHT OUTER JOIN CHANGETABLE (CHANGES ~SNAPSHOT~.' + @SchemaName + '.' + @TableName + ', ~PREVIOUSCTVERSION~) AS ct ON ' + STUFF((SELECT    ' ' + 'AND ' + TargetTableName + '.' + TargetColumnName + ' = ct.' + TargetColumnName + CHAR(13) + CHAR(10)
                                                                                                                                  FROM      #TableMetaData
                                                                                                                                  WHERE     TargetTableName = @TableName
                                                                                                                                            AND IsPrimaryKey = 1
                                                                                                                                  ORDER BY  TargetColumnOrder
                    FOR                                                                                                          XML PATH('') ,
                                                                                                                                     TYPE
					).value('(./text())[1]', 'NVARCHAR(MAX)'), 1, 5, '') + ';
';

            UPDATE  adm.ProcessStep
            SET     IncrementalSql = @Sql
            WHERE   ProcessStepId = @ProcessStepId

            FETCH NEXT
    FROM cr_tables
    INTO @ProcessStepId, @TableName;
        END

    CLOSE cr_tables;

    DEALLOCATE cr_tables;
END


GO


