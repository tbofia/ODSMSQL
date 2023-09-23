IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderAnalyticsRptUpdateProvider') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderAnalyticsRptUpdateProvider
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerRptUpdateProvider') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerRptUpdateProvider
GO

CREATE PROCEDURE dbo.ProviderDataExplorerRptUpdateProvider(
@SourceDatabaseName VARCHAR(50),
@SnapshotAsOf AS DATETIME,
@IsIncrementalLoad INT,
@Debug BIT,
@ReportId INT,
@OdsCustomerId INT
)
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
		@WhereClause VARCHAR(MAX),
		@RunFromOdsPostingGroupAuditId INT;

-- Get OdsPostingGroupAuditId from ETLAudit table for Incremental Load
SET @RunFromOdsPostingGroupAuditId = dbo.GetMaxRunFromOdsPostingGroupAuditId(@ProcessName,@AuditFor,@ReportId)

SET @WhereClause =
	  CHAR(13)+CHAR(10)+'WHERE '
	+ CHAR(13)+CHAR(10)+CHAR(9) + ' p.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))
	+ CHAR(13)+CHAR(10)+CHAR(9) + CASE WHEN @IsIncrementalLoad = 1 THEN ' AND p.OdsPostingGroupAuditID > '+CAST(@RunFromOdsPostingGroupAuditId AS VARCHAR(50)) ELSE '' END	
	+ CHAR(13)+CHAR(10)+CHAR(9);

SET @SQLScript = CAST('' AS VARCHAR(MAX))+
' 
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
/* Step1: Fetch all records for Specialty field from ProviderDataExplorerProvider */

 IF OBJECT_ID(''tempdb..#ProviderSPCLists'') IS NOT NULL
            DROP TABLE #ProviderSPCLists;
BEGIN
 SELECT *,ROW_NUMBER() OVER(ORDER BY ProviderSPCList) AS Cnt INTO #ProviderSPCLists 
 FROM ( 
		SELECT  
			 OdsCustomerId ,
			 ProviderSPCList,
			 Specialty,
			 ProviderClusterId  
		FROM dbo.ProviderDataExplorerProvider p 
		'+@WhereClause +' 
	  ) AS base
 
END

 /* Step2: Splittig the multiple values to atomic */

 IF OBJECT_ID(''tempdb..#ProviderSPCListsResult'') IS NOT NULL
			 DROP TABLE #ProviderSPCListsResult;
    BEGIN
		SELECT 
			Cnt,
			OdsCustomerId,
			ProviderClusterId,
			LTRIM(RTRIM(m.n.value(''.[1]'',''VARCHAR(8000)''))) AS ProviderSpecialty
		INTO #ProviderSPCListsResult
		FROM
			(
			SELECT 
				Cnt,
				OdsCustomerId,				
				ProviderClusterId,
				CAST(''<XMLRoot><RowData>'' + REPLACE(Specialty,'':'',''</RowData><RowData>'') + ''</RowData></XMLRoot>'' AS XML) AS x
			FROM  #ProviderSPCLists
			)t  
			CROSS APPLY x.nodes(''/XMLRoot/RowData'')m(n)

END

/*STEP:3  Excluding xx specialty*/
DELETE  #ProviderSPCListsResult  WHERE ProviderSpecialty like''%Unknown Physician Specialty%''


/* Step4: Clusterwise distinct specialties insert them to #ClusterSpecialtyLists */

 IF OBJECT_ID(''tempdb..#ClusterSpecialtyLists'') IS NOT NULL
              DROP TABLE #ClusterSpecialtyLists;
	BEGIN
		SELECT DISTINCT * INTO #ClusterSpecialtyLists FROM 
		(SELECT 
				OdsCustomerId,
				ProviderClusterId, 
		        ClusterSpecialty = STUFF(
									 (SELECT DISTINCT  '','' + ProviderSpecialty FROM #ProviderSPCListsResult t1 
									  WHERE t1.ProviderClusterId = t2.ProviderClusterId AND t1.OdsCustomerId = t2.OdsCustomerId FOR XML PATH ('''')), 1, 1, '''')
					   	 
			FROM #ProviderSPCListsResult t2 
		)AS t1
	END


	IF EXISTS (SELECT Name FROM tempdb.sys.indexes
	WHERE Name = ''IX_ClusterSpecialtyLists''
	AND OBJECT_ID = OBJECT_ID(''tempdb..#ClusterSpecialtyLists''))
	BEGIN	
	DROP INDEX IX_ClusterSpecialtyLists ON #ClusterSpecialtyLists ;	
	END
	CREATE INDEX IX_ClusterSpecialtyLists ON #ClusterSpecialtyLists (OdsCustomerId,ProviderClusterId);

/* Step5: Update Clusterwise Specialtyies */
UPDATE t1 SET 
		t1.ClusterSpecialty = t2.ClusterSpecialty
FROM  dbo.ProviderDataExplorerProvider t1 
INNER JOIN #ClusterSpecialtyLists t2  ON  t1.ProviderClusterId = t2.ProviderClusterId 
			AND t1.OdsCustomerId = t2.OdsCustomerId ;
	
	'

IF(@Debug = 1)
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






