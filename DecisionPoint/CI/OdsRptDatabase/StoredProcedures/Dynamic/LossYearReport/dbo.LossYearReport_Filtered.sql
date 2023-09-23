IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.LossYearReport_Filtered') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.LossYearReport_Filtered
GO

CREATE PROCEDURE  dbo.LossYearReport_Filtered (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 0)
AS
BEGIN
--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@RunType INT = 0,	@if_Date AS DATETIME = NULL,@ReportType INT = 5,@OdsCustomerId INT = 44;

DECLARE @SQLScript VARCHAR(MAX);

ALTER INDEX ALL ON  stg.LossYearReport_Filtered DISABLE;

SET @SQLScript = CAST ('' AS VARCHAR(MAX)) + '
DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;'+

'
TRUNCATE TABLE stg.LossYearReport_EncounterTypeId;

INSERT INTO stg.LossYearReport_EncounterTypeId
SELECT OdsCustomerId
      ,BillIDNo
      ,MIN(EncounterTypeId) AS EncounterTypeId
      ,GETDATE() AS RunDate
FROM ReportDB.stg.LossYearReport_Input
'
+CASE WHEN @OdsCustomerId <> 0 THEN 'WHERE OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +
'
GROUP BY OdsCustomerId
      ,BillIDNo;

TRUNCATE TABLE stg.LossYearReport_Filtered;

INSERT INTO stg.LossYearReport_Filtered
SELECT  I.OdsCustomerId,  
		CompanyName,  
		CmtSOJ AS SOJ, 
		AgeGroup as AgeGroup, 
		AnchorDateQuarter as DateQuarter, 
		Form_Type AS FormType,
		CV_Code AS CoverageType,
		E.EncounterTypeId AS EncounterTypePriority,
		ServiceGroup AS ServiceGroup,
		RevenueCodeCategoryId,
		CmtSEX  AS Gender, 
		Outlier_cat, 
		CmtState ClaimantState,
		CmtCounty ClaimantCounty, 
		PvdSPC_List  AS ProviderSpecialty, 
		State AS ProviderState, 
		InjuryNatureId,
		CmtIdNo, 
		DT_SVC,
		Period,
		CASE WHEN (ALLOWED > 0 OR (ALLOWED = 0 AND COALESCE(BE4.EndNote,BOE202.OverrideEndNote,BPE4.EndNote,BPOE202.OverrideEndNote,BE202.EndNote,BOE4.OverrideEndNote,BPE202.EndNote,BPOE4.OverrideEndNote) IS NULL)) THEN 1 ELSE 0 END AS IsAllowedGreaterThanZero,
		Allowed, 
		Charged, 
		Units 

FROM  stg.LossYearReport_Input I
INNER JOIN stg.LossYearReport_EncounterTypeId E
	ON I.OdsCustomerId = E.OdsCustomerId
	AND I.BillIdNo  = E.BillIdNo
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'BILLS_Endnotes' ELSE 'if_BILLS_Endnotes(@RunPostingGroupAuditId)' END + ' BE4
	ON I.OdsCustomerId = BE4.OdsCustomerId
	AND I.BillIdNo = BE4.BillIdNo
	AND I.Line_No = BE4.Line_No
	AND BE4.EndNote = 4
	AND I.LineType = 1
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'BILLS_Endnotes' ELSE 'if_BILLS_Endnotes(@RunPostingGroupAuditId)' END + ' BE202
	ON I.OdsCustomerId = BE202.OdsCustomerId
	AND I.BillIdNo = BE202.BillIdNo
	AND I.Line_No = BE202.Line_No
	AND BE202.EndNote = 202
	AND I.LineType = 1
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'Bills_OverrideEndNotes' ELSE 'if_Bills_OverrideEndNotes(@RunPostingGroupAuditId)' END + ' BOE202
	ON I.OdsCustomerId = BOE202.OdsCustomerId
	AND I.BillIdNo = BOE202.BillIdNo
	AND I.Line_No = BOE202.Line_No
	AND BOE202.OverrideEndNote = 202
	AND I.LineType = 1
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'Bills_OverrideEndNotes' ELSE 'if_Bills_OverrideEndNotes(@RunPostingGroupAuditId)' END + ' BOE4
	ON I.OdsCustomerId = BOE4.OdsCustomerId
	AND I.BillIdNo = BOE4.BillIdNo
	AND I.Line_No = BOE4.Line_No
	AND BOE4.OverrideEndNote = 4
	AND I.LineType = 1
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'Bills_Pharm_Endnotes' ELSE 'if_Bills_Pharm_Endnotes(@RunPostingGroupAuditId)' END + ' BPE4
	ON I.OdsCustomerId = BPE4.OdsCustomerId
	AND I.BillIdNo = BPE4.BillIdNo
	AND I.Line_No = BPE4.Line_No
	AND BPE4.EndNote = 4
	AND I.LineType = 2
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'Bills_Pharm_Endnotes' ELSE 'if_Bills_Pharm_Endnotes(@RunPostingGroupAuditId)' END + ' BPE202
	ON I.OdsCustomerId = BPE202.OdsCustomerId
	AND I.BillIdNo = BPE202.BillIdNo
	AND I.Line_No = BPE202.Line_No
	AND BPE202.EndNote = 4
	AND I.LineType = 2
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'Bills_Pharm_OverrideEndNotes' ELSE 'if_Bills_Pharm_OverrideEndNotes(@RunPostingGroupAuditId)' END + ' BPOE202
	ON I.OdsCustomerId = BPOE202.OdsCustomerId
	AND I.BillIdNo = BPOE202.BillIdNo
	AND I.Line_No = BPOE202.Line_No
	AND BPOE202.OverrideEndNote = 202
	AND I.LineType = 2
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'Bills_Pharm_OverrideEndNotes' ELSE 'if_Bills_Pharm_OverrideEndNotes(@RunPostingGroupAuditId)' END + ' BPOE4
	ON I.OdsCustomerId = BPOE4.OdsCustomerId
	AND I.BillIdNo = BPOE4.BillIdNo
	AND I.Line_No = BPOE4.Line_No
	AND BPOE4.OverrideEndNote = 4
	AND I.LineType = 2
WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN 'I.OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3)) + ' AND ' ELSE '' END +' Outlier = 0;

'

EXEC (@SQLScript);

ALTER INDEX ALL ON  stg.LossYearReport_Filtered REBUILD;

END

GO


