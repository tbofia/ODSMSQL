IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderAnalyticsRptLoadBillHeader') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderAnalyticsRptLoadBillHeader
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerRptLoadBillHeader') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerRptLoadBillHeader
GO

CREATE PROCEDURE dbo.ProviderDataExplorerRptLoadBillHeader(
@SourceDatabaseName VARCHAR(50),
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
		@RunFromOdsPostingGroupAuditId INT;

-- Get OdsPostingGroupAuditId from ETLAudit table for Incremental Load
SET @RunFromOdsPostingGroupAuditId = dbo.GetMaxRunFromOdsPostingGroupAuditId(@ProcessName,@AuditFor,@ReportId);

SET @SqlScript = CASE WHEN @IsIncrementalLoad = 1 THEN
--Incremental Load
-- Update all the records coming from staging and insert the new records to destination
'
UPDATE d
	SET		d.DateSaved = s.DateSaved,
			d.ClaimDateLoss = s.ClaimDateLoss,
			d.CVType = s.CVType,
			d.Flags = s.Flags,
			d.CreateDate = s.CreateDate,
			d.ProviderZipofService = s.PvdZOS,
			d.TypeofBill = s.TypeofBill,
			d.LastChangedOn = s.LastChangedOn,
			d.CVTypeDescription = s.CVTypeDescription,
			d.RunDate = GETDATE()
    FROM dbo.ProviderDataExplorerBillHeader d 
    INNER JOIN stg.ProviderDataExplorerBillHeader s ON s.BillIdNo = d.BillId
										  AND s.OdsCustomerId = d.OdsCustomerId
										  

INSERT INTO dbo.ProviderDataExplorerBillHeader
		(
			OdsPostingGroupAuditId,		
			OdsCustomerId,
			BillId,
			ClaimantHeaderId,
			DateSaved,
			ClaimDateLoss,
			CVType,
			Flags,
			CreateDate,
			ProviderZipofService,
			TypeofBill,
			LastChangedOn,
			CVTypeDescription
		)	
SELECT 
			s.OdsPostingGroupAuditId,
			s.OdsCustomerId,
			s.BillIdNo,
			s.ClaimantHdrIdNo,
			s.DateSaved,
			s.ClaimDateLoss,
			s.CVType,
			s.Flags,
			s.CreateDate,
			s.PvdZOS,
			s.TypeofBill,
			s.LastChangedOn,
			s.CVTypeDescription

FROM stg.ProviderDataExplorerBillHeader s 
		LEFT JOIN dbo.ProviderDataExplorerBillHeader d ON d.BillId = s.BillIdNo
															AND d.OdsCustomerId = s.OdsCustomerId
																														
		WHERE d.BillId IS NULL AND d.OdsCustomerId IS NULL
'
ELSE
--Full Load
--Insert all the records coming from staging
'
INSERT INTO dbo.ProviderDataExplorerBillHeader
	(
			OdsPostingGroupAuditId,		
			OdsCustomerId,
			BillId,
			ClaimantHeaderId,
			DateSaved,
			ClaimDateLoss,
			CVType,
			Flags,
			CreateDate,
			ProviderZipofService,
			TypeofBill,
			LastChangedOn,
			CVTypeDescription
	)
SELECT 
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
			TypeofBill,
			LastChangedOn,
			CVTypeDescription								
FROM stg.ProviderDataExplorerBillHeader ;
'
END

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


