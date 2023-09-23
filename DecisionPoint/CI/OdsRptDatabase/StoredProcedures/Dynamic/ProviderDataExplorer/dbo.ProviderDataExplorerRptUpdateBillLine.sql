
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderAnalyticsRptUpdateBillLine') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderAnalyticsRptUpdateBillLine

GO 

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerRptUpdateBillLine') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerRptUpdateBillLine

GO 

CREATE PROCEDURE dbo.ProviderDataExplorerRptUpdateBillLine(
@SourceDatabaseName VARCHAR(50),
@SnapshotAsOf AS DATETIME,
@IsIncrementalLoad INT,
@Debug BIT,
@ReportId INT,
@OdsCustomerId INT)
AS
BEGIN

DECLARE 
		@OdsPostingGroupAuditId INT,
		@ProcessName VARCHAR(50),
		@AuditFor VARCHAR(100),
		@PostingGroupAuditIdQuery NVARCHAR(MAX);

DECLARE @PostingIdTable TABLE (PostingId INT);

-- Track the Audit for Customer
SET @AuditFor = 'OdsCustomerId : '+CAST(@OdsCustomerId AS VARCHAR(3));

-- Get the latest OdsPostingGroupAuditId from Source adm.PostingGroupAudit
SET @PostingGroupAuditIdQuery = N'SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerId AS VARCHAR(3))+','''+LEFT(CONVERT(VARCHAR,@SnapshotAsOf,110),10)+''')';
INSERT INTO @PostingIdTable EXEC (@PostingGroupAuditIdQuery)
SELECT @OdsPostingGroupAuditId = PostingId FROM @PostingIdTable;

-- Get the Process Name
SET @ProcessName = ( SELECT OBJECT_NAME(@@PROCID) );

-- Tracking Process start in ETL Audit
EXEC dbo.ProviderDataExplorerEtlAuditStart @AuditFor,@ProcessName,@OdsPostingGroupAuditId,@ReportId;

DECLARE @SQLScript VARCHAR(MAX),		
		@WhereClauseException VARCHAR(MAX),
		@WhereClauseCategory VARCHAR(MAX),
		@WhereClauseOldCode VARCHAR(MAX),
		@RunFromOdsPostingGroupAuditId INT;

-- Get OdsPostingGroupAuditId from ETLAudit table for Incremental Load
SET @RunFromOdsPostingGroupAuditId = dbo.GetMaxRunFromOdsPostingGroupAuditId(@ProcessName,@AuditFor,@ReportId)

SET @WhereClauseException =
	  CHAR(13)+CHAR(10)+'WHERE  bl.Category = @ODSPAPRCategory   AND cdq.ExceptionFlag = 1'	  
	+ CHAR(13)+CHAR(10)+CHAR(9) + ' AND bl.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))
	+ CHAR(13)+CHAR(10)+CHAR(9) + CASE WHEN @IsIncrementalLoad = 1 THEN ' AND bl.OdsPostingGroupAuditID > '+CAST(@RunFromOdsPostingGroupAuditId AS VARCHAR(50)) ELSE '' END	
	+ CHAR(13)+CHAR(10)+CHAR(9)

SET @WhereClauseCategory =
	  CHAR(13)+CHAR(10)+'WHERE  bl.Category = @ODSPAPRCategory AND cdq.Category IN (''Historical'',''Mitchell'')'
	+ CHAR(13)+CHAR(10)+CHAR(9) + ' AND bl.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))
	+ CHAR(13)+CHAR(10)+CHAR(9) + CASE WHEN @IsIncrementalLoad = 1 THEN ' AND bl.OdsPostingGroupAuditID > '+CAST(@RunFromOdsPostingGroupAuditId AS VARCHAR(50)) ELSE '' END	
	+ CHAR(13)+CHAR(10)+CHAR(9)
	 
SET @WhereClauseOldCode =
	  CHAR(13)+CHAR(10)+'WHERE  bl.Category = @ODSPAPRCategory '
	+ CHAR(13)+CHAR(10)+CHAR(9) + ' AND bl.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))
	+ CHAR(13)+CHAR(10)+CHAR(9) + CASE WHEN @IsIncrementalLoad = 1 THEN ' AND bl.OdsPostingGroupAuditID > '+CAST(@RunFromOdsPostingGroupAuditId AS VARCHAR(50)) ELSE '' END	
	+ CHAR(13)+CHAR(10)+CHAR(9)

SET @SQLScript = 
 '
	DECLARE @ODSPAPRCategory VARCHAR(50)
	SELECT @ODSPAPRCategory = ParameterValue FROM adm.ReportParameters WHERE ReportId=9 AND ParameterName=''ODSPAPRCategory'';

	/* Make ExceptionFlag is 1 where Invalid or Alternative Procedure Codes - Exclude */
	 UPDATE bl 
		SET bl.ExceptionFlag = 1,
			bl.ExceptionComments = ''Invalid or Alternative Procedure Codes - Exclude''
		FROM dbo.ProviderDataExplorerBillLine bl
		INNER JOIN rpt.ProviderDataExplorerPRCodeDataQuality cdq ON cdq.Code = bl.Code 
		'+@WhereClauseException +'; 

/*  update category and subcategory in bill lines */
UPDATE bl
	SET 
	bl.Category = cdq.Category,
	bl.SubCategory = cdq.SubCategory
FROM dbo.ProviderDataExplorerBillLine bl
INNER JOIN rpt.ProviderDataExplorerPRCodeDataQuality cdq ON cdq.Code = bl.Code 
'+@WhereClauseCategory +';


/*Set Old procedrue code mapped to new procedure codes.*/
UPDATE bl
SET
	bl.CodeType = cm.CodeType,
	bl.Category = cm.Category,
	bl.SubCategory = cm.SubCategory
 FROM dbo.ProviderDataExplorerBillLine bl 
INNER JOIN rpt.ProviderDataExplorerPRCodeDataQuality cdq ON cdq.Code = bl.Code 
												AND ISNULL(cdq.MappedCode,'''') <> '''' 
												AND ISNULL(cdq.MappedCode,'''') <> ''RC''
INNER JOIN rpt.ProviderDataExplorerCodeHierarchy cm ON cdq.MappedCode BETWEEN cm.CodeStart AND cm.CodeEnd 
														AND cm.CodeType IN (''CPT'',''HCPCS'',''CDT'')
 '+@WhereClauseOldCode+';

  
 /* Exclude Bills based on the CustomerBillExclusion list.*/

 UPDATE bl
        SET ExceptionFlag = 1,
			ExceptionComments = ''Bill excluded based on the CustomerBillExclusion list''
FROM dbo.ProviderDataExplorerBillLine bl 
JOIN stg.CustomerBillExclusionTemp t ON bl.OdsCustomerId = t.OdsCustomerId 
										   AND bl.BillId = t.BillIdNo ;
 
  IF OBJECT_ID(''stg.CustomerBillExclusionTemp'',''U'') IS NOT NULL					
	DROP TABLE stg.CustomerBillExclusionTemp;	
		 
	 '	 	 	  

IF (@Debug = 1)
BEGIN
	PRINT @AuditFor;
	PRINT @OdsPostingGroupAuditId;
	PRINT @ProcessName;
	PRINT @RunFromOdsPostingGroupAuditId;
	PRINT(@SQLScript);
END

EXEC(@SQLScript);

-- Tracking Process end in ETL Audit
EXEC dbo.ProviderDataExplorerEtlAuditEnd @AuditFor,@ProcessName,@OdsPostingGroupAuditId,@ReportId;

END
GO

