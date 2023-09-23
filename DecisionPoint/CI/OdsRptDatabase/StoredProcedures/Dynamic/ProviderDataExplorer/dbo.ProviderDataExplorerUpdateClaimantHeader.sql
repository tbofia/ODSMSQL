IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderAnalyticsUpdateClaimantHeader') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderAnalyticsUpdateClaimantHeader
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerUpdateClaimantHeader') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerUpdateClaimantHeader
GO

CREATE PROCEDURE dbo.ProviderDataExplorerUpdateClaimantHeader(
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

-- Build Where clause for ClaimantDiagnosis
SET @WhereClause =
	  CHAR(13)+CHAR(10)+'WHERE '
	+ CHAR(13)+CHAR(10)+CHAR(9) + ' ch.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))
	+ CHAR(13)+CHAR(10)+CHAR(9) + CASE WHEN @IsIncrementalLoad = 1 THEN ' AND ch.OdsPostingGroupAuditID > '+CAST(@RunFromOdsPostingGroupAuditId AS VARCHAR(50)) ELSE '' END	
	+ CHAR(13)+CHAR(10)+CHAR(9)

SET @SQLScript = CAST('' as VARCHAR(MAX)) +
' 
IF OBJECT_ID(''tempdb..#ClaimantDiagnosis'') IS NOT NULL 
		DROP TABLE #ClaimantDiagnosis;
BEGIN
SELECT ch.ODSCustomerID, 	 
	   ch.ClaimantHdrIdNo AS ClaimantHeaderID, 
	   bh.BillIdNo AS BillID,	    
	   dx.IcdVersion AS ICDVersion, 	   
	   icd.Duration AS RecoveryDuration, 
	   icd.Description AS ICDDescription,	   
	   icd.DiagnosisSeverityId AS DiagnosisSeverityID, 
	   icd.InjuryNatureId AS InjuryNatureID, 
	   it.InjuryNaturePriority AS InjuryNaturePriority, 
	   it.Description AS InjuryDescription 
	   --, it.NarrativeInformation AS NarrativeInformation
	   -- ch.OdsPostingGroupAuditId, 
	   --dx.dx AS DiagnosisCode, 
	   --dx.SeqNum AS SequenceNumber,
	   --icd.DiagnosisFamilyId AS DiagnosisFamilyID, 
	   --icd.StartDate AS ICDStartDate, 
	   --icd.EndDate AS ICDEndDate, 
	   --icd.Traumatic, 
INTO #ClaimantDiagnosis

FROM stg.ProviderDataExplorerClaimantHeader ch  
INNER JOIN stg.ProviderDataExplorerBillHeader bh ON ch.OdsCustomerId = bh.OdsCustomerId
													AND ch.ClaimantHdrIdNo = bh.ClaimantHdrIdNo
INNER JOIN '+@SourceDatabaseName+'.dbo.cmt_dx dx ON bh.OdsCustomerId = dx.odscustomerid
													AND bh.billidno = dx.billidno
INNER JOIN '+@SourceDatabaseName+'.dbo.icddiagnosiscodedictionary icd ON dx.dx = icd.diagnosiscode
													AND dx.icdversion = icd.icdversion
													AND dx.OdsCustomerId = icd.OdsCustomerId												
INNER JOIN '+@SourceDatabaseName+'.dbo.injurynature it ON icd.OdsCustomerId = it.OdsCustomerId													
													AND icd.injurynatureid = it.injurynatureid'
													
							+@WhereClause+	' 
END

IF EXISTS (SELECT Name FROM tempdb.sys.indexes  WHERE Name = ''IX_ClaimantDiagnosis'' 
    AND object_id = OBJECT_ID(''tempdb..#ClaimantDiagnosis''))
  BEGIN
    DROP INDEX IX_ClaimantDiagnosis ON #ClaimantDiagnosis;
  END
CREATE INDEX IX_ClaimantDiagnosis ON #ClaimantDiagnosis(ClaimantHeaderID,BillID);


-- Maximum Recovery Duration with minimum Injury Nature Priority
WITH 
MaxRecoveryDuration AS (
							SELECT ch.ClaimantIdNo,
									MAX(cd.RecoveryDuration) MaxRecoveryDuration
							FROM stg.ProviderDataExplorerClaimantHeader ch 
							INNER JOIN #ClaimantDiagnosis cd ON cd.ClaimantHeaderID = ch.ClaimantHdrIdNo															
																AND cd.OdsCustomerId = ch.OdsCustomerId															
							GROUP BY ch.ClaimantIdNo
						    ),

MinInjuryPriority AS (
							SELECT ch.ClaimantIdNo,
								   mrd.MaxRecoveryDuration,
								   MIN(cd.InjuryNaturePriority) MinInjuryNaturePriority
							FROM stg.ProviderDataExplorerClaimantHeader ch 
							INNER JOIN #ClaimantDiagnosis cd ON cd.ClaimantHeaderID = ch.ClaimantHdrIdNo
																AND cd.OdsCustomerId = ch.OdsCustomerId															
							INNER JOIN MaxRecoveryDuration mrd ON ch.ClaimantIdNo = mrd.ClaimantIdNo
																AND cd.RecoveryDuration = mrd.MaxRecoveryDuration
                            GROUP BY ch.ClaimantIdNo,
								     mrd.MaxRecoveryDuration
						 ),

InjuryDetailsForClaimant AS (
							SELECT DISTINCT ch.ClaimantIdNo,
								   cd.InjuryDescription,
								   cd.InjuryNatureID,
								   cd.InjuryNaturePriority,
								   cd.RecoveryDuration * 7 AS MaxRecoveryDurationDays

							FROM #ClaimantDiagnosis cd 
							INNER JOIN stg.ProviderDataExplorerClaimantHeader ch ON cd.ClaimantHeaderID = ch.ClaimantHdrIdNo
															AND cd.OdsCustomerId = ch.OdsCustomerId																					
							INNER JOIN MinInjuryPriority minip ON ch.ClaimantIdNo = minip.ClaimantIdNo
															AND cd.InjuryNaturePriority = minip.MinInjuryNaturePriority
															AND cd.RecoveryDuration = minip.MaxRecoveryDuration 
								)
-- update calculated fields in Claimant Header 
UPDATE  ch 
SET ch.ExpectedTenureInDays = ic.MaxRecoveryDurationDays,
	ch.ExpectedRecoveryDate = DATEADD(d,ic.MaxRecoveryDurationDays,ch.DateLoss),
	ch.InjuryDescription = ic.InjuryDescription,
	ch.InjuryNatureId = ic.InjuryNatureID,
	ch.InjuryNaturePriority = ic.InjuryNaturePriority
FROM stg.ProviderDataExplorerClaimantHeader ch 
INNER JOIN InjuryDetailsForClaimant ic ON ic.ClaimantIdNo = ch.ClaimantIdNo  ;


IF OBJECT_ID(''tempdb..#BillInjuryDescription'') IS NOT NULL 
		DROP TABLE #BillInjuryDescription;

/* Calculate Max_Recovery_Duration with minimum Injury_Nature_Priority from bill level */
;WITH MaxRecoveryDuration
     AS (SELECT cd.BillId, 
				MAX(cd.RecoveryDuration) MaxRecoveryDuration
         FROM #ClaimantDiagnosis cd  
		 INNER JOIN stg.ProviderDataExplorerBillHeader Bl ON cd.BillId = Bl.BillIdNo 
												AND cd.ClaimantHeaderID = Bl.ClaimantHdrIdNo 		 
												AND cd.OdsCustomerId = Bl.OdsCustomerId
												
		 GROUP BY cd.BillId
		 ),
		MinInjuryNaturePriority 
		AS (SELECT cd.BillId, 
					mrd.MaxRecoveryDuration, 
					MIN(cd.InjuryNaturePriority) MinInjuryNaturePriority
         FROM #ClaimantDiagnosis cd 
		 INNER JOIN stg.ProviderDataExplorerBillHeader Bl ON cd.BillId = Bl.BillIdNo 
												AND cd.ClaimantHeaderID = Bl.ClaimantHdrIdNo 		 
												AND cd.OdsCustomerId = Bl.OdsCustomerId
												
		 INNER JOIN MaxRecoveryDuration mrd ON Bl.BillIdNo = mrd.BillId
												AND cd.RecoveryDuration = mrd.MaxRecoveryDuration
         GROUP BY cd.BillId, 				
                  mrd.MaxRecoveryDuration
		 )

     SELECT  DISTINCT 
            mrdp.BillId, 
            cd.InjuryDescription
            --,cd.InjuryNatureID, 
            --cd.InjuryNaturePriority, 
            --cd.RecoveryDuration * 7 MaxRecoveryDurationDays
     INTO #BillInjuryDescription
     FROM #ClaimantDiagnosis cd 
		 INNER JOIN stg.ProviderDataExplorerBillHeader Bl ON cd.BillId = Bl.BillIdNo 
												AND cd.ClaimantHeaderID = Bl.ClaimantHdrIdNo 		 
												AND cd.OdsCustomerId = Bl.OdsCustomerId												
		 INNER JOIN MinInjuryNaturePriority mrdp ON Bl.BillIdNo = mrdp.BillId
											    AND cd.RecoveryDuration = mrdp.MaxRecoveryDuration
											    AND cd.InjuryNaturePriority = mrdp.MinInjuryNaturePriority;

/* Update BillInjuryDescription from ClaimantDiagnosis calculations */

UPDATE Bl
		SET 
			BillInjuryDescription = erd.InjuryDescription 

FROM stg.ProviderDataExplorerBillHeader bh 	
INNER JOIN stg.ProviderDataExplorerBillLine Bl  ON Bl.BillIdNo = bh.BillIdNo 
											 AND Bl.OdsCustomerId = bh.OdsCustomerId 											
INNER JOIN #BillInjuryDescription erd  ON Bl.BillIdNo = erd.BillId; 


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

