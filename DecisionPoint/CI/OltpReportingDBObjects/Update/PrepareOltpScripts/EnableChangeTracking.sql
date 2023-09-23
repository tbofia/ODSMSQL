-- ** DP PRIMARY KEY CLEANUP **

--UDF_Sentry_Criteria

-- Old DP versions omit the primary key; sometimes, they've been manually created in production but are nonclustered.
-- Let's clean all of this up now.  We'll need the PK for Change Tracking.

IF EXISTS ( SELECT  object_id
            FROM    sys.indexes
            WHERE   object_id = OBJECT_ID('dbo.UDF_Sentry_Criteria')
                    AND name = 'PK_UDF_Sentry_Criteria'
                    AND type_desc = 'NONCLUSTERED' )
    ALTER TABLE dbo.UDF_Sentry_Criteria DROP CONSTRAINT PK_UDF_Sentry_Criteria;
GO

-- On some production instances, a clustered index named idx_UDFIdNo has been created on the UDF_Sentry_Criteria.UdfIdNo column.  We
-- want the PK to be clustered, so we'll drop this index, then create a new one called IX_UdfIdNo as NONCLUSTERED for everybody (that
-- code is in the corresponding index file).
SET XACT_ABORT ON;
IF EXISTS ( SELECT  object_id
            FROM    sys.indexes
            WHERE   object_id = OBJECT_ID('dbo.UDF_Sentry_Criteria')
                    AND name = 'idx_UDFIdNo' )
BEGIN
    DROP INDEX idx_UDFIdNo ON dbo.UDF_Sentry_Criteria;

	IF NOT EXISTS ( SELECT  object_id
					FROM    sys.indexes
					WHERE   object_id = OBJECT_ID('dbo.UDF_Sentry_Criteria')
							AND name = 'IX_UdfIdNo' )
		CREATE NONCLUSTERED INDEX IX_UdfIdNo ON dbo.UDF_Sentry_Criteria (UdfIdNo);
END
GO

-- Now, let's create the clustered primary key.
IF NOT EXISTS ( SELECT  object_id
                FROM    sys.key_constraints
                WHERE   parent_object_id = OBJECT_ID('dbo.UDF_Sentry_Criteria')
                        AND name = 'PK_UDF_Sentry_Criteria' )
    ALTER TABLE dbo.UDF_Sentry_Criteria ADD CONSTRAINT PK_UDF_Sentry_Criteria PRIMARY KEY CLUSTERED (CriteriaId);
GO

-- UDF_Sentry_Criteria.PredefinedValues
--
-- This isn't really change tracking related, but the UDF_Sentry_Criteria.PredefinedValues field is TEXT before
-- DP 8.7.  We can't remove delimited characters via REPLACE using this data type, so we'll convert to VARCHAR(MAX).
--

SET XACT_ABORT ON

BEGIN TRANSACTION

DECLARE @Sql NVARCHAR(4000)

SELECT  @Sql = 'DROP STATISTICS ' + STUFF(( SELECT  DISTINCT
                        ', ' + OBJECT_NAME(ss.object_id) + '.' + ss.name
                FROM    sys.stats ss
                        INNER JOIN sys.stats_columns sc ON sc.object_id = ss.object_id
                                                           AND sc.stats_id = ss.stats_id
                        INNER JOIN sys.columns c ON c.column_id = sc.column_id
                                                    AND c.object_id = sc.OBJECT_ID
                WHERE   ss.user_created = 1 -- Was this user created?
                        AND c.object_id = OBJECT_ID('dbo.UDF_Sentry_Criteria') 
                        AND c.system_type_id IN ( 35, 99 ) -- text, ntext
ORDER BY                ', ' + OBJECT_NAME(ss.object_id) + '.' + ss.name
              FOR
                XML PATH('') ), 1, 2, '') + ';'

IF @Sql IS NOT NULL
	EXEC (@Sql)

-- Convert TEXT to VARCHAR(MAX)
IF EXISTS ( SELECT  c.object_id
            FROM    sys.columns c
                    INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
            WHERE   object_id = OBJECT_ID('dbo.UDF_Sentry_Criteria')
                    AND c.name = 'PredefinedValues'
                    AND t.name = 'text' )
    ALTER TABLE dbo.UDF_Sentry_Criteria ALTER COLUMN PredefinedValues VARCHAR(MAX) NULL

