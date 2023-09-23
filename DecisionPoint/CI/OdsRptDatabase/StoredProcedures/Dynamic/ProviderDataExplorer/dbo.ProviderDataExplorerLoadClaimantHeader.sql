IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderAnalyticsLoadClaimantHeader') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderAnalyticsLoadClaimantHeader
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerLoadClaimantHeader') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerLoadClaimantHeader
GO

CREATE PROCEDURE dbo.ProviderDataExplorerLoadClaimantHeader(
@SourceDatabaseName VARCHAR(50),
@StartDate AS DATETIME,
@EndDate AS DATETIME,
@SnapshotAsOf AS DATETIME,
@IsIncrementalLoad INT,
@Debug BIT,
@ReportId INT,
@OdsCustomerId INT)
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
	+ CHAR(13)+CHAR(10)+CHAR(9) + 'ch.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))
	+ CHAR(13)+CHAR(10)+CHAR(9) + CASE WHEN @IsIncrementalLoad = 1 THEN ' AND ch.OdsPostingGroupAuditId > '+CAST(@RunFromOdsPostingGroupAuditId AS VARCHAR(50)) ELSE '' END

SET @SQLScript=
CASE
	WHEN @IsIncrementalLoad = 0 THEN
	-- Full load
	-- Step1: Load the InScope data to stg table (Index on dateloss)
	-- Step2: Insert data joining the Inscope table
'
	IF OBJECT_ID(''stg.ProviderDataExplorerClaimsInScope'',''U'') IS NOT NULL					
	DROP TABLE stg.ProviderDataExplorerClaimsInScope;				
	
	CREATE TABLE stg.ProviderDataExplorerClaimsInScope
	(
	OdscustomerId INT NOT NULL,				
	ClaimIdNo INT NOT NULL,
	DateLoss DATETIME

	CONSTRAINT PK_ProviderDataExplorerClaimsInScope PRIMARY KEY
			(						
				OdsCustomerId,
				ClaimIdNo
			)
		
	);

	INSERT INTO stg.ProviderDataExplorerClaimsInScope
	SELECT	OdscustomerId,				
			ClaimIdNo,
			DateLoss
	FROM '+ @SourceDatabaseName + '.dbo.Claims 
	WHERE OdsCustomerId = '+ CAST(@OdsCustomerId AS VARCHAR(3)) + ' 
	AND DateLoss >= '''+CONVERT(VARCHAR(10),@StartDate,112)+'''

	'
	ELSE ''
END
-- Incremental Load
-- load data with latest OdsPostingGroupAuditId
+ CHAR(13)+CHAR(10)+CHAR(9)
+' 
	TRUNCATE TABLE stg.ProviderDataExplorerClaimantHeader;
	
	INSERT INTO stg.ProviderDataExplorerClaimantHeader(
				OdsPostingGroupAuditId,
				OdsCustomerId,
				ClaimIdNo,
				ClaimNo,
				DateLoss,
				CVCode,
				LossState,
				ClaimantIdNo,
				ClaimantState,
				ClaimantZip,
				ClaimantStateOfJurisdiction,
				CoverageType,
				ClaimantHdrIdNo,
				ProviderIdNo,
				CreateDate,
				LastChangedOn,
				CustomerName,
				CVCodeDesciption,
				CoverageTypeDescription	
				
	)
	SELECT 		
				c.OdsPostingGroupAuditId,
				c.OdsCustomerId,
				c.ClaimIDNo,
				c.ClaimNo,
				c.DateLoss,
				c.CV_Code,
				c.LossState,
				cmt.CmtIDNo,
				cmt.CmtState,
				SUBSTRING(cmt.CmtZip,1,5),
				cmt.CmtStateOfJurisdiction,
				cmt.CoverageType,
				ch.CMT_HDR_IDNo,
				ch.PvdIDNo,
				c.CreateDate,
				c.LastChangedOn,
				cus.CustomerName,
				cvt.LongName,
				cvtc.LongName
			
	FROM '+@SourceDatabaseName+'.dbo.Claims c '
	+ CHAR(13)+CHAR(10)+CHAR(9) + CASE
									WHEN @IsIncrementalLoad = 0 THEN
									'INNER JOIN stg.ProviderDataExplorerClaimsInScope cis ON c.OdsCustomerId = cis.OdsCustomerId
																										AND c.ClaimIdNo=cis.ClaimIdNo'
								  ELSE ''
								  END
	+ CHAR(13)+CHAR(10)+CHAR(9)
	+'INNER JOIN '+@SourceDatabaseName+'.dbo.Claimant cmt ON c.ClaimIDNo = cmt.ClaimIDNo 
												AND c.OdsCustomerId = cmt.OdsCustomerId 												
	INNER JOIN '+@SourceDatabaseName+'.dbo.CMT_HDR ch ON ch.CmtIDNo = cmt.CmtIDNo 
												AND cmt.OdsCustomerId = ch.OdsCustomerId 												
	INNER JOIN '+@SourceDatabaseName+'.adm.Customer cus ON cus.CustomerId = ch.OdsCustomerId
	LEFT JOIN '+@SourceDatabaseName+'.dbo.CoverageType cvt ON c.OdsCustomerId=cvt.OdsCustomerId 
												AND c.CV_Code=cvt.ShortName
	LEFT JOIN '+@SourceDatabaseName+'.dbo.CoverageType cvtc ON c.OdsCustomerId=cvtc.OdsCustomerId 
												AND cmt.CoverageType=cvtc.ShortName																	
		
'+ @WhereClause			

IF (@Debug = 1)
BEGIN
	PRINT @AuditFor;
	PRINT @OdsPostingGroupAuditId;
	PRINT @ProcessName;
	PRINT @RunFromOdsPostingGroupAuditId;
	PRINT(@SQLScript)
END

EXEC(@SQLScript);

-- Tracking Process end in ETL Audit
EXEC dbo.ProviderDataExplorerEtlAuditEnd @AuditFor,@ProcessName,@OdsPostingGroupAuditId,@ReportId;

END



GO


