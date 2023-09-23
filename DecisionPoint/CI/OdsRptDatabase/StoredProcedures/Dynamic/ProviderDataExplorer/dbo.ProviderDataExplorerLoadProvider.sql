
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderAnalyticsLoadProvider') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderAnalyticsLoadProvider

GO

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerLoadProvider') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerLoadProvider

GO

CREATE PROCEDURE dbo.ProviderDataExplorerLoadProvider(
@SourceDatabaseName VARCHAR(50),
@StartDate AS DATETIME,
@EndDate AS DATETIME,
@SnapshotAsOf AS DATETIME,
@IsIncrementalLoad INT,
@Debug BIT,
@ReportId INT,
@OdsCustomerId INT
)
AS
BEGIN

DECLARE @OdsPostingGroupAuditId INT,
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
SET @RunFromOdsPostingGroupAuditId = dbo.GetMaxRunFromOdsPostingGroupAuditId(@ProcessName,@AuditFor,@ReportId);
									
-- Build Where clause to be used for data fetch from ODS	
SET @WhereClause =
	  CHAR(13)+CHAR(10)+'WHERE '
	+ CHAR(13)+CHAR(10)+CHAR(9) + 'p.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))
	+ CHAR(13)+CHAR(10)+CHAR(9) + CASE WHEN @IsIncrementalLoad = 1 THEN ' AND p.OdsPostingGroupAuditID > '+CAST(@RunFromOdsPostingGroupAuditId AS VARCHAR(50)) ELSE '' END

SET @SQLScript=
CASE WHEN @IsIncrementalLoad = 0 THEN
-- Full load
	-- Step1: (lookup specialty + new york specialty ) specialty tables which goes to providers data
	-- Step2: Insert providers data joining with staging ClaimantHeader table 

' 
IF EXISTS (SELECT Name FROM sys.indexes  WHERE Name=''IDXPACHOdsCustomerIdProviderId'' 
    AND object_id = OBJECT_ID(''stg.ProviderDataExplorerClaimantHeader''))
  BEGIN
    DROP INDEX IDXPACHOdsCustomerIdProviderId ON stg.ProviderDataExplorerClaimantHeader;
  END
CREATE INDEX IDXPACHOdsCustomerIdProviderId ON stg.ProviderDataExplorerClaimantHeader (OdsCustomerId,ProviderIdNo);
'
ELSE '' END+
'
	IF OBJECT_ID(''tempdb..#Specialty'') IS NOT NULL
	      DROP TABLE #Specialty;
	BEGIN
		SELECT OdsPostingGroupAuditId,
				OdsCustomerId,
				ShortName,
				LongName ,
				ROW_NUMBER() OVER(PARTITION BY ShortName,OdsCustomerId ORDER BY OdsCustomerId )AS Cnt  
		INTO #Specialty 
		FROM (
				SELECT 
					OdsPostingGroupAuditId,
					OdsCustomerId,
					ShortName,
					LongName 	 
		FROM '+@SourceDatabaseName+'.dbo.lkp_SPC
		UNION
		SELECT OdsPostingGroupAuditId,
			   OdsCustomerId,
			   RatingCode,
			   Desc_ 
		FROM '+@SourceDatabaseName+'.dbo.ny_specialty ) as t1
	END

	IF EXISTS (SELECT Name FROM tempdb.sys.indexes  WHERE Name = ''IDXPA_Specialty'' 
    AND object_id = OBJECT_ID(''tempdb..#Specialty''))
  BEGIN
    DROP INDEX IDXPA_Specialty ON #Specialty;
  END
CREATE INDEX IDXPA_Specialty ON #Specialty (OdsCustomerId,ShortName,Cnt);

TRUNCATE TABLE stg.ProviderDataExplorerProvider;

INSERT INTO stg.ProviderDataExplorerProvider(
			OdsPostingGroupAuditId,
			OdsCustomerId,
			ProviderIdNo,
			ProviderTIN,
			ProviderFirstName,
			ProviderLastName,
			ProviderGroup,
			ProviderState,
			ProviderZip,
			ProviderSPCList,
			ProviderNPINumber,	
			CreatedDate,
			ProviderTypeID,
			ProviderName,
			ProviderClusterID,
			Specialty		
)
SELECT 					
			p.OdsPostingGroupAuditId,
			p.OdsCustomerId,
			p.PvdIDNo,
			p.PvdTIN,
			p.PvdFirstName,
			p.PvdLastName,			
			p.PvdGroup,
			p.PvdState,
			SUBSTRING(p.PvdZip,1,5),
			p.PvdSPC_List,
			p.PvdNPINo,
			p.CreateDate,
			prs.ProviderType,			
             CASE  WHEN prs.ProviderType = ''G'' THEN
                        CASE
                               WHEN LEN(LTRIM(RTRIM(p.PvdGroup))) > 0 THEN LTRIM(RTRIM(UPPER(p.PvdGroup)))
                               ELSE LTRIM(RTRIM(UPPER(p.PvdFirstName))) + '' '' + LTRIM(RTRIM(UPPER(p.PvdLastName)))
                        END
              ELSE
                      CASE
                                 WHEN LEN(LTRIM(RTRIM(p.PvdFirstName))) > 0 THEN LTRIM(RTRIM(UPPER(p.PvdFirstName))) + '' '' + LTRIM(RTRIM(UPPER(p.PvdLastName)))
                                   ELSE  LTRIM(RTRIM(UPPER(p.PvdGroup)))
                        END
              END,

			prs.ProviderClusterKey,
			l.LongName	

		FROM   '
		+ CHAR(13)+CHAR(10)+CHAR(9) +@SourceDatabaseName+'.dbo.PROVIDER p '
		+ CHAR(13)+CHAR(10)+CHAR(9) + CASE
				WHEN @IsIncrementalLoad = 0 THEN
		'INNER JOIN (SELECT DISTINCT OdsCustomerId,ProviderIdNo FROM stg.ProviderDataExplorerClaimantHeader)  ch ON p.OdsCustomerId = ch.OdsCustomerId 
												AND p.PvdIdNo = ch.ProviderIdNo'
				ELSE ''
				-- Incremental Load
				-- load data with latest OdsPostingGroupAuditId
		   END
		+ CHAR(13)+CHAR(10)+CHAR(9)
		+'LEFT JOIN  '+@SourceDatabaseName+'.dbo.ProviderCluster prs ON p.PvdIDNo = prs.PvdIDNo 
											    AND p.ODSCustomerID = prs.OrgOdsCustomerId												
		 LEFT JOIN #Specialty l ON  p.PvdSPC_List = l.ShortName 
												AND p.OdsCustomerId = l.OdsCustomerId 												
												AND l.Cnt = 1
														
		'+ @WhereClause 		 
		+ CHAR(13)+CHAR(10)+CHAR(9)+
		CASE WHEN @IsIncrementalLoad = 0 THEN
		+' DROP INDEX IDXPACHOdsCustomerIdProviderId ON stg.ProviderDataExplorerClaimantHeader;'
		ELSE '' END
		+ CHAR(13)+CHAR(10)+CHAR(9)
		
		
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

