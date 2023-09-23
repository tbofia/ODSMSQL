IF OBJECT_ID('rpt.GetBatchingInformation') IS NOT NULL
    DROP PROCEDURE rpt.GetBatchingInformation
GO

CREATE PROCEDURE rpt.GetBatchingInformation (
 @DataExtractTypeId INT 
,@DBSnapshotName VARCHAR(100) 
,@FileSize INT 
,@ProcessAuditId INT)
AS
BEGIN
	
	DECLARE  @BatchQuery NVARCHAR(MAX)
			,@FileSizeQuery NVARCHAR(MAX)
			,@BatchColumnQuery NVARCHAR(2000)
			,@BatchColumnName VARCHAR(128)
			,@BatchColumnType VARCHAR(50)
			,@NumberOfBatches INT = 0
			,@ProcessId INT = (SELECT ProcessId FROM rpt.ProcessAudit WHERE ProcessAuditId = @ProcessAuditId)
	
	IF OBJECT_ID('tempdb..#FileSize') IS NOT NULL DROP TABLE #FileSize
	CREATE TABLE #FileSize(
	TableName VARCHAR(25),
	TotalRows INT,
	TotalSpaceAllocated VARCHAR(500),
	TotalSpaceUsed VARCHAR(500),
	TotalSpaceforIndex VARCHAR(500),
	TotalUnusedSpace VARCHAR(500)
	);
	
	IF @DataExtractTypeId IN (1,2) AND @FileSize > 0
		BEGIN
			--dividing file size by 3 because that will expand 3 times after extracted to flat file
			SET @BatchQuery = 'SELECT @NumberOfBatches = CASE WHEN (((SUM(a.used_pages) * 8) / 1024))>'+CAST(@FileSize/3 AS VARCHAR(5))+' 
																	THEN ((((SUM(a.used_pages) * 8) / 1024))/'+CAST(@FileSize/3 AS VARCHAR(5))+'+1)
															  ELSE 1 
														 END
								FROM '+@DBSnapshotName+'.rpt.process pr	
								INNER JOIN  '+@DBSnapshotName+'.sys.tables t ON t.Name = pr.BaseFileName	
								INNER JOIN  '+@DBSnapshotName+'.sys.indexes i ON t.OBJECT_ID = i.object_id
								INNER JOIN  '+@DBSnapshotName+'.sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id 
								INNER JOIN  '+@DBSnapshotName+'.sys.allocation_units a ON p.partition_id = a.container_id
								WHERE pr.ProcessId = '+CAST(@ProcessId AS VARCHAR(10))

			EXEC sys.sp_executesql  @BatchQuery, N'@FileSize INT, @NumberOfBatches INT OUTPUT', 
									@FileSize = @FileSize,
									@NumberOfBatches = @NumberOfBatches OUTPUT
		END

	SET @BatchColumnQuery = 'SELECT @BatchColumnName  = C.ColumnName , @BatchColumnType = I.DATA_TYPE
							FROM '+@DBSnapshotName++'.rpt.ProcessColumn C
							INNER JOIN '+@DBSnapshotName+'.rpt.Process P 
							ON C.ProcessId = P.ProcessId
							INNER JOIN '+@DBSnapshotName+'.INFORMATION_SCHEMA.COLUMNS I
							ON I.TABLE_NAME = P.BaseFileName
							AND I.COLUMN_NAME = C.ColumnName
							WHERE C.ProcessId = '+CAST(@ProcessId AS VARCHAR(10))+' 
								  AND C.UseForBatchProcessing = 1'

	EXEC sys.sp_executesql @BatchColumnQuery, N'@BatchColumnName VARCHAR(100) OUTPUT, @BatchColumnType VARCHAR(50) OUTPUT'
						, @BatchColumnName = @BatchColumnName OUTPUT
						, @BatchColumnType = @BatchColumnType OUTPUT;

	SET @NumberOfBatches = CASE WHEN ISNULL(@NumberOfBatches,0) < 2 THEN 0
								--When We don't have column for splitting, we'll create single big extract file.
								WHEN @BatchColumnName IS NULL THEN 0
								ELSE @NumberOfBatches 
						   END

	SELECT @NumberOfBatches,@BatchColumnName,@BatchColumnType

END
GO
