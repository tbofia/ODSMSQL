IF OBJECT_ID('adm.CreateFullSqlStatements') IS NOT NULL
    DROP PROCEDURE adm.CreateFullSqlStatements
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE adm.CreateFullSqlStatements
(
    @ProcessIdTable IntegerTable READONLY
)
AS
BEGIN

    SET NOCOUNT ON;
/* UPDATE adm.ProcessStep.FullSql*/
    DECLARE @Sql NVARCHAR(MAX) ,
        @ProcessStepId INTEGER ,
        @SchemaName NVARCHAR(128) = 'dbo' ,
        @TableName NVARCHAR(128)

    IF OBJECT_ID('tempdb..#TableMetaData', 'U') IS NOT NULL
        DROP TABLE #TableMetaData

    SELECT  tc.ProcessStepId ,
            p.TargetTableName ,
            tc.TargetColumnName ,
            tc.TargetColumnOrder
    INTO    #TableMetaData
    FROM    adm.Process p
            INNER JOIN adm.ProcessStep ps ON p.ProcessId = ps.ProcessId
            INNER JOIN adm.TargetColumn tc ON ps.ProcessStepId = tc.ProcessStepId
            INNER JOIN @ProcessIdTable pid ON p.ProcessId = pid.Id
    WHERE   p.TargetSchemaName = 'src'
    ORDER BY p.TargetTableName ,
            tc.TargetColumnOrder

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
            SELECT  @Sql = 'SELECT ' + REVERSE(STUFF(REVERSE((SELECT    CHAR(13) + CHAR(10) + ' ' + CASE WHEN TargetColumnName = 'DmlOperation' THEN '''I'' ,'
                                                                                                             ELSE @TableName + '.' + TargetColumnName + ' ,'
                                                                                                        END
                                                              FROM      #TableMetaData
                                                              WHERE     TargetTableName = @TableName
                                                              ORDER BY  TargetColumnOrder
                                                     FOR     XML PATH('') ,
                                                                 TYPE
							).value('(./text())[1]', 'NVARCHAR(MAX)')), 1, 2, '')) + '
FROM ~SNAPSHOT~.' + @SchemaName + '.' + @TableName + '
;
'

            UPDATE  adm.ProcessStep
            SET     FullSql = @Sql
            WHERE   ProcessStepId = @ProcessStepId

            FETCH NEXT
    FROM cr_tables
    INTO @ProcessStepId, @TableName;
        END

    CLOSE cr_tables;

    DEALLOCATE cr_tables;

END


GO