COMMIT TRANSACTION
GO

-- Some versions of DP are missing PKs for the MedicareStatusIndicatorRule* tables
IF OBJECT_ID('dbo.MedicareStatusIndicatorRuleCoverageType', 'U') IS NOT NULL
AND NOT EXISTS (   SELECT 1
                  FROM   sys.key_constraints
                  WHERE  parent_object_id = OBJECT_ID('dbo.MedicareStatusIndicatorRuleCoverageType')
                         AND name = 'PK_MedicareStatusIndicatorRuleCoverageType'
                         AND type = 'PK' )
    ALTER TABLE dbo.MedicareStatusIndicatorRuleCoverageType
    ADD CONSTRAINT PK_MedicareStatusIndicatorRuleCoverageType PRIMARY KEY CLUSTERED ( MedicareStatusIndicatorRuleId, ShortName )
GO

IF OBJECT_ID('dbo.MedicareStatusIndicatorRulePlaceOfService', 'U') IS NOT NULL
AND NOT EXISTS (   SELECT 1
                  FROM   sys.key_constraints
                  WHERE  parent_object_id = OBJECT_ID('dbo.MedicareStatusIndicatorRulePlaceOfService')
                         AND name = 'PK_MedicareStatusIndicatorRulePlaceOfService'
                         AND type = 'PK' )
    ALTER TABLE dbo.MedicareStatusIndicatorRulePlaceOfService
    ADD CONSTRAINT PK_MedicareStatusIndicatorRulePlaceOfService PRIMARY KEY CLUSTERED ( MedicareStatusIndicatorRuleId, PlaceOfService )
GO

IF OBJECT_ID('dbo.MedicareStatusIndicatorRuleProcedureCode', 'U') IS NOT NULL
AND NOT EXISTS (   SELECT 1
                  FROM   sys.key_constraints
                  WHERE  parent_object_id = OBJECT_ID('dbo.MedicareStatusIndicatorRuleProcedureCode')
                         AND name = 'PK_MedicareStatusIndicatorRuleProcedureCode'
                         AND type = 'PK' )
    ALTER TABLE dbo.MedicareStatusIndicatorRuleProcedureCode
    ADD CONSTRAINT PK_MedicareStatusIndicatorRuleProcedureCode PRIMARY KEY CLUSTERED ( MedicareStatusIndicatorRuleId, ProcedureCode )
GO

IF OBJECT_ID('dbo.MedicareStatusIndicatorRuleProviderSpecialty', 'U') IS NOT NULL
AND NOT EXISTS (   SELECT 1
                  FROM   sys.key_constraints
                  WHERE  parent_object_id = OBJECT_ID('dbo.MedicareStatusIndicatorRuleProviderSpecialty')
                         AND name = 'PK_MedicareStatusIndicatorRuleProviderSpecialty'
                         AND type = 'PK' )
    ALTER TABLE dbo.MedicareStatusIndicatorRuleProviderSpecialty
    ADD CONSTRAINT PK_MedicareStatusIndicatorRuleProviderSpecialty PRIMARY KEY CLUSTERED ( MedicareStatusIndicatorRuleId, ProviderSpecialty )
GO

-- SENTRY_ACTION
SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.SENTRY_ACTION')
          AND name = 'idx_ActionID'
)
    DROP INDEX idx_ActionID ON dbo.SENTRY_ACTION;

IF OBJECT_ID('dbo.PK_SENTRY_ACTION', 'PK') IS NULL
   AND OBJECT_ID('dbo.SENTRY_ACTION', 'U') IS NOT NULL
BEGIN
    ALTER TABLE dbo.SENTRY_ACTION
    ADD CONSTRAINT PK_SENTRY_ACTION
        PRIMARY KEY CLUSTERED (ActionID);
END;


COMMIT TRANSACTION;
GO

-- SENTRY_ACTION_CATEGORY
SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Sentry_Action_Category')
          AND name = 'idx_ActionCategory'
)
    DROP INDEX idx_ActionCategory ON dbo.Sentry_Action_Category;

