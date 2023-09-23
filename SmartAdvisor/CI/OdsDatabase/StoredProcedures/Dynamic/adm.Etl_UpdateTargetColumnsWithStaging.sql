IF OBJECT_ID('adm.Etl_UpdateTargetColumnsWithStaging', 'P') IS NOT NULL
    DROP PROCEDURE adm.Etl_UpdateTargetColumnsWithStaging
GO

CREATE PROCEDURE adm.Etl_UpdateTargetColumnsWithStaging (
@CustomerId INT,
@OdsPostingGroupAuditId INT,
@SnapshotDate VARCHAR(50))
AS
BEGIN
-- DECLARE @CustomerId INT = 1, @SnapshotDate VARCHAR(50) = '2018-12-14 17:32:19.000', @PostingGroupId INT = 1, @OdsPostingGroupAuditId INT = 5;

DECLARE  @ProcessId INT
		,@ProcessAuditId INT
		,@Status VARCHAR(2)
		,@IsSnapshot INT
		,@SQLQuery NVARCHAR(MAX)
		,@UpdateSQL NVARCHAR(MAX)=''
		,@JoinClause VARCHAR(MAX)
		,@DisableIdx VARCHAR(MAX)
		,@RebuildIdx VARCHAR(MAX)
		,@TargetSchemaName CHAR(3)
		,@TargetTableName VARCHAR(255)
		,@TotalUpdatedRecords INT
		,@TotalRecordsInTarget BIGINT
		,@SourceServer VARCHAR(255) = (SELECT ServerName FROM adm.Customer WHERE CustomerId = @CustomerId);

-- Check if all processes have been loaded	   
IF EXISTS (
SELECT 1
FROM stg.ETL_ControlFiles C
INNER JOIN adm.Process P ON C.TargetTableName = P.TargetTableName
	AND P.IsActive = 1
LEFT OUTER JOIN adm.ProcessAudit PA ON P.ProcessId = PA.ProcessId
	AND PA.Status IN ('I','U','FI')
	AND PA.PostingGroupAuditId = @OdsPostingGroupAuditId
WHERE C.SnapshotDate = @SnapshotDate
HAVING COUNT(DISTINCT P.ProcessId) = COUNT(DISTINCT PA.ProcessId))

