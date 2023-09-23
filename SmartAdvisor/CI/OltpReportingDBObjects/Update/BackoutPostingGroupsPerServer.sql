--This script will backout all the posting groups created after @SnapshotCreateDate for all the qualified customers in the @ListofCustomerDatabase.

--STEP 1: Let's create a temp table for all the qualified customers along with the posting group audit ids in descending order.
DECLARE @SnapshotCreateDate VARCHAR(20) = '2019-08-05'
		, @SchemaName VARCHAR(50) = 'rpt'
		, @TableName VARCHAR(50) = 'PostingGroupAudit'
		, @ListofCustomerDatabase VARCHAR(MAX) = '''SAACTPROD'',''SAALDPROD'',''SAAMFPROD'',''SABRSPROD'',''SACALPROD'',''SACYPPROD'',''SAEKHPROD'',''SAFIDPROD'',''SAGALPROD'',''SAGUAPROD'',''SAHUGPROD'',''SAICSPROD'',''SALWCPROD'',''SAMIAPROD'',''SAOCUPROD'',''SAPAIPROD'',''SAPCPPROD'',''SAPCSPROD'',''SAPMIPROD'',''SARNYPROD'',''SASENPROD'',''SASFMPROD'',''SASLIPROD'',''SAZENPROD'',''V40A01PROD'',''V40ACSPROD'',''V40AL1PROD'',''V40ARLPROD'',''V40CASPROD'',''V40CC1PROD'',''V40CS1PROD'',''V40CT1PROD'',''V40CW1PROD'',''V40EC1PROD'',''V40FC1PROD'',''V40FCIPROD'',''V40FD1PROD'',''V40FMCPROD'',''V40GB1PROD'',''V40HE1PROD'',''V40IOSPROD'',''V40KRMPROD'',''V40MCNPROD'',''V40ME1PROD'',''V40NJGPROD'',''V40PALPROD'',''V40PM1PROD'',''V40PM2PROD'',''V40PRAPROD'',''V40PRCPROD'',''V40PROPROD'',''V40PX1PROD'',''V40RMSPROD'',''V40RW1PROD'',''V40SCOPROD'',''V40SELPROD'',''V40SF1PROD'',''V40SFSPROD'',''V40TMIPROD'',''V40TQCPROD'',''V40TY1PROD'',''V40WR1PROD'',''V40ZU1PROD'',''V4IC1PROD''';

DECLARE @Command VARCHAR(MAX) ='USE [?]; IF OBJECT_ID('''+@SchemaName+'.'+@TableName+''') IS NOT NULL 
											AND (SELECT source_database_id from sys.databases where db_name() = name) IS NULL
											INSERT INTO #cleanup (DBName, PostingGroupAuditId) select ''?'', PostingGroupAuditId 
											FROM rpt.PostingGroupAudit 
											WHERE snapshotCreateDate > '''+@SnapshotCreateDate+'''
												AND DB_NAME() IN ('+@ListofCustomerDatabase+')
											ORDER BY PostingGroupAuditId DESC '

IF OBJECT_ID('tempdb..#cleanup') IS NOT NULL 
	DROP TABLE #cleanup

CREATE TABLE #cleanup (
				 ID INT IDENTITY(1,1) NOT NULL, 
				 DBName VARCHAR(50) NOT NULL, 
				 PostingGroupAuditId INT NOT NULL
				)

EXEC sp_MSforeachdb @Command;

--select * from #cleanup


--STEP 2: Loop thru it and clean up in order.
DECLARE @ID INT, @DBName VARCHAR(50), @PostingGroupAuditId INT;
DECLARE Cursor_Cleanup CURSOR FOR 
SELECT ID, DBName, PostingGroupAuditId
FROM #cleanup
ORDER BY ID ASC;

OPEN Cursor_Cleanup

FETCH NEXT FROM Cursor_Cleanup INTO @ID, @DBName,@PostingGroupAuditId

WHILE @@FETCH_STATUS = 0
BEGIN

	DECLARE @exec NVARCHAR(500) = QUOTENAME(@DBName) + N'.sys.sp_Executesql'
			, @sql  NVARCHAR(MAX) = N'
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRANSACTION;

	DECLARE @PostingGroupAuditId INT = '+CAST(@PostingGroupAuditId AS NVARCHAR(50))+',
			@Status VARCHAR(2) ,
			@Message VARCHAR(100);
	
	UPDATE rpt.PostingGroupAudit
	SET status = ''01''
	WHERE Status = ''FI'' AND PostingGroupAuditId = @PostingGroupAuditId;

	-- What was the last posting group?
	SELECT @PostingGroupAuditId = MAX(PostingGroupAuditId)
	FROM   rpt.PostingGroupAudit;

	-- What was the status of this posting group?
	SELECT @Status = Status
	FROM   rpt.PostingGroupAudit
	WHERE  PostingGroupAuditId = @PostingGroupAuditId;

	IF @Status = ''FI'' OR @Status IS NULL
		BEGIN
			PRINT ''Nothing to do here.  Aborting...'';
			ROLLBACK TRANSACTION;
			RETURN;
		END;

	-- Do we have any extracts created after the posting group we''re trying to rollback?
	IF EXISTS (   SELECT TOP 1 1
				  FROM   rpt.PostingGroupAudit
				  WHERE  PostingGroupAuditId > @PostingGroupAuditId )
		BEGIN
			RAISERROR(''You can''''t back out this posting group without backing out subsequent posting groups!  Aborting...'', 16, 1) WITH LOG;
			ROLLBACK TRANSACTION;
			RETURN;
		END;

	UPDATE pc
	SET    pc.PreviousCheckpoint = psa.PreviousCheckpoint
	FROM   rpt.ProcessCheckpoint pc
		   INNER JOIN rpt.ProcessAudit pa ON pc.ProcessId = pa.ProcessId
		   INNER JOIN rpt.ProcessStepAudit psa ON pa.ProcessAuditId = psa.ProcessAuditId
	WHERE  pa.PostingGroupAuditId = @PostingGroupAuditId;

	DELETE FROM a
	FROM  rpt.ProcessStepAudit a
		  INNER JOIN rpt.ProcessAudit b ON a.ProcessAuditId = b.ProcessAuditId
		  INNER JOIN rpt.PostingGroupAudit c ON b.PostingGroupAuditId = c.PostingGroupAuditId
	WHERE c.PostingGroupAuditId = @PostingGroupAuditId;

	DELETE FROM b
	FROM  rpt.ProcessAudit b
		  INNER JOIN rpt.PostingGroupAudit c ON b.PostingGroupAuditId = c.PostingGroupAuditId
	WHERE c.PostingGroupAuditId = @PostingGroupAuditId;

	DELETE FROM c
	FROM  rpt.PostingGroupAudit c
	WHERE c.PostingGroupAuditId = @PostingGroupAuditId;

	SET @Message = ''Successfully removed PostingGroupAuditId '' + CAST(@PostingGroupAuditId AS VARCHAR(20)) + '' from database '' + DB_NAME();
	PRINT @Message;

	COMMIT TRANSACTION;';

	EXEC @exec @sql;

	FETCH NEXT FROM Cursor_Cleanup INTO @ID, @DBName,@PostingGroupAuditId
END

CLOSE Cursor_Cleanup;  
DEALLOCATE Cursor_Cleanup; 