IF OBJECT_ID('dbo.PK_SENTRY_ACTION_CATEGORY', 'PK') IS NULL
   AND OBJECT_ID('dbo.SENTRY_ACTION_CATEGORY', 'U') IS NOT NULL
BEGIN
    ALTER TABLE dbo.SENTRY_ACTION_CATEGORY
    ADD CONSTRAINT PK_SENTRY_ACTION_CATEGORY
        PRIMARY KEY CLUSTERED (ActionCategoryIDNo);
END;


COMMIT TRANSACTION;
GO

-- SENTRY_CRITERIA
SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.SENTRY_CRITERIA')
          AND name = 'idx_CriteriaID'
)
    DROP INDEX idx_CriteriaID ON dbo.SENTRY_CRITERIA;

IF OBJECT_ID('dbo.PK_SENTRY_CRITERIA', 'PK') IS NULL
   AND OBJECT_ID('dbo.SENTRY_CRITERIA', 'U') IS NOT NULL
BEGIN
    ALTER TABLE dbo.SENTRY_CRITERIA
    ADD CONSTRAINT PK_SENTRY_CRITERIA
        PRIMARY KEY CLUSTERED (CriteriaID);
END;


COMMIT TRANSACTION;
GO

-- Now, let's enable change tracking
SET XACT_ABORT ON;

DECLARE @Sql VARCHAR(MAX) ,@BaseFileName VARCHAR(300),@ProductKey VARCHAR(MAX),@SchemaName VARCHAR(MAX);

SET @Sql = 'IF NOT EXISTS (
    SELECT database_id
    FROM sys.change_tracking_databases 
    WHERE database_id = DB_ID()
    )
    ALTER DATABASE [' + DB_NAME() + ']
    SET CHANGE_TRACKING = ON 
    (CHANGE_RETENTION = 10 DAYS, AUTO_CLEANUP = ON);'

EXEC (@Sql);

-- For v1.1, we're going to change the retention period
-- from 7 to 10 days.
IF NOT EXISTS ( SELECT  1
                FROM    sys.change_tracking_databases ct
                WHERE   ct.database_id = DB_ID()
                        AND ct.retention_period = 10
                        AND ct.retention_period_units_desc = 'DAYS' )
BEGIN
    SET @Sql = 'ALTER DATABASE [' + DB_NAME() + '] SET CHANGE_TRACKING (CHANGE_RETENTION = 10 DAYS);'
    EXEC (@Sql);
END

-- Enable chnage tracking for tables in rpt.Process which are non snapshot tables
BEGIN TRANSACTION
BEGIN TRY
	DECLARE cr_tablename CURSOR FOR 
	SELECT BaseFileName,ProductKey 
	FROM rpt.Process
	WHERE IsSnapshot = 0

	OPEN cr_tablename

	FETCH NEXT FROM cr_tablename
	INTO @BaseFileName,@ProductKey
		
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @SchemaName = (SELECT CASE WHEN @ProductKey = 'DecisionPoint' THEN 'dbo' WHEN @ProductKey = 'DemandManager' AND EXISTS(SELECT 1 FROM sys.schemas WHERE name = 'aw') THEN 'aw' ELSE 'dm' END )
		SET @Sql =  'IF NOT EXISTS ( SELECT  object_id 
								FROM    sys.change_tracking_tables 
								WHERE object_id = OBJECT_ID('''+@SchemaName+'.'+@BaseFileName+''') ) 
				IF OBJECT_ID('''+@SchemaName+'.'+@BaseFileName+''', ''U'') IS NOT NULL 
				ALTER TABLE '+@SchemaName+'.'+@BaseFileName+'
				ENABLE CHANGE_TRACKING
				WITH(TRACK_COLUMNS_UPDATED = OFF);' 
	
	EXEC(@Sql)

	FETCH NEXT FROM cr_tablename
	INTO @BaseFileName,@ProductKey
	
	END

	CLOSE cr_tablename
	DEALLOCATE cr_tablename

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	PRINT 'Errors. Change Tracking Could not be enabled... '
	ROLLBACK TRANSACTION
END CATCH















