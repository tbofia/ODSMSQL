
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderAnalyticsRptLoadProvider') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderAnalyticsRptLoadProvider

GO 

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerRptLoadProvider') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerRptLoadProvider

GO 

CREATE PROCEDURE dbo.ProviderDataExplorerRptLoadProvider(
@SourceDatabaseName VARCHAR(50),
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

-- Tracking Process start in ETL Audit
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
	SET   	
	        d.ProviderTIN = s.ProviderTIN,
			d.ProviderFirstName = s.ProviderFirstName,
			d.ProviderLastName = s.ProviderLastName,
			d.ProviderGroup = s.ProviderGroup,
			d.ProviderState = s.ProviderState,
			d.ProviderZip = s.ProviderZip,
			d.ProviderSPCList = s.ProviderSPCList,
			d.ProviderNPINumber = s.ProviderNPINumber,
			d.CreatedDate = s.CreatedDate,
			d.ProviderName = s.ProviderName,
			d.ProviderTypeId = s.ProviderTypeId,
			d.ProviderClusterId = s.ProviderClusterId,
			d.Specialty	= s.Specialty,
			d.RunDate = GETDATE()
FROM stg.ProviderDataExplorerProvider s
	 INNER JOIN dbo.ProviderDataExplorerProvider d ON s.ProviderIdNo=d.ProviderId 
														AND s.OdsCustomerId = d.OdsCustomerId															
														

INSERT INTO dbo.ProviderDataExplorerProvider(
			OdsPostingGroupAuditId,
			OdsCustomerId,
			ProviderId,
			ProviderTIN,
			ProviderFirstName,
			ProviderLastName,
			ProviderGroup,
			ProviderState,
			ProviderZip,
			ProviderSPCList,
			ProviderNPINumber,
			CreatedDate,
			ProviderName,
			ProviderTypeId,			
			ProviderClusterId,
			Specialty				
	  )

SELECT 
			s.OdsPostingGroupAuditId,
			s.OdsCustomerId,
			s.ProviderIdNo,
			s.ProviderTIN,
			s.ProviderFirstName,
			s.ProviderLastName,
			s.ProviderGroup,
			s.ProviderState,
			s.ProviderZip,
			s.ProviderSPCList,
			s.ProviderNPINumber,
			s.CreatedDate,
			s.ProviderName,
			s.ProviderTypeId,
			s.ProviderClusterId,
			s.Specialty				
	 FROM stg.ProviderDataExplorerProvider s 
	 LEFT JOIN dbo.ProviderDataExplorerProvider d ON s.ProviderIdNo=d.ProviderId 
														AND s.OdsCustomerId = d.OdsCustomerId														
														
     WHERE d.ProviderId IS NULL 
'
ELSE
--Full Load
--Insert all the records coming from staging
'
INSERT INTO dbo.ProviderDataExplorerProvider(
			OdsPostingGroupAuditId,
			OdsCustomerId,
			ProviderId,
			ProviderTIN,
			ProviderFirstName,
			ProviderLastName,
			ProviderGroup,
			ProviderState,
			ProviderZip,
			ProviderSPCList,
			ProviderNPINumber,
			CreatedDate,
			ProviderName,
			ProviderTypeId,
			ProviderClusterId,
			Specialty
			
	)
SELECT 
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
			ProviderName,
			ProviderTypeId,
			ProviderClusterId,
			Specialty				
FROM  stg.ProviderDataExplorerProvider
'
END

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


