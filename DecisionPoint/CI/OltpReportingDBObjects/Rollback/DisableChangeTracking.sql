

-- Disable change tracking for tables in rpt.Process which are non snapshot tables
SET XACT_ABORT ON;

DECLARE @Sql VARCHAR(MAX) ,@BaseFileName VARCHAR(300),@ProductKey VARCHAR(MAX),@SchemaName VARCHAR(MAX)
		,@MinOdsVersion VARCHAR(10) ;
SET @MinOdsVersion = ( SELECT TOP 1 LEFT(AppVersion, CHARINDEX('.', AppVersion, CHARINDEX('.', AppVersion)+1)-1) FROM rpt.AppVersion 
						ORDER BY [AppVersionId] DESC )

BEGIN TRANSACTION
BEGIN TRY
	DECLARE cr_tablename CURSOR FOR 
	SELECT BaseFileName,ProductKey 
	FROM rpt.Process
	WHERE IsSnapshot = 0
	AND MinODSVersion = @MinOdsVersion


	OPEN cr_tablename

	FETCH NEXT FROM cr_tablename
	INTO @BaseFileName,@ProductKey
		
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @SchemaName = (SELECT CASE WHEN @ProductKey = 'DecisionPoint' THEN 'dbo' WHEN @ProductKey = 'DemandManager' AND EXISTS(SELECT 1 FROM sys.schemas WHERE name = 'aw') THEN 'aw' ELSE 'dm' END )
		SET @Sql =  'IF EXISTS ( SELECT  object_id 
								FROM    sys.change_tracking_tables 
								WHERE object_id = OBJECT_ID('''+@SchemaName+'.'+@BaseFileName+''') ) 
				IF OBJECT_ID('''+@SchemaName+'.'+@BaseFileName+''', ''U'') IS NOT NULL 
				ALTER TABLE '+@SchemaName+'.'+@BaseFileName+'
			    DISABLE CHANGE_TRACKING ' 
	
	EXEC (@Sql)

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


-- ONLY FOR THIS RELEASE - 10.8 CHANGES FOR THOSE THREE TABLES
-- This was originally configured as a dynamic table. 
-- It's dev static, so let's Enable Change Tracking and reset the checkpoint value.
SET XACT_ABORT ON;
IF NOT EXISTS
(
    SELECT object_id
    FROM sys.change_tracking_tables
    WHERE object_id = OBJECT_ID('dbo.UdfDataFormat')
) AND EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'dbo' 
                 AND  TABLE_NAME = 'UdfDataFormat')
BEGIN
    BEGIN TRANSACTION;

       -- Enable Change Tracking
    ALTER TABLE dbo.UdfDataFormat ENABLE CHANGE_TRACKING
	WITH(TRACK_COLUMNS_UPDATED = OFF);
       
       -- Reset the checkpoint for this table
    UPDATE pc
    SET pc.PreviousCheckpoint = 0
    FROM rpt.ProcessCheckpoint pc
        INNER JOIN rpt.Process p
            ON p.ProcessId = pc.ProcessId
    WHERE p.BaseFileName ='UdfDataFormat';

    COMMIT TRANSACTION;
END;
GO

SET XACT_ABORT ON;
IF NOT EXISTS
(
    SELECT object_id
    FROM sys.change_tracking_tables
    WHERE object_id = OBJECT_ID('dbo.VpnSavingTransactionType')
) AND EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'dbo' 
                 AND  TABLE_NAME = 'VpnSavingTransactionType')
BEGIN
    BEGIN TRANSACTION;

       -- Enable Change Tracking
    ALTER TABLE dbo.VpnSavingTransactionType ENABLE CHANGE_TRACKING
	WITH(TRACK_COLUMNS_UPDATED = OFF);
       
       -- Reset the checkpoint for this table
    UPDATE pc
    SET pc.PreviousCheckpoint = 0
    FROM rpt.ProcessCheckpoint pc
        INNER JOIN rpt.Process p
            ON p.ProcessId = pc.ProcessId
    WHERE p.BaseFileName ='VpnSavingTransactionType';

    COMMIT TRANSACTION;
END;
GO



SET XACT_ABORT ON;
IF NOT EXISTS
(
    SELECT object_id
    FROM sys.change_tracking_tables
    WHERE object_id = OBJECT_ID('dbo.VpnProcessFlagType')
) AND EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'dbo' 
                 AND  TABLE_NAME = 'VpnProcessFlagType')
BEGIN
    BEGIN TRANSACTION;

       -- Enable Change Tracking
    ALTER TABLE dbo.VpnProcessFlagType ENABLE CHANGE_TRACKING
	WITH(TRACK_COLUMNS_UPDATED = OFF);
       
       -- Reset the checkpoint for this table
    UPDATE pc
    SET pc.PreviousCheckpoint = 0
    FROM rpt.ProcessCheckpoint pc
        INNER JOIN rpt.Process p
            ON p.ProcessId = pc.ProcessId
    WHERE p.BaseFileName ='VpnProcessFlagType';

    COMMIT TRANSACTION;
END;
GO


