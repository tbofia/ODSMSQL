IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderAnalyticsUpdateProvider') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderAnalyticsUpdateProvider
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerUpdateProvider') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerUpdateProvider
GO

CREATE PROCEDURE dbo.ProviderDataExplorerUpdateProvider(
@SourceDatabaseName VARCHAR(50),
@SnapshotAsOf AS DATETIME,
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
		@RunFromOdsPostingGroupAuditId INT;

-- Get OdsPostingGroupAuditId from ETLAudit table for Incremental Load
SET @RunFromOdsPostingGroupAuditId = dbo.GetMaxRunFromOdsPostingGroupAuditId(@ProcessName,@AuditFor,@ReportId)

SET @SQLScript=
'		
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

IF OBJECT_ID(''tempdb..#Specialty'') IS NOT NULL
	      DROP TABLE #Specialty;
	BEGIN
		SELECT  OdsCustomerId,
				ShortName,
				LongName ,
				ROW_NUMBER() OVER(PARTITION BY ShortName,OdsCustomerId ORDER BY OdsCustomerId )AS Cnt  
		INTO #Specialty 
		FROM (
				SELECT 
					OdsCustomerId,
					ShortName,
					LongName 	 
		FROM '+@SourceDatabaseName+'.dbo.lkp_SPC 
		UNION
				SELECT 
					OdsCustomerId,
					RatingCode,
					Desc_ 
		FROM '+@SourceDatabaseName+'.dbo.ny_specialty 
		) as t1
	END
	
		/* Step1: Fetch all null records for Specialty field from ProviderDataExplorer.Providers */
         IF OBJECT_ID(''tempdb..#ProviderSPCLists'') IS NOT NULL
                 DROP TABLE #ProviderSPCLists;
    BEGIN
		 SELECT 
				OdsCustomerId ,
				ProviderSPCList,
				Specialty,
				ROW_NUMBER() OVER(ORDER BY ProviderSPCList) AS cnt INTO #ProviderSPCLists 
		 FROM (SELECT DISTINCT OdsCustomerId ,ProviderSPCList,Specialty  
		 FROM stg.ProviderDataExplorerProvider 
		 WHERE LEN(LTRIM(RTRIM(ISNULL(Specialty,''''))))=0 
			   AND OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+'
		 
		 ) AS base
	END

		 /* Step2: Splittig the multiple values to atomic */
		IF OBJECT_ID(''tempdb..#ProviderSPCListsResult'') IS NOT NULL
				 DROP TABLE #ProviderSPCListsResult;
       BEGIN
		SELECT 
			Cnt,
			OdscustomerId,
			ProviderSPCList,
			LTRIM(RTRIM(m.n.value(''.[1]'',''VARCHAR(8000)''))) AS ProviderSPCListCerts
		INTO #ProviderSPCListsResult
		FROM
		(
		SELECT 
			Cnt,
			OdscustomerId,
			ProviderSPCList,
			CAST(''<XMLRoot><RowData>'' + 
			REPLACE(ProviderSPCList,'':'',''</RowData><RowData>'') + ''</RowData></XMLRoot>'' AS XML) AS x
		FROM   #ProviderSPCLists
		)t
		CROSS APPLY x.nodes(''/XMLRoot/RowData'')m(n)
		END

		/* Step3: Join the Provider_SPC_List with ny_specialty on short description  */
		IF OBJECT_ID(''tempdb..#ProviderSPCListsResultnew'') IS NOT NULL
		          DROP TABLE #ProviderSPCListsResultnew;
        BEGIN
		SELECT a.*,
			CASE WHEN ISNULL(b.LongName,'''')='''' THEN  ProviderSPCListCerts	
				ELSE b.LongName END  LongName 
		INTO #ProviderSPCListsResultnew 
		FROM #ProviderSPCListsResult a 
		LEFT JOIN #Specialty b ON a.ProviderSPCListCerts=b.ShortName 
							AND a.OdsCustomerId=b.OdsCustomerId AND b.Cnt = 1
		ORDER BY cnt
		END

		/* Step4: Combine the result for the multiple values and insert them to #Provider_SPC_Lists_Result_new_Specialty */
		IF OBJECT_ID(''tempdb..#ProviderSPCListsResultnewSpecialty'') IS NOT NULL
		           DROP TABLE #ProviderSPCListsResultnewSpecialty;
		BEGIN 
		SELECT * INTO #ProviderSPCListsResultnewSpecialty 
		FROM 
		  (SELECT 
				Cnt,
				OdsCustomerId,
				ProviderSPCList, 
				LongName = STUFF(
				         (SELECT '':'' + LongName FROM #ProviderSPCListsResultnew t1 
						 WHERE t1.cnt=t2.cnt  FOR XML PATH ('''')), 1, 1, ''''
				       )
		FROM #ProviderSPCListsResultnew t2 
		GROUP BY 
				Cnt,
				OdsCustomerId,
				ProviderSPCList
		
		)AS t1
		END

		/* Step5: Update Specialty long description and still having nulls then replace them with short description */
		UPDATE t1 
		SET Specialty = CASE WHEN LEN(LTRIM(RTRIM(t2.LongName))) <= 1 THEN t2.ProviderSPCList 
						ELSE CASE WHEN CHARINDEX('':'',t2.LongName ) = 1  THEN STUFF(t2.LongName,1,1,'''') ELSE t2.LongName END END
		FROM  stg.ProviderDataExplorerProvider t1 
		INNER JOIN #ProviderSPCListsResultnewSpecialty t2  ON  t1.ProviderSPCList=t2.ProviderSPCList 
															AND t1.ODSCustomerID=t2.ODSCustomerID		
		
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

