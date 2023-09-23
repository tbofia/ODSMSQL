IF OBJECT_ID('adm.Etl_UpdateTargetColumnsWithStaging', 'P') IS NOT NULL
    DROP PROCEDURE adm.Etl_UpdateTargetColumnsWithStaging
GO

CREATE PROCEDURE adm.Etl_UpdateTargetColumnsWithStaging (
@CustomerId INT,
@SnapshotDate VARCHAR(50),
@OdsPostingGroupAuditId INT)
AS
BEGIN
-- DECLARE @CustomerId INT = 68, @SnapshotDate VARCHAR(50), @PostingGroupId INT = 1, @OdsPostingGroupAuditId INT = 23;

DECLARE  @ProcessId INT
		,@ProcessAuditId INT
		,@SQLQuery NVARCHAR(MAX)
		,@UpdateSQL NVARCHAR(MAX)
		,@JoinClause VARCHAR(MAX)
		,@TargetSchemaName CHAR(3)
		,@TargetTableName VARCHAR(255)
		,@TotalUpdatedRecords INT
		,@TotalRecordsInTarget BIGINT;

-- Check if all processes have been loaded	   
IF EXISTS (
SELECT 1
FROM stg.ETL_ControlFiles C
INNER JOIN adm.Process P ON C.TargetTableName = P.TargetTableName
	AND P.IsActive = 1
LEFT OUTER JOIN adm.ProcessAudit PA ON P.ProcessId = PA.ProcessId
	AND PA.Status IN ('I','FI')
	AND PA.PostingGroupAuditId = @OdsPostingGroupAuditId
WHERE C.SnapshotDate = @SnapshotDate
HAVING COUNT(DISTINCT P.ProcessId) = COUNT(DISTINCT PA.ProcessId))

