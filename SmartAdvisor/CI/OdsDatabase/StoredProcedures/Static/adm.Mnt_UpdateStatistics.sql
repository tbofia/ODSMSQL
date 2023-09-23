IF OBJECT_ID('adm.Mnt_UpdateStatistics', 'P') IS NOT NULL
    DROP PROCEDURE adm.Mnt_UpdateStatistics
GO
CREATE PROCEDURE adm.Mnt_UpdateStatistics(
@OdsCustomerId INT  = 0,
@ProcessId INT = 0)
AS
BEGIN
-- DECLARE @OdsCustomerId INT  = 0, @ProcessId INT = 5
-- Get Target table name for given process
DECLARE  @SQLQuery VARCHAR(MAX)
		,@Command VARCHAR(MAX)
		,@TargetTableName VARCHAR(100) = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId)
		,@TargetSchemaName VARCHAR(100) = (SELECT TargetSchemaName FROM adm.Process WHERE ProcessId = @ProcessId)


IF (@OdsCustomerId = 0) 
BEGIN 
	IF(@TargetTableName IS NULL) -- -- All Customers, All Active Tables
	BEGIN TRY
		SET @Command = '
		IF EXISTS(SELECT 1 FROM adm.Process WHERE OBJECT_ID(TargetSchemaName+''.''+TargetTableName) = OBJECT_ID(''?'')  AND IsActive = 1) -- Test is Table is Active
		BEGIN
			UPDATE STATISTICS ? WITH FULLSCAN;
		END';
		EXEC sp_MSforeachtable @command1=@Command,@whereand='and Schema_id=Schema_id(''src'')';
	END TRY
	BEGIN CATCH
		PRINT 'Could Not Update Statistics for ALL...Make sure you have the right permissions.';
	END CATCH

	ELSE -- All Customers, Specified Table
	BEGIN TRY
		SET @SQLQuery = 'UPDATE STATISTICS src.'+@TargetTableName+' WITH FULLSCAN;'
		EXEC (@SQLQuery);
	END TRY
	BEGIN CATCH
		PRINT 'Could Not Update Statistics for scr.'+@TargetTableName+'...Make sure you have the right permissions.';
	END CATCH

END
ELSE
BEGIN 
	IF(@TargetTableName IS NULL) -- -- Specified Customer, All Active Tables
	BEGIN TRY
		SET @Command = '
		DECLARE  @IX_Name VARCHAR(255);
		IF EXISTS(SELECT 1 FROM adm.Process WHERE OBJECT_ID(TargetSchemaName+''.''+TargetTableName) = OBJECT_ID(''?'')  AND IsActive = 1)
		BEGIN
			SELECT @IX_Name = I.name -- Get Clustered Index Name
			FROM sys.indexes I
			WHERE I.object_id = OBJECT_ID(''?'')
			AND I.type = 1;
			EXEC (''UPDATE STATISTICS ?(''+@IX_Name+'') WITH RESAMPLE ON PARTITIONS('+CAST(@OdsCustomerId AS VARCHAR(100))+')'');
		END';
		EXEC sp_MSforeachtable @command1=@Command,@whereand='and Schema_id=Schema_id(''src'')';
	END TRY
	BEGIN CATCH
		PRINT 'Could Not Update Statistics for All Tables for customer '+CAST(@OdsCustomerId AS VARCHAR(100))+'...Make sure you have the right permissions.';
	END CATCH
	ELSE 
	BEGIN TRY -- SPecified Customer, Specified Table
		DECLARE  @IX_Name VARCHAR(255);
		SELECT @IX_Name = I.name 
		FROM sys.indexes I
		WHERE I.object_id = OBJECT_ID(@TargetSchemaName+'.'+@TargetTableName)
		AND I.type = 1;
		SET @SQLQuery ='UPDATE STATISTICS '+@TargetSchemaName+'.'+@TargetTableName+'('+@IX_Name+') WITH RESAMPLE ON PARTITIONS('+CAST(@OdsCustomerId AS VARCHAR(100))+')';
		EXEC(@SQLQuery);
	END TRY
	BEGIN CATCH
		PRINT 'Could Not Update Statistics for scr.'+@TargetTableName+' for customer '+CAST(@OdsCustomerId AS VARCHAR(100))+'...Make sure you have the right permissions.';
	END CATCH
END 

END

GO
