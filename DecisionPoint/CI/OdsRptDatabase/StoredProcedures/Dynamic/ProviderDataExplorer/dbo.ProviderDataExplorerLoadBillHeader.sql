IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderAnalyticsLoadBillHeader') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderAnalyticsLoadBillHeader
GO 

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerLoadBillHeader') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerLoadBillHeader
GO 

CREATE PROCEDURE dbo.ProviderDataExplorerLoadBillHeader(
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
SET @RunFromOdsPostingGroupAuditId = dbo.GetMaxRunFromOdsPostingGroupAuditId(@ProcessName,@AuditFor,@ReportId)

-- Build Where clause to be used for data fetch from ODS	
SET @WhereClause =
	  CHAR(13)+CHAR(10)+'WHERE '
	+ CHAR(13)+CHAR(10)+CHAR(9) + 'bh.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))
	+ CHAR(13)+CHAR(10)+CHAR(9) + CASE WHEN @IsIncrementalLoad = 1 THEN ' AND bh.OdsPostingGroupAuditID > '+CAST(@RunFromOdsPostingGroupAuditId AS VARCHAR(50)) ELSE '' END

SET @SQLScript=
CASE WHEN @IsIncrementalLoad = 0 THEN
' 
IF EXISTS (SELECT Name FROM sys.indexes  WHERE Name=''IDXPACHOdsCustomerIdCHId'' 
    AND object_id = OBJECT_ID(''stg.ProviderDataExplorerClaimantHeader''))
  BEGIN
    DROP INDEX IDXPACHOdsCustomerIdCHId ON stg.ProviderDataExplorerClaimantHeader;
  END
  CREATE INDEX IDXPACHOdsCustomerIdCHId ON stg.ProviderDataExplorerClaimantHeader (OdsCustomerId,ClaimantHdrIdNo);
  '
ELSE '' END+
'
TRUNCATE TABLE stg.ProviderDataExplorerBillHeader;
INSERT INTO stg.ProviderDataExplorerBillHeader(
			OdsPostingGroupAuditId,
			OdsCustomerId,
			BillIdNo,
			ClaimantHdrIdNo,
			DateSaved,
			ClaimDateLoss,
			CVType,
			Flags,
			CreateDate,
			PvdZOS,
			TypeOfBill,
			LastChangedOn,
			CVTypeDescription
			
)
SELECT 		
			bh.OdsPostingGroupAuditId,
			bh.OdsCustomerId,
			bh.BillIdNo,
			bh.CMT_HDR_IdNo,
			bh.DateSaved,
			bh.ClaimDateLoss,
			bh.CV_Type,
			bh.Flags,
			bh.CreateDate,
			SUBSTRING(bh.PvdZOS,1,5),
			bh.TypeOfBill,
			bh.LastChangedOn,
			cvt.LongName
			
		FROM '
		+ CHAR(13)+CHAR(10)+CHAR(9)+@SourceDatabaseName+'.dbo.BILL_HDR bh '
		+ CHAR(13)+CHAR(10)+CHAR(9) + CASE
				WHEN @IsIncrementalLoad = 0 THEN
				-- Full load
				-- load data joining the staging ClaimantHeader table
		'INNER JOIN stg.ProviderDataExplorerClaimantHeader ch ON bh.OdsCustomerId = ch.OdsCustomerId
												AND bh.CMT_HDR_IdNo=ch.ClaimantHdrIdNo'
				ELSE ''
				-- Incremental Load
				-- load data with latest OdsPostingGroupAuditId
		   END
		+ CHAR(13)+CHAR(10)+CHAR(9) +
		' LEFT JOIN '+@SourceDatabaseName+'.dbo.CoverageType cvt ON bh.OdsCustomerId=cvt.OdsCustomerId 
											AND bh.CV_Type=cvt.ShortName
														
		'+ @WhereClause 
		+ CHAR(13)+CHAR(10)+CHAR(9)+
		CASE WHEN @IsIncrementalLoad = 0 THEN
' DROP INDEX IDXPACHOdsCustomerIdCHId ON stg.ProviderDataExplorerClaimantHeader;'
ELSE '' END				

IF(@Debug  = 1)
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