BEGIN

	BEGIN TRANSACTION UpdateTrans
	BEGIN TRY 

	IF CURSOR_STATUS('global','process_cursor')>=-1
		DEALLOCATE process_cursor

	-- Get all Loaded Processes and their ProcessAuditids for update.
	DECLARE process_cursor CURSOR FOR  
	SELECT P.ProcessId, PA.ProcessAuditId,PA.Status
	FROM stg.ETL_ControlFiles C
	INNER JOIN adm.Process P ON C.TargetTableName = P.TargetTableName
	INNER JOIN adm.ProcessAudit PA ON P.ProcessId = PA.ProcessId
		AND PA.Status IN('I','U')
		AND PA.PostingGroupAuditId = @OdsPostingGroupAuditId
	WHERE C.SnapshotDate = @SnapshotDate;
	
	OPEN process_cursor ;  
	FETCH NEXT FROM process_cursor INTO @ProcessId,@ProcessAuditId,@Status;

	WHILE @@FETCH_STATUS = 0   
	BEGIN
	
	SET @TargetSchemaName= (SELECT TargetSchemaName FROM adm.Process WHERE ProcessId = @ProcessId)
	SET @TargetTableName = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId)
	SET @IsSnapshot = (SELECT IsSnapshot FROM adm.Process WHERE ProcessId = @ProcessId)
	SET @JoinClause = NULL;
	SET @DisableIdx  = NULL;
	SET @RebuildIdx = NULL;
	 		
	SELECT @JoinClause =  COALESCE(@JoinClause+' AND ','')+'T.'+TargetColumnName+' = S.'+TargetColumnName
	FROM(
	SELECT DISTINCT I.COLUMN_NAME AS TargetColumnName
	FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE I
	INNER JOIN adm.Process P
		ON I.TABLE_NAME = P.TargetTableName
		AND OBJECTPROPERTY(OBJECT_ID(I.CONSTRAINT_SCHEMA + '.' + I.CONSTRAINT_NAME), 'IsPrimaryKey') = 1
		AND I.TABLE_SCHEMA = 'src'
	WHERE P.TargetTableName = @TargetTableName
		AND I.COLUMN_NAME NOT IN ('OdsPostingGroupAuditId','OdsCustomerId')) AS T

	-- Disable all Non Clustered Indexes
	SELECT @DisableIdx = COALESCE(@DisableIdx,'')+'ALTER INDEX '+I.name+' ON '+@TargetSchemaName+'.'+@TargetTableName+' DISABLE;'+CHAR(13)+CHAR(10)
	FROM   sys.indexes I
	INNER JOIN sys.tables T
	ON  T.object_id = I.object_id
	WHERE T.name = @TargetTableName
		AND SCHEMA_NAME(T.schema_id) = @TargetSchemaName
		AND I.type = 2

	-- Rebuild all Non Clustered Indexes
	SELECT @RebuildIdx = COALESCE(@RebuildIdx,'')+'ALTER INDEX '+I.name+' ON '+@TargetSchemaName+'.'+@TargetTableName+' REBUILD;'+CHAR(13)+CHAR(10)
	FROM   sys.indexes I
	INNER JOIN sys.tables T
	ON  T.object_id = I.object_id
	WHERE T.name = @TargetTableName
		AND SCHEMA_NAME(T.schema_id) = @TargetSchemaName
		AND I.type = 2

	-- Build Update Script for Incremental
	IF @Status = 'I'
		SET @UpdateSQL = 
		'UPDATE T'+CHAR(13)+CHAR(10)+
		'SET  T.OdsRowIsCurrent = CASE WHEN T.OdsPostingGroupAuditId = '+CAST(@OdsPostingGroupAuditId AS VARCHAR(20))+ ' THEN 1 ELSE 0 END'+CHAR(13)+CHAR(10)+
		 CASE WHEN @IsSnapshot = 1 THEN CHAR(9)+',T.OdsCustomerId = 0'+CHAR(13)+CHAR(10) ELSE '' END+
		'FROM '+@TargetSchemaName+'.'+@TargetTableName+' T'+CHAR(13)+CHAR(10)+
		CASE WHEN @IsSnapshot = 1 THEN -- Do this Join For Core Tables so we can filter by Server
								'INNER JOIN adm.PostingGroupAudit PGA'+CHAR(13)+CHAR(10)+CHAR(9)+
								'ON T.OdsPostingGroupAuditId = PGA.PostingGroupAuditId'+CHAR(13)+CHAR(10)+
								'INNER JOIN adm.Customer C'+CHAR(13)+CHAR(10)+CHAR(9)+
								'ON PGA.CustomerId = C.CustomerId'+CHAR(13)+CHAR(10)
								ELSE '' END+
		'INNER JOIN '+@TargetSchemaName+'.'+@TargetTableName+' S'+CHAR(13)+CHAR(10)+
		'	ON '+@JoinClause+CHAR(13)+CHAR(10)+
		'	AND S.OdsPostingGroupAuditId = '+CAST(@OdsPostingGroupAuditId AS VARCHAR(20))+CHAR(13)+CHAR(10)+
		'WHERE '+CASE WHEN @IsSnapshot = 1 THEN 'C.ServerName = '''+@SourceServer+'''' ELSE 'T.OdsCustomerId = '+CAST(@CustomerId AS VARCHAR(3))+'' END+CHAR(13)+CHAR(10)+CHAR(9)+
		'AND ((T.OdsRowIsCurrent = 1) OR (T.OdsRowIsCurrent = 0 AND T.OdsPostingGroupAuditId = '+CAST(@OdsPostingGroupAuditId AS VARCHAR(20))+'));'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)	
	-- Build update script for fullload. 
	IF (@Status = 'U' AND @IsSnapshot = 1)
		SET @UpdateSQL = --@DisableIdx+CHAR(13)+CHAR(10)+
		'UPDATE T'+CHAR(13)+CHAR(10)+
		'SET OdsCustomerId = 0'+CHAR(13)+CHAR(10)+
		'FROM '+@TargetSchemaName+'.'+@TargetTableName+' T'+CHAR(13)+CHAR(10)+
		'WHERE T.OdsPostingGroupAuditId = '+CAST(@OdsPostingGroupAuditId AS VARCHAR(20))+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)--+
		--@RebuildIdx+CHAR(13)+CHAR(10)

	-- Execute Update Statement for current process
	SET @UpdateSQL = @UpdateSQL + CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) + 'SELECT @TotalUpdatedRecords = @@ROWCOUNT'
	EXEC sp_executesql @UpdateSQL,N'@TotalUpdatedRecords INT OUT',@TotalUpdatedRecords OUT;

	-- Get Number of records in the target table based on last load
	SELECT TOP 1 @TotalRecordsInTarget = PA.TotalRecordsInTarget
	FROM adm.ProcessAudit PA WITH (NOLOCK)
	INNER JOIN adm.PostingGroupAudit PGA WITH (NOLOCK)
	ON PA.PostingGroupAuditId = PGA.PostingGroupAuditId
		AND PGA.Status = 'FI'
	INNER JOIN adm.Customer C
	ON PGA.CustomerId = C.CustomerId
	WHERE PA.Status = 'FI'
		AND CASE WHEN @IsSnapshot = 1 THEN C.ServerName ELSE CAST(C.CustomerId AS VARCHAR(5)) END  = CASE WHEN @IsSnapshot = 1 THEN @SourceServer ELSE CAST(@CustomerId AS VARCHAR(5)) END		
		AND PA.ProcessId = @ProcessId

	ORDER BY ProcessAuditId DESC

	-- Update adm.ProcessAudit Table with number of updated records
	UPDATE adm.ProcessAudit
	SET  Status = 'FI'
	 ,TotalRecordsInTarget = @TotalRecordsInTarget + (2*LoadRowCount - @TotalUpdatedRecords) - TotalDeletedRecords
	 ,LastUpdateDate = GETDATE()
	 ,UpdateRowCount = CASE WHEN @Status = 'I' THEN @TotalUpdatedRecords END
	 ,LastChangeDate = GETDATE()
	WHERE ProcessAuditId = @ProcessAuditId

	-- Check if total records in source is equal to records in target and confirm by counting records in table
	IF EXISTS(SELECT PA.ProcessAuditId FROM adm.ProcessAudit PA INNER JOIN adm.Process P ON P.ProcessId = PA.ProcessId WHERE PA.ProcessAuditId = @ProcessAuditId AND P.IsSnapshot = 0 AND ISNULL(PA.TotalRecordsInTarget,0) <> PA.TotalRecordsInSource)
	BEGIN
		-- Count Number of records in the target table
		SET @SQLQuery = '
			 SELECT @TotalRecordsInTarget = COUNT(1)'+CHAR(13)+CHAR(10)+ 
			'FROM '+@TargetSchemaName+'.'+@TargetTableName+' T WITH (NOLOCK)'+CHAR(13)+CHAR(10)+ -- Use with Nolock because we want to include records in current transaction
			'INNER JOIN adm.PostingGroupAudit PGA'+CHAR(13)+CHAR(10)+CHAR(9)+
			'ON T.OdsPostingGroupAuditId = PGA.PostingGroupAuditId'+CHAR(13)+CHAR(10)+
			'INNER JOIN adm.Customer C'+CHAR(13)+CHAR(10)+CHAR(9)+
			'ON PGA.CustomerId = C.CustomerId'+CHAR(13)+CHAR(10)+
			'WHERE T.OdsRowIsCurrent = 1'+CHAR(13)+CHAR(10)+
			'AND T.DmlOperation <> ''D'''+CHAR(13)+CHAR(10)+
			'AND '+CASE WHEN @IsSnapshot = 1 THEN 'C.ServerName = '''+@SourceServer+'''' ELSE 'T.OdsCustomerId = '+CAST(@CustomerId AS VARCHAR(3))+'' END+';'

		EXEC sp_executesql @SQLQuery ,N'@TotalRecordsInTarget BIGINT OUT',@TotalRecordsInTarget OUT;

		UPDATE adm.ProcessAudit
		SET  Status = 'FI'
		 ,TotalRecordsInTarget = @TotalRecordsInTarget
		 ,LastChangeDate = GETDATE()
		WHERE ProcessAuditId = @ProcessAuditId
	END
	  
	FETCH NEXT FROM process_cursor INTO @ProcessId,@ProcessAuditId,@Status;
	END
	
	CLOSE process_cursor;   
	DEALLOCATE process_cursor;
		
	COMMIT TRANSACTION UpdateTrans
	END TRY
	BEGIN CATCH

	IF CURSOR_STATUS('global','process_cursor')>=-1
		DEALLOCATE process_cursor

	ROLLBACK TRANSACTION UpdateTrans
	END CATCH

END

END

GO
