IF OBJECT_ID('adm.Mnt_DeleteLastLoadedPostingGroupAudit', 'P') IS NOT NULL
    DROP PROCEDURE adm.Mnt_DeleteLastLoadedPostingGroupAudit
GO

CREATE PROCEDURE adm.Mnt_DeleteLastLoadedPostingGroupAudit (
@CustomerId INT,
@OdsPostingGroupAuditId INT)
AS
BEGIN
-- DECLARE @CustomerId INT=44,@OdsPostingGroupAuditId INT=54222
DECLARE  @ProcessId INT 
		,@SQLScript NVARCHAR(MAX)
		,@JoinClause VARCHAR(MAX)
		,@TargetSchemaName CHAR(3)
		,@ProductSchemaName CHAR(3)
		,@TargetTableName VARCHAR(255)
		,@LastPostingGroupAuditId INT;

IF NOT EXISTS(SELECT 1 FROM adm.PostingGroupAudit WHERE CustomerId = @CustomerId AND PostingGroupAuditId > @OdsPostingGroupAuditId)
BEGIN
	
	BEGIN TRANSACTION UpdateTrans
	BEGIN TRY 

	-- Get all Loaded Processes and their ProcessAuditids for update.
	DECLARE process_cursor CURSOR FOR  
	SELECT DISTINCT P.ProcessId
	FROM adm.Process P 
	INNER JOIN adm.ProcessAudit PA
	ON P.ProcessId = PA.ProcessId
	INNER JOIN adm.PostingGroupAudit PGA
	ON PA.PostingGroupAuditId = PGA.PostingGroupAuditId
	WHERE PGA.PostingGroupAuditId = @OdsPostingGroupAuditId
	ORDER BY 1;	
	
	OPEN process_cursor ;  
	FETCH NEXT FROM process_cursor INTO @ProcessId;

	WHILE @@FETCH_STATUS = 0   
	BEGIN

	SET @TargetSchemaName= (SELECT TargetSchemaName FROM adm.Process WHERE ProcessId = @ProcessId)
	SET @TargetTableName = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId)
	SET @ProductSchemaName = (SELECT Product.SchemaName FROM adm.Process INNER JOIN adm.Product ON Process.ProductKey = Product.ProductKey WHERE ProcessId = @ProcessId) 

	SET @JoinClause = NULL; SET @SQLScript= NULL;
	 		
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
		
	-- Build Update Script to reset the old records back to rowiscurrent status
	SET @SQLScript = 
	'UPDATE T'+CHAR(13)+CHAR(10)+
	'SET T.OdsRowIsCurrent = 1'+CHAR(13)+CHAR(10)+
	'FROM '+@TargetSchemaName+'.'+@TargetTableName+' T'+CHAR(13)+CHAR(10)+
	'INNER JOIN '+@ProductSchemaName+'.if_'+@TargetTableName+'('+CAST(@OdsPostingGroupAuditId-1 AS VARCHAR(20))+ ') F'+CHAR(13)+CHAR(10)+
	'	ON '+REPLACE(@JoinClause,'S.','F.')+CHAR(13)+CHAR(10)+
	'	AND F.OdsPostingGroupAuditId = T.OdsPostingGroupAuditId'+CHAR(13)+CHAR(10)+
	'INNER JOIN '+@TargetSchemaName+'.'+@TargetTableName+' S'+CHAR(13)+CHAR(10)+
	'	ON '+@JoinClause+CHAR(13)+CHAR(10)+
	'	AND S.OdsPostingGroupAuditId = '+CAST(@OdsPostingGroupAuditId AS VARCHAR(20))+CHAR(13)+CHAR(10)+
	'WHERE T.OdsCustomerId = '+CAST(@CustomerId AS VARCHAR(3))+CHAR(13)+CHAR(10)+
	'AND T.OdsRowIsCurrent = 0;'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+	
	
	-- Delete Records loaded in this posting group
	'DELETE FROM '+@TargetSchemaName+'.'+@TargetTableName+CHAR(13)+CHAR(10)+
	'WHERE OdsPostingGroupAuditId = '+CAST(@OdsPostingGroupAuditId AS VARCHAR(20))+';'+CHAR(13)+CHAR(10)+CHAR(10)+
	-- Clean up the Process Audit records
	'DELETE P'+CHAR(13)+CHAR(10)+
	'FROM adm.ProcessAudit P'+CHAR(13)+CHAR(10)+
	'INNER JOIN adm.PostingGroupAudit PGA'+CHAR(13)+CHAR(10)+
	'	ON P.PostingGroupAuditId = PGA.PostingGroupAuditId'+CHAR(13)+CHAR(10)+
	'	AND PGA.PostingGroupAuditId = '+CAST(@OdsPostingGroupAuditId AS VARCHAR(20))+CHAR(13)+CHAR(10)+
	'WHERE P.ProcessId = '+CAST(@ProcessId AS VARCHAR(20))+';'+CHAR(13)+CHAR(10)

	EXEC(@SQLScript);

	FETCH NEXT FROM process_cursor INTO @ProcessId;

	END

	CLOSE process_cursor;   
	DEALLOCATE process_cursor;

	-- Clean up the Posting group audit record
	DELETE FROM adm.PostingGroupAudit WHERE PostingGroupAuditId = @OdsPostingGroupAuditId;
		
	COMMIT TRANSACTION UpdateTrans
	END TRY
	BEGIN CATCH
	
	PRINT 'Ops! Something went wrong Deleting the data...';

	IF CURSOR_STATUS('global','process_cursor')>=-1
	BEGIN
	CLOSE process_cursor;   
	DEALLOCATE process_cursor;
	END
	ROLLBACK TRANSACTION UpdateTrans
	END CATCH
END
END
GO

