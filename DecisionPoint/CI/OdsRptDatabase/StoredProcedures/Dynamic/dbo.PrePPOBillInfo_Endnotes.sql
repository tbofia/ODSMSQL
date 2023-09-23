IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.PrePPOBillInfo_Endnotes') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PrePPOBillInfo_Endnotes
GO

CREATE PROCEDURE dbo.PrePPOBillInfo_Endnotes (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 0,
@IsIncremental INT = 0,
@TargetDatabaseName VARCHAR(50)='ReportDB')
AS
BEGIN

-- Setup Run parameters
-- DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@TargetDatabaseName VARCHAR(50)='ReportDB',@RunDate AS DATETIME = GETDATE(),@RunType INT = 0,@if_Date AS DATETIME = GETDATE(),@OdsCustomerId INT = 0,@IsIncremental INT = 1;

DECLARE @SQLScript VARCHAR(MAX) = '
DECLARE  @start_dt DATETIME = (SELECT MAX(RunDate) FROM rpt.PrePPOBillInfo_Endnotes '+CASE WHEN @OdsCustomerId = 0 THEN '' ELSE 'WHERE OdsCustomerId = '+CAST(@OdsCustomerID as VARCHAR(5)) END+')
		,@RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+'''))
		,@CutOffPostingGroupAuditId INT;
		 
SET @CutOffPostingGroupAuditId = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+',CONVERT(VARCHAR(10),ISNULL(@start_dt,''1900-01-01''),112)));
										
-- Get Latest date bill was sent to PPO
IF OBJECT_ID(''tempdb..#MaxPrePPOBillInfo'') IS NOT NULL DROP TABLE #MaxPrePPOBillInfo
SELECT
	 P.OdsCustomerId
	,P.billIDNo
	,P.line_no
	,P.PharmacyLine
	,MAX(P.PrePPOBillInfoId) AS LatestPrePPOBillInfoId

INTO #MaxPrePPOBillInfo
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'PrePPOBillInfo' ELSE 'if_PrePPOBillInfo(@RunPostingGroupAuditId)' END+' P'+
CASE WHEN @IsIncremental = 1 THEN '
INNER JOIN (SELECT DISTINCT  OdsCustomerId
							,billIDNo
							,line_no
							,PharmacyLine
			FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'PrePPOBillInfo' ELSE 'if_PrePPOBillInfo(@RunPostingGroupAuditId)' END+'
			WHERE OdsPostingGroupAuditId >= ISNULL(@CutOffPostingGroupAuditId,0)
	) AS I
	ON P.OdsCustomerId = I.OdsCustomerId
	AND P.BillIdNo = I.BillIdNo
	AND P.line_no = I.line_no
	AND P.PharmacyLine = I.PharmacyLine'
ELSE '' END +'
WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN 'P.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ' ELSE '' END +'P.BillSnapshot = ''Pre-PPO''
GROUP BY P.OdsCustomerId
	,P.billIDNo
	,P.line_no
	,P.PharmacyLine;

CREATE NONCLUSTERED INDEX Idx_MaxPrePPOBillInfo
ON #MaxPrePPOBillInfo (OdsCustomerId,billIDNo,line_no)
INCLUDE (PharmacyLine);

'+CASE WHEN @IsIncremental = 0 THEN '
TRUNCATE TABLE '+@TargetDatabaseName+'.rpt.PrePPOBillInfo_Endnotes;' 
ELSE '
DELETE P 
FROM '+@TargetDatabaseName+'.rpt.PrePPOBillInfo_Endnotes P
INNER JOIN #MaxPrePPOBillInfo mp
	ON p.OdsCustomerId = mp.OdsCustomerId
	AND p.billIDNo = mp.billIDNo
    AND p.line_no = mp.line_no
    AND p.Linetype = CASE WHEN mp.PharmacyLine = 0 THEN 1 WHEN mp.PharmacyLine = 1 THEN 2 END' END+'	

-- Dump Max PrePPOInfo Data 
IF OBJECT_ID(''tempdb..#PrePPOBillInfo'') IS NOT NULL DROP TABLE #PrePPOBillInfo
SELECT
	 p.OdsCustomerId
	,p.billIDNo
	,p.line_no
	,CASE WHEN p.PharmacyLine = 0 THEN 1 WHEN p.PharmacyLine = 1 THEN 2 END AS Line_type 
	,p.Endnotes
	,p.OVER_RIDE
	,p.ALLOWED
	,p.ANALYZED 
INTO #PrePPOBillInfo
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'PrePPOBillInfo' ELSE 'if_PrePPOBillInfo(@RunPostingGroupAuditId)' END+' p
INNER JOIN #MaxPrePPOBillInfo mp
	ON p.OdsCustomerId = mp.OdsCustomerId
    AND p.PrePPOBillInfoId = mp.LatestPrePPOBillInfoId
	AND p.billIDNo = mp.billIDNo
    AND p.line_no = mp.line_no
    AND p.PharmacyLine = mp.PharmacyLine;

INSERT INTO '+@TargetDatabaseName+'.rpt.PrePPOBillInfo_Endnotes(
	 OdsCustomerId
	,billIDNo
	,line_no
	,linetype
	,Endnotes
	,OVER_RIDE
	,ALLOWED
	,ANALYZED)	
SELECT
	 p.OdsCustomerId
	,p.billIDNo
	,p.line_no
	,p.Line_type 
	,LTRIM(RTRIM(e.StringText)) [Endnotes]
	,p.OVER_RIDE
	,p.ALLOWED
	,p.ANALYZED 
FROM #PrePPOBillInfo p
OUTER APPLY dbo.GetTableFromDelimitedString(p.Endnotes,'','') e 
OPTION (FORCE ORDER);'
 
EXEC(@SQLScript);

END
GO
