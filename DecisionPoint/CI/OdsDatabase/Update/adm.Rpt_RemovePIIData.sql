IF OBJECT_ID('adm.Rpt_RemovePIIData') IS NOT NULL
DROP PROCEDURE adm.Rpt_RemovePIIData
GO

CREATE PROCEDURE adm.Rpt_RemovePIIData(
@OdsCustomerId INT = 0,
@ProcessId INT,
@DBSnapshotName VARCHAR(255) = NULL,
@IsIncremental INT = 1,
@RunPostingGroupAuditId INT,
@SQLSelect VARCHAR(MAX) OUTPUT,
@NumberOfBatches INT OUTPUT)
AS
BEGIN
--DECLARE @OdsCustomerId INT = 4,@ProcessId INT  = 5, @DBSnapshotName VARCHAR(255) = NULL,@IsIncremental INT = 1,@RunPostingGroupAuditId INT,@SQLSelect VARCHAR(MAX),@NumberOfBatches INT
DECLARE  @srcColumnList VARCHAR(MAX)
		,@TargetTableName VARCHAR(255)
		,@TargetSchemaName VARCHAR(50)
		,@BatchColumnName VARCHAR(128)

-- Determine number of batches to dump data in based on file size
IF @IsIncremental <> 1
BEGIN
	SELECT    @NumberOfBatches = CASE WHEN @ProcessId IN (5,9) THEN (((((SUM(a.used_pages) * 8) / 1024))/1024)/25)+11 ELSE (((((SUM(a.used_pages) * 8) / 1024))/1024)/25)+1 END
	FROM  adm.process pr 
	INNER JOIN  sys.tables t ON t.Name = pr.TargetTableName
	INNER JOIN  sys.indexes i ON t.OBJECT_ID = i.object_id
	INNER JOIN  sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
	INNER JOIN  sys.allocation_units a ON p.partition_id = a.container_id
	LEFT OUTER JOIN  sys.schemas s ON t.schema_id = s.schema_id
	WHERE s.Name = 'src' AND pr.ProcessId = @ProcessId 
	AND p.partition_id = CASE WHEN @OdsCustomerId = 0 THEN p.partition_id ELSE @OdsCustomerId END

	SELECT @BatchColumnName  = ColumnName FROM adm.ProcessColumn WHERE ProcessId = @ProcessId AND UseForBatchProcessing = 1
END
		
SET @DBSnapshotName = CASE WHEN @DBSnapshotName IS NULL THEN DB_NAME() ELSE @DBSnapshotName END
	
SET @TargetTableName  = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId)
SET @TargetSchemaName  = (SELECT TargetSchemaName FROM adm.Process WHERE ProcessId = @ProcessId)
-- 2.0 Get Colimn list for target table
SELECT @srcColumnList =  COALESCE(@srcColumnList+CHAR(13)+CHAR(10)+CHAR(9)+',','')+CASE WHEN PC.HoldsPII = 1 THEN ISNULL(PC.ObfuscateWithValue,'NULL') ELSE COLUMN_NAME END
FROM INFORMATION_SCHEMA.COLUMNS C
LEFT OUTER JOIN adm.Process P
	ON C.TABLE_NAME = P.TargetTableName
LEFT OUTER JOIN adm.ProcessColumn PC
	ON P.ProcessId = PC.ProcessId
	AND C.COLUMN_NAME = PC.ColumnName
WHERE TABLE_SCHEMA = @TargetSchemaName
AND TABLE_NAME = @TargetTableName
ORDER BY ORDINAL_POSITION;


SET @NumberOfBatches = CASE WHEN ISNULL(@NumberOfBatches,0) < 2 THEN 0 ELSE @NumberOfBatches END

-- Build SELECT Statement (@srcColumnList)
SET @SQLSelect = 'SELECT '+@srcColumnList+CHAR(13)+CHAR(10)+'FROM '+@DBSnapshotName+'.'+@TargetSchemaName+'.'+@TargetTableName + 
	CASE WHEN @OdsCustomerId <> 0 THEN CHAR(13)+CHAR(10)+'WHERE OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END+
	CASE WHEN @NumberOfBatches > 1 THEN CASE WHEN @OdsCustomerId <> 0 THEN ' AND ' ELSE CHAR(13)+CHAR(10)+'WHERE ' END + 'ABS('+@BatchColumnName+')  % '+CAST(@NumberOfBatches AS VARCHAR(5))+' = <BatchId>' ELSE '' END+
	CASE WHEN @IsIncremental = 1 THEN CASE WHEN @OdsCustomerId <> 0 THEN ' AND ' ELSE CHAR(13)+CHAR(10)+'WHERE ' END + 'OdsPostingGroupAuditId >= '+CAST(ISNULL(@RunPostingGroupAuditId,0) AS VARCHAR(20)) ELSE '' END

END
GO