BEGIN

	BEGIN TRANSACTION UpdateTrans
	BEGIN TRY 

	-- Get all Loaded Processes and their ProcessAuditids for update.
	DECLARE process_cursor CURSOR FOR  
	SELECT P.ProcessId, PA.ProcessAuditId
	FROM stg.ETL_ControlFiles C
	INNER JOIN adm.Process P ON C.TargetTableName = P.TargetTableName
		AND P.IsActive = 1
	INNER JOIN adm.ProcessAudit PA ON P.ProcessId = PA.ProcessId
		AND PA.Status = 'I'
		AND PA.PostingGroupAuditId = @OdsPostingGroupAuditId
	WHERE C.SnapshotDate = @SnapshotDate;
	
	OPEN process_cursor ;  
	FETCH NEXT FROM process_cursor INTO @ProcessId,@ProcessAuditId;

	WHILE @@FETCH_STATUS = 0   
	BEGIN
	
	SET @TargetSchemaName= (SELECT TargetSchemaName FROM adm.Process WHERE ProcessId = @ProcessId)
	SET @TargetTableName = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId)
	SET @JoinClause = NULL;
	 		
	SELECT @JoinClause =  COALESCE(@JoinClause+' AND ','')+'T.'+TargetColumnName+' = S.'+TargetColumnName
	FROM(
	SELECT DISTINCT I.COLUMN_NAME AS TargetColumnName
	FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE I
	INNER JOIN adm.Process P
		ON I.TABLE_NAME = P.TargetTableName
		AND OBJECTPROPERTY(OBJECT_ID(I.CONSTRAINT_SCHEMA + '.' + I.CONSTRAINT_NAME), 'IsPrimaryKey') = 1
		AND I.TABLE_SCHEMA = 'src'
	WHERE P.TargetTableName = @TargetTableName
		AND I.COLUMN_NAME NOT IN ('OdsPostingGroupAuditId')) AS T
		
	-- Build Update Script
	SET @UpdateSQL = 
	'UPDATE T'+CHAR(13)+CHAR(10)+
	'SET T.OdsRowIsCurrent = CASE WHEN T.OdsPostingGroupAuditId = '+CAST(@OdsPostingGroupAuditId AS VARCHAR(20))+ ' THEN 1 ELSE 0 END'+CHAR(13)+CHAR(10)+
	'FROM '+@TargetSchemaName+'.'+@TargetTableName+' T'+CHAR(13)+CHAR(10)+
	'INNER JOIN '+@TargetSchemaName+'.'+@TargetTableName+' S'+CHAR(13)+CHAR(10)+
	'	ON '+@JoinClause+CHAR(13)+CHAR(10)+
	'	AND S.OdsPostingGroupAuditId = '+CAST(@OdsPostingGroupAuditId AS VARCHAR(20))+CHAR(13)+CHAR(10)+
	'WHERE T.OdsCustomerId = '+CAST(@CustomerId AS VARCHAR(3))+CHAR(13)+CHAR(10)+
	'AND ((T.OdsRowIsCurrent = 1) OR (T.OdsRowIsCurrent = 0 AND T.OdsPostingGroupAuditId = '+CAST(@OdsPostingGroupAuditId AS VARCHAR(20))+'));'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)	
	
	-- Execute Update Statement for current process
	SET @UpdateSQL = @UpdateSQL + CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) + 'SELECT @TotalUpdatedRecords = @@ROWCOUNT'
	EXEC sp_executesql @UpdateSQL,N'@TotalUpdatedRecords INT OUT',@TotalUpdatedRecords OUT;

	-- Count Number of records in the target table based on last load
	SELECT TOP 1 @TotalRecordsInTarget = PA.TotalRecordsInTarget
	FROM adm.ProcessAudit PA WITH (NOLOCK)
	INNER JOIN adm.PostingGroupAudit PGA WITH (NOLOCK)
	ON PA.PostingGroupAuditId = PGA.PostingGroupAuditId
		AND PGA.Status = 'FI'
	WHERE PA.Status = 'FI'
		AND PGA.CustomerId = @CustomerId 
		AND PA.ProcessId = @ProcessId

	ORDER BY ProcessAuditId DESC

	-- Update adm.ProcessAudit Table with number of updated records
	UPDATE adm.ProcessAudit
	SET  Status = 'FI'
	 ,TotalRecordsInTarget = @TotalRecordsInTarget + (2*LoadRowCount - @TotalUpdatedRecords) - TotalDeletedRecords
	 ,LastUpdateDate = GETDATE()
	 ,UpdateRowCount = @TotalUpdatedRecords
	 ,LastChangeDate = GETDATE()
	WHERE ProcessAuditId = @ProcessAuditId

		-- Check if total records in source is equal to records in target and confirm by counting records in table
	IF EXISTS(SELECT ProcessAuditId FROM adm.ProcessAudit WHERE ProcessAuditId = @ProcessAuditId AND ISNULL(TotalRecordsInTarget,0) <> TotalRecordsInSource)
	BEGIN
		-- Count Number of records in the target table
		SET @SQLQuery = '
			 SELECT @TotalRecordsInTarget = COUNT(1)'+CHAR(13)+CHAR(10)+ 
			'FROM '+@TargetSchemaName+'.'+@TargetTableName+' T WITH (NOLOCK)'+CHAR(13)+CHAR(10)+ -- Use with Nolock because we want to include records in current transaction
			'WHERE T.OdsRowIsCurrent = 1'+CHAR(13)+CHAR(10)+
			'AND T.DmlOperation <> ''D'''+CHAR(13)+CHAR(10)+
			'AND T.OdsCustomerId = '+CAST(@CustomerId AS VARCHAR(3))+';'

		EXEC sp_executesql @SQLQuery ,N'@TotalRecordsInTarget BIGINT OUT',@TotalRecordsInTarget OUT;

		UPDATE adm.ProcessAudit
		SET  Status = 'FI'
		 ,TotalRecordsInTarget = @TotalRecordsInTarget
		 ,LastChangeDate = GETDATE()
		WHERE ProcessAuditId = @ProcessAuditId
	END
	  
	FETCH NEXT FROM process_cursor INTO @ProcessId,@ProcessAuditId;
	END
	
	CLOSE process_cursor;   
	DEALLOCATE process_cursor;
		
	COMMIT TRANSACTION UpdateTrans
	END TRY
	BEGIN CATCH
	ROLLBACK TRANSACTION UpdateTrans
	END CATCH

END

END

GO
