IF OBJECT_ID('adm.Mnt_MergeCustomersDataByPostingGroupsAuditId', 'P') IS NOT NULL
    DROP PROCEDURE adm.Mnt_MergeCustomersDataByPostingGroupsAuditId
GO

CREATE PROCEDURE adm.Mnt_MergeCustomersDataByPostingGroupsAuditId(
@CustomerId INT,
@MergedCustomerId INT,
@OdsPostingGroupAuditId INT,
@returnstatus INT OUTPUT)
AS
BEGIN

--DECLARE  @CustomerId INT = 58		,@MergedCustomerId INT = 21		,@OdsPostingGroupAuditId INT = 55517

DECLARE  @ProcessId INT=124
		,@SQLScript NVARCHAR(MAX)
		,@JoinClause VARCHAR(MAX)
		,@TargetSchemaName CHAR(3)
		,@ProductSchemaName CHAR(3)
		,@TargetTableName VARCHAR(255)
		,@LastPostingGroupAuditId INT;

BEGIN TRANSACTION UpdateTrans
BEGIN TRY
	DECLARE process_cursor CURSOR FOR  
	SELECT DISTINCT P.ProcessId
	FROM adm.Process P
	INNER JOIN adm.ProcessAudit PA
	ON P.ProcessId = PA.ProcessId
	WHERE PA.PostingGroupAuditId = @OdsPostingGroupAuditId;
	
	OPEN process_cursor ;  
	FETCH NEXT FROM process_cursor INTO @ProcessId

	WHILE @@FETCH_STATUS = 0   
	BEGIN
		SET @TargetSchemaName= (SELECT TargetSchemaName FROM adm.Process WHERE ProcessId = @ProcessId);
		SET @TargetTableName = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId);
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
			AND I.COLUMN_NAME NOT IN ('OdsPostingGroupAuditId')) AS T;

		SET @SQLScript = 
		'UPDATE '+@TargetSchemaName+'.'+@TargetTableName+CHAR(13)+CHAR(10)+
		'SET OdsCustomerId = '+CAST(@CustomerId AS VARCHAR(3))+CHAR(13)+CHAR(10)+
		'WHERE OdsCustomerId = '+CAST(@MergedCustomerId AS VARCHAR(3))+CHAR(13)+CHAR(10)+
		'AND OdsPostingGroupAuditId = '+CAST(@OdsPostingGroupAuditId AS VARCHAR(20))+';'+CHAR(13)+CHAR(10)+CHAR(10)

	
			-- Build Update Script
		SET @SQLScript = @SQLScript +
		'UPDATE T'+CHAR(13)+CHAR(10)+
		'SET T.OdsRowIsCurrent = CASE WHEN T.OdsPostingGroupAuditId = '+CAST(@OdsPostingGroupAuditId AS VARCHAR(20))+ ' THEN 1 ELSE 0 END'+CHAR(13)+CHAR(10)+
		'FROM '+@TargetSchemaName+'.'+@TargetTableName+' T'+CHAR(13)+CHAR(10)+
		'INNER JOIN '+@TargetSchemaName+'.'+@TargetTableName+' S'+CHAR(13)+CHAR(10)+
		'	ON '+@JoinClause+CHAR(13)+CHAR(10)+
		'	AND S.OdsPostingGroupAuditId = '+CAST(@OdsPostingGroupAuditId AS VARCHAR(20))+CHAR(13)+CHAR(10)+
		'WHERE T.OdsCustomerId = '+CAST(@CustomerId AS VARCHAR(3))+CHAR(13)+CHAR(10)+
		'AND ((T.OdsRowIsCurrent = 1) OR (T.OdsRowIsCurrent = 0 AND T.OdsPostingGroupAuditId = '+CAST(@OdsPostingGroupAuditId AS VARCHAR(20))+'));'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)	

		EXEC(@SQLScript);

		FETCH NEXT FROM process_cursor INTO @ProcessId;
	END

	CLOSE process_cursor;   
	DEALLOCATE process_cursor;

	UPDATE adm.PostingGroupAudit 
	SET Customerid = @CustomerId
	WHERE PostingGroupAuditId = @OdsPostingGroupAuditId;

	COMMIT TRANSACTION UpdateTrans
	SET @returnstatus = 0
END TRY
BEGIN CATCH
IF CURSOR_STATUS('global','process_cursor')>=-1
BEGIN
	CLOSE process_cursor;   
	DEALLOCATE process_cursor;
END
ROLLBACK TRANSACTION UpdateTrans
SET @returnstatus = 1
END CATCH

END

GO


