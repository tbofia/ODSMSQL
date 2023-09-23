IF OBJECT_ID('adm.Rpt_GenerateDataExtract') IS NOT NULL
    DROP PROCEDURE adm.Rpt_GenerateDataExtract
GO

CREATE PROCEDURE adm.Rpt_GenerateDataExtract  (
@ProcessId INT  = NULL,
@OutputPath VARCHAR(100) ,
@FileExtension VARCHAR(4) ,
@FileColumnDelimiter VARCHAR(2))
AS
BEGIN
    SET NOCOUNT ON
--  DECLARE @ProcessId INT  = 1,      @OutputPath VARCHAR(100) = '\\MEDPD-DELL20\OdsFileExtracts',      @FileExtension VARCHAR(4) = 'txt' ,      @FileColumnDelimiter VARCHAR(2) = '|'
	DECLARE  @TargetTableName VARCHAR(255)
			,@TargetSchemaName VARCHAR(50)
			,@FileName VARCHAR(MAX)
			,@Timestamp VARCHAR(50);

    SET @TargetTableName  = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId)
	SET @TargetSchemaName  = (SELECT TargetSchemaName FROM adm.Process WHERE ProcessId = @ProcessId)
	SET @Timestamp = CONVERT(VARCHAR(8), GETDATE(), 112) + RIGHT('0' + CAST(DATEPART(hh, GETDATE()) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DATEPART(mi, GETDATE()) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DATEPART(ss, GETDATE()) AS VARCHAR(2)), 2);

	SET @FileName = REPLACE(@@SERVERNAME +'_'+DB_NAME()+'_'+@Timestamp+'_'+@TargetTableName,'\','')

    DECLARE @BcpCommand VARCHAR(8000) , -- xp_cmdshell limitation!
			@TotalRowsAffected INT = 0,
			@SQLScriptSP NVARCHAR(MAX) = '',
			@CoreSiteCode VARCHAR(3);

	IF OBJECT_ID('tempdb..#CommandPromptOutput') IS NOT NULL DROP TABLE #CommandPromptOutput
    CREATE TABLE #CommandPromptOutput(
          CommandPromptOutputId INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED ,
          ResultText VARCHAR(MAX));

	IF OBJECT_ID('tempdb..#ErrorWhiteList') IS NOT NULL DROP TABLE #ErrorWhiteList
    CREATE TABLE #ErrorWhiteList(
          CommandPromptOutputId INT);

		-- Let's add a backslash if we don't have one.
    IF SUBSTRING(REVERSE(@OutputPath), 1, 1) <> '\'
        SET @OutputPath = @OutputPath + '\';

	-- Let's build our bcp command
	SET @BcpCommand = 'bcp '+DB_NAME()+'.'+@TargetSchemaName+'.'+@TargetTableName+' out ' + @OutputPath + @FileName + '.' + @FileExtension + ' -c -w -t "' + @FileColumnDelimiter + '" -S ' + @@SERVERNAME + ' -T';

-- Now, we're going to execute the bcp command via the cmdshell, save the results to #CommandPromptOutput,
-- then look for errors and total row count.
    BEGIN TRY
        INSERT  INTO #CommandPromptOutput
                EXEC master.sys.xp_cmdshell @BcpCommand;

-- MSSQL 2012 is throwing an error when it encounters certain warnings, which is throwing off our error
-- handling below.  Let's remove these if we run into them.
-- First, let's collect the lines that have the warnings we want to suppress
        INSERT  INTO #ErrorWhiteList
                ( CommandPromptOutputId
                )
                SELECT  CommandPromptOutputId
                FROM    #CommandPromptOutput
                WHERE   ResultText LIKE 'Error%Warning: BCP import with a format file will convert empty strings in delimited columns to NULL%'

-- Now remove them from our command prompt output; we have to also remove the previous lines (which contain the error number)
        DELETE  FROM a
        FROM    #CommandPromptOutput a
                INNER JOIN ( SELECT CommandPromptOutputId - 1 AS CommandPromptOutputId -- Previous line (containing error number)
                             FROM   #ErrorWhiteList
                             UNION ALL
                             SELECT CommandPromptOutputId -- Error description
                             FROM   #ErrorWhiteList ) b ON a.CommandPromptOutputId = b.CommandPromptOutputId;

-- Did we run into any issues on the bcp?
        IF EXISTS ( SELECT  1
                    FROM    #CommandPromptOutput
                    WHERE   ResultText LIKE '%Error%' )
            BEGIN
                RAISERROR ('There is a problem with our bcp command!', 16, 1)
            END

        SELECT  @TotalRowsAffected = CAST(ISNULL(SUBSTRING(ResultText, 1, PATINDEX('%rows copied.%', ResultText) - 1), '0') AS INT)
        FROM    #CommandPromptOutput
        WHERE   ResultText LIKE '%rows copied.%';

        SELECT  @TotalRowsAffected AS TotalRowsAffected;


    END TRY

    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION

        DECLARE @ErrMsg NVARCHAR(4000) ,
            @ErrSeverity INT

        SELECT  @ErrMsg = ERROR_MESSAGE() ,
                @ErrSeverity = ERROR_SEVERITY()

        SELECT  @ErrMsg += '; ' + ResultText
        FROM    #CommandPromptOutput
        WHERE   ResultText LIKE '%Error%'
        ORDER BY CommandPromptOutputId;

        RAISERROR (@ErrMsg, @ErrSeverity, 1) WITH LOG

        RETURN
    END CATCH

END
GO

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
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.AdjustorWorkspaceDemandPackage') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.AdjustorWorkspaceDemandPackage
GO

CREATE PROCEDURE dbo.AdjustorWorkspaceDemandPackage(
@SourceDatabaseName Varchar(250) = 'AcsOds',
@if_Date AS DATETIME = NULL,
@RunType INT = 0, 
@OdsCustomerId INT,
@TargetDatabaseName VARCHAR(250) = 'ReportDB')
AS
BEGIN

--DECLARE @SourceDatabaseName VARCHAR(250) = 'AcsOds'; DECLARE @CustomerID INT = 0; DECLARE @if_Date DateTime = NULL; DECLARE @RunType INT = 0;

DECLARE @SQLScript VARCHAR(MAX)
SET @SQLScript = CAST('' AS VARCHAR(MAX)) +
'
DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;

'+CASE WHEN @OdsCustomerID <> 0 THEN 
'DELETE FROM '+@TargetDatabaseName+'.dbo.AdjustorWorkspaceDemandPackage_Output
WHERE OdsCustomerId = '+CAST(@OdsCustomerID as VARCHAR(5))+';' ELSE 

'TRUNCATE TABLE '+@TargetDatabaseName+'.dbo.AdjustorWorkspaceDemandPackage_Output;' END+'

INSERT INTO '+@TargetDatabaseName+'.dbo.AdjustorWorkspaceDemandPackage_Output
SELECT 
    DCMNT.OdsCustomerId, 
    CUST.CustomerName, 
	ISNULL(CPNY.CompanyName, ''UNKNOWN'') Company,
	ISNULL(OFC.OfcName, ''UNKNOWN'') Office,
	CMNT.CmtStateOfJurisdiction SOJ,
	DP.RequestedByUserName,
	CAST(DateTimeReceived AS DATE) DateTimeReceived,
	DCMNT.DemandClaimantId,
	DP.DemandPackageId,
	DP.PageCount,
	SUM(ISNULL(DPF.Size, 0)) Size,
	SUM(CASE WHEN DPF.DemandPackageUploadedFileId IS NULL THEN 0 ELSE 1 END) AS FileCount, 
	Getdate() AS RunDate
FROM ' +@SourceDatabaseName+'.aw.'+CASE WHEN @RunType = 0 THEN 'DemandClaimant' ELSE 'if_DemandClaimant(@RunPostingGroupAuditId)' END + ' DCMNT
INNER JOIN ' +@SourceDatabaseName+'.adm.Customer CUST 
    ON CUST.CustomerId = DCMNT.OdsCustomerId
INNER JOIN ' +@SourceDatabaseName+'.aw.'+CASE WHEN @RunType = 0 THEN 'DemandPackage' ELSE 'if_DemandPackage(@RunPostingGroupAuditId)' END + ' DP 
    ON DCMNT.OdsCustomerId = DP.OdsCustomerId AND DCMNT.DemandClaimantId = DP.DemandClaimantId
INNER JOIN ' +@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CLAIMANT' ELSE 'if_CLAIMANT(@RunPostingGroupAuditId)' END + ' CMNT 
    ON DCMNT.OdsCustomerId = CMNT.OdsCustomerId AND DCMNT.ExternalClaimantId = CMNT.CmtIDNo
INNER JOIN ' +@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CLAIMS' ELSE 'if_CLAIMS(@RunPostingGroupAuditId)' END + ' CLM 
    ON CLM.OdsCustomerId = CMNT.OdsCustomerId AND CLM.ClaimIDNo = CMNT.ClaimIDNo
LEFT OUTER JOIN ' +@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'prf_COMPANY' ELSE 'if_prf_COMPANY(@RunPostingGroupAuditId)' END + ' CPNY 
    ON CPNY.OdsCustomerId = CLM.OdsCustomerId AND CPNY.CompanyId = CLM.CompanyId
LEFT OUTER JOIN ' +@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'prf_Office' ELSE 'if_prf_Office(@RunPostingGroupAuditId)' END + ' OFC 
    ON OFC.OdsCustomerId = CLM.OdsCustomerId AND OFC.OfficeId = CLM.OfficeIndex
LEFT OUTER JOIN ' +@SourceDatabaseName+'.aw.'+CASE WHEN @RunType = 0 THEN 'DemandPackageUploadedFile' ELSE 'if_DemandPackageUploadedFile(@RunPostingGroupAuditId)' END + ' DPF 
    ON DP.OdsCustomerId = DPF.OdsCustomerId AND DP.DemandPackageid = DPF.DemandPackageid' 
+ CASE WHEN @OdsCustomerID <> 0 THEN + CHAR(10) +CHAR(13) + 'WHERE DCMNT.OdsCustomerId = ' + CAST(@OdsCustomerID as VARCHAR(5)) ELSE '' END +'
GROUP BY     DCMNT.OdsCustomerId, 
    CUST.CustomerName, 
	ISNULL(CPNY.CompanyName, ''UNKNOWN''),
	ISNULL(OFC.OfcName, ''UNKNOWN''),
	CMNT.CmtStateOfJurisdiction,
	DP.RequestedByUserName,
	CAST(DateTimeReceived AS DATE),
	DCMNT.DemandClaimantId,
	DP.DemandPackageId,
	DP.PageCount;'

EXEC (@SQLScript);

END

GO




IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.AdjustorWorkspaceServiceRequested') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.AdjustorWorkspaceServiceRequested
GO

CREATE PROCEDURE dbo.AdjustorWorkspaceServiceRequested(
@SourceDatabaseName Varchar(250) = 'AcsOds',
@if_Date AS DATETIME = NULL,
@RunType INT = 0, 
@OdsCustomerId INT = 0,
@TargetDatabaseName VARCHAR(250) = 'ReportDB')
AS
BEGIN

--DECLARE @SourceDatabaseName VARCHAR(250) = 'AcsOds'; DECLARE @CustomerId INT = 0; DECLARE @if_Date DateTime = GETDATE(); DECLARE @RunType INT = 0;

DECLARE @SQLScript VARCHAR(MAX)
SET @SQLScript = CAST('' AS VARCHAR(MAX)) +
'
DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerId as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;


DECLARE @LastOdsPostingGroupAuditId DATETIME = (SELECT ISNULL(MAX(OdsPostingGroupAuditId),0) FROM dbo.AdjustorWorkspaceServiceRequested_Output)

-- Get Service Requested
IF OBJECT_ID(''tempdb..#JsonFirstLevel'') IS NOT NULL DROP TABLE #JsonFirstLevel;
SELECT D.OdsCustomerId
	 ,D.OdsPostingGroupAuditId
	 ,D.DemandPackageId
	 ,D.DateTimeReceived
	 ,S.DemandPackageRequestedServiceId
	 ,S.ReviewRequestOptions
	 ,JSON_Value(S.ReviewRequestOptions,''$.Name'') RequestedServiceName
	 ,J.[Value] AS JsonValue
INTO #JsonFirstLevel
FROM ' +@SourceDatabaseName+'.aw.'+CASE WHEN @RunType = 0 THEN 'DemandPackage' ELSE 'if_DemandPackage(@RunPostingGroupAuditId)' END + ' D
INNER JOIN ' +@SourceDatabaseName+'.aw.'+CASE WHEN @RunType = 0 THEN 'DemandPackageRequestedService' ELSE 'if_DemandPackageRequestedService(@RunPostingGroupAuditId)' END + ' S
	ON S.OdsCustomerId = D.OdsCustomerId
	AND S.DemandPackageId = D.DemandPackageId
CROSS APPLY OPENJSON(ReviewRequestOptions,''$.Fields'') J
WHERE ISJSON(ReviewRequestOptions) > 0
	AND D.OdsPostingGroupAuditId > @LastOdsPostingGroupAuditId'
+ CASE WHEN @OdsCustomerId <> 0 THEN + CHAR(10) +CHAR(13) + ' AND S.OdsCustomerId = ' + CAST(@OdsCustomerID as VARCHAR(5)) ELSE '' END +'; 

-- Put Data in intermediate table
IF OBJECT_ID(''tempdb..#AdjustorWorkspaceServiceRequested'') IS NOT NULL DROP TABLE #AdjustorWorkspaceServiceRequested;
SELECT DISTINCT OdsCustomerId
		,DemandPackageId
		,OdsPostingGroupAuditId
		,DateTimeReceived
		,DemandPackageRequestedServiceId
		,RTRIM(LTRIM(RequestedServiceName)) RequestedServiceName
		,NULL AS IsRush
		,NULL AS IsSupplemental
INTO #AdjustorWorkspaceServiceRequested
FROM  #JsonFirstLevel;

--  Parse for Options
;WITH cte_OptionValues AS(
SELECT DISTINCT 
     OdsCustomerId 
	,DemandPackageRequestedServiceId
	,DemandPackageId
	,JSON_Value(JsonValue,''$.Name'') OptionName
	,JSON_Query(JsonValue,''$.Values'') OptionValue

FROM #JsonFirstLevel
WHERE JSON_Value(JsonValue,''$.Id'') IN (''Rush'',''Supplemental''))

-- Update Table with option values
UPDATE F
SET     F.IsRush = CASE WHEN O.OptionValue = ''["True"]'' THEN 1 ELSE 0 END 
	   ,F.IsSupplemental =  CASE WHEN V.OptionValue = ''["True"]'' THEN 1 ELSE 0 END 
	
FROM #AdjustorWorkspaceServiceRequested F
LEFT OUTER JOIN cte_OptionValues O
	ON F.OdsCustomerId = O.OdsCustomerId
	AND F.DemandPackageId  = O.DemandPackageId 
	AND F.DemandPackageRequestedServiceId = O.DemandPackageRequestedServiceId
	AND O.OptionName = ''Rush''
LEFT OUTER JOIN cte_OptionValues V
	ON  F.OdsCustomerId = V.OdsCustomerId
	AND F.DemandPackageId  = V.DemandPackageId 
	AND F.DemandPackageRequestedServiceId = V.DemandPackageRequestedServiceId
	AND V.OptionName = ''Supplemental'';
	
-- Merge With Final data	
MERGE '+@TargetDatabaseName+'.dbo.AdjustorWorkspaceServiceRequested_Output AS T
USING #AdjustorWorkspaceServiceRequested S
ON T.OdsCustomerid = S.OdsCustomerId
AND T.DemandPackageId = S.DemandPackageId
AND T.DemandPackageRequestedServiceId = S.DemandPackageRequestedServiceId
WHEN MATCHED THEN
	UPDATE SET T.OdsPostingGroupAuditId = S.OdsPostingGroupAuditId
      ,T.DateTimeReceived = S.DateTimeReceived
      ,T.DemandPackageRequestedServiceName = S.RequestedServiceName
      ,T.IsRush = S.IsRush
      ,T.IsSupplemental = S.IsSupplemental
WHEN NOT MATCHED BY TARGET THEN
	INSERT (OdsCustomerId
      ,OdsPostingGroupAuditId
      ,DemandPackageId
      ,DateTimeReceived
      ,DemandPackageRequestedServiceId
      ,DemandPackageRequestedServiceName
      ,IsRush
      ,IsSupplemental
      ,RunDate)
	VALUES (S.OdsCustomerId
      ,S.OdsPostingGroupAuditId
      ,S.DemandPackageId
      ,S.DateTimeReceived
      ,S.DemandPackageRequestedServiceId
      ,S.RequestedServiceName
      ,S.IsRush
      ,S.IsSupplemental
      ,GETDATE());'

EXEC (@SQLScript);

END

GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.DP_PerformanceReport_Data') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.DP_PerformanceReport_Data
GO


CREATE PROCEDURE dbo.DP_PerformanceReport_Data (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@StartDate AS DATETIME,
@EndDate AS DATETIME,
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@ReportId INT = 1,
@ReportType INT = 1,
@OdsCustomerId INT = 0)
AS
BEGIN

-- Setup Run parameters
-- DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@StartDate AS DATETIME = '20140901',@EndDate AS DATETIME = '20140930',@RunType INT = 1,@if_Date AS DATETIME = GETDATE(),@ReportId INT = 1,@ReportType INT = 1,@OdsCustomerId INT = 1;

DECLARE  @SQLScript VARCHAR(MAX)
		,@WhereClause VARCHAR(MAX);

-- Build Where clause to be used only when Claimant report or Bill Header Createdate report		
SET @WhereClause = CASE WHEN @ReportType IN(1,3) THEN 
CHAR(13)+CHAR(10)+'WHERE '
	+CASE WHEN @OdsCustomerId <> 0 THEN ' BH.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))ELSE '' END
	+CASE WHEN @ReportType = 1 THEN CASE WHEN @OdsCustomerId <> 0 THEN CHAR(13)+CHAR(10)+CHAR(9)+' AND ' ELSE '' END + ' CONVERT(VARCHAR(10),BH.CreateDate,112) BETWEEN '''+CONVERT(VARCHAR(10),@StartDate,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+'''' ELSE '' END
	+CASE WHEN @OdsCustomerId <> 0 OR @ReportType = 1 THEN CHAR(13)+CHAR(10)+CHAR(9)+' AND ' ELSE '' END +' BH.Flags & 16 = 0;'  ELSE '' END


SET @SQLScript = '
DECLARE  @returnstatus INT
DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;

'+
CASE WHEN @OdsCustomerID <> 0 THEN '
EXEC adm.Rpt_CreateUnpartitionedTableSchema '+CAST(@OdsCustomerId AS VARCHAR(3))+',16,1,@returnstatus;
EXEC adm.Rpt_CreateUnpartitionedTableIndexes '+CAST(@OdsCustomerId AS VARCHAR(3))+',16,@returnstatus;
EXEC adm.Rpt_SwitchUnpartitionedTable '+CAST(@OdsCustomerId AS VARCHAR(3))+',16,'''',1,@returnstatus;

DROP TABLE stg.DP_PerformanceReport_Input_Unpartitioned;' 

ELSE '
TRUNCATE TABLE stg.DP_PerformanceReport_Input;' END+'

--Test: SELECT @start_dt,@end_dt'+
CASE WHEN @ReportType = 2 THEN '

-- Filter Bill History Data
IF OBJECT_ID(''tempdb..#Bill_History'') IS NOT NULL DROP TABLE #Bill_History
SELECT bhs.OdsCustomerId
	,bhs.billIDNo
	,max(bhs.DateCommitted) as DateCommitted 
INTO #Bill_History
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Bill_History' ELSE 'if_Bill_History(@RunPostingGroupAuditId)' END+ ' bhs
WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN ' bhs.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ' ELSE '' END +'CONVERT(VARCHAR(10),bhs.DateCommitted,112) BETWEEN '''+CONVERT(VARCHAR(10),@StartDate,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+'''
GROUP BY bhs.OdsCustomerId
	,bhs.billIDNo; 
'
ELSE '' END+'

--Get Primary Diagnosis Code From CMT_DX table
IF OBJECT_ID(''tempdb..#Diagnosis'') IS NOT NULL DROP TABLE #Diagnosis;  /*Get Diagnosis Code*/
SELECT OdsCustomerId,BillIDNo,DX
INTO #Diagnosis
FROM (
SELECT C.OdsCustomerId
	,C.BillIDNo
	,C.DX
	, ROW_NUMBER() Over (Partition By OdsCustomerId,BillIDNo ORDER By SeqNum asc) Rnk
FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CMT_DX' ELSE 'if_CMT_DX(@RunPostingGroupAuditId)' END + ' C
'+CASE WHEN @OdsCustomerId <> 0 THEN 'WHERE C.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +' 
)X WHERE Rnk = 1;

--Get Provider Data into temp table
IF OBJECT_ID(''tempdb..#Provider'') IS NOT NULL DROP TABLE #Provider; 
SELECT DISTINCT 
	 OdsCustomerId
	,PvdIDNo
	,PvdSPC_List
	,Case WHEN SUBSTRING(PvdSPC_List,0,Charindex('':'',PvdSPC_List)) = ''XX'' THEN ''UNK''
				When PvdSPC_List LIKE ''%:%'' AND (LTRIM(RTRIM(PvdSPC_List)) LIKE ''%Unknown%'' OR LTRIM(RTRIM(PvdSPC_List)) = '''' OR LTRIM(RTRIM(PvdSPC_List)) IS NULL) Then ''UNK''
				When PvdSPC_List LIKE ''%:%'' Then SUBSTRING(PvdSPC_List,0,Charindex('':'',PvdSPC_List))
				When LTRIM(RTRIM(PvdSPC_List)) = '','' OR  LTRIM(RTRIM(PvdSPC_List)) IS NULL OR LTRIM(RTRIM(PvdSPC_List)) = '''' OR LTRIM(RTRIM(PvdSPC_List)) LIKE ''%Unknown%'' OR LTRIM(RTRIM(PvdSPC_List)) =''XX'' THEN ''UNK''
				Else PvdSPC_List End AS ProviderSpecialty
INTO #Provider
FROM '+@SourceDatabaseName+'.dbo.'+ CASE WHEN @RunType = 0 THEN 'PROVIDER' ELSE 'if_PROVIDER(@RunPostingGroupAuditId)' END +
CASE WHEN @OdsCustomerId <> 0 THEN ' WHERE  OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +  
'

CREATE NONCLUSTERED INDEX idx_Pvd ON #Provider(OdsCustomerId,PvdIDNo); 

-- Get Bills of interest
IF OBJECT_ID(''tempdb..#BILL_HDR'') IS NOT NULL DROP TABLE #BILL_HDR
SELECT DISTINCT
	 BH.OdsCustomerId
	,BH.BillIDNo
	,BH.CMT_HDR_IDNo'+CASE WHEN @ReportType = 2 THEN'
	,CONVERT(VARCHAR(8),bhs.DateCommitted,112) AS CreateDateformated
	,bhs.DateCommitted AS CreateDate'ELSE '	
	,CONVERT(VARCHAR(8),BH.CreateDate,112) AS CreateDateformated
	,BH.CreateDate' END +'
	,CASE WHEN BH.Flags & 4096 > 0 THEN ''UB-04''  ELSE ''CMS-1500''  END AS Form_Type
	,ISNULL(d.DX,-1) AS DiagnosisCode
	,BH.TypeOfBill
	,BH.CV_Type
	,LEFT(BH.PvdZOS,5) as ProviderZipOfService
INTO #BILL_HDR
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BILL_HDR' ELSE 'if_BILL_HDR(@RunPostingGroupAuditId)' END+' BH'+CASE WHEN @ReportType = 2 THEN '
INNER JOIN #Bill_History bhs ON BH.OdsCustomerId = bhs.OdsCustomerId 
	AND BH.BillIDNo = bhs.BillIDNo 
	AND BH.Flags & 16 = 0'  ELSE '' END+ '
LEFT OUTER JOIN #Diagnosis d ON BH.OdsCustomerId = d.OdsCustomerId
	AND BH.BillIDNo = d.BillIDNo '
+@WhereClause+'

	
--Add Lines, Claim and Claimant level InfO.
INSERT INTO stg.DP_PerformanceReport_Input(
		 OdsCustomerId
		,BillIDNo
		,CreateDate
		,Form_Type
		,ProviderZipOfService
		,TypeOfBill
		,DiagnosisCode
		,CompanyID
		,Company
		,OfficeID
		,Office
		,Coverage
		,ClaimNo
		,ClaimIDNo
		,CmtIDNO
		,SOJ
		,ProcedureCode
		,ProviderSpecialty
		,ProviderType
		,ProviderType_Desc
		,LINE_NO_DISP
		,LINE_NO
		,REF_LINE_NO
		,Line_Type
		,OVER_RIDE
		,CHARGED
		,ALLOWED
		,PreApportionedAmount
		,ANALYZED
		,UNITS
		,ReportType
)
SELECT   BH.OdsCustomerId
		,BH.BillIDNo
		,'+CASE WHEN @ReportType = 3 THEN 'CL.CreateDate' ELSE 'BH.CreateDate' END+'
		,BH.Form_Type
		,BH.ProviderZipOfService
		,BH.TypeOfBill
		,BH.DiagnosisCode
		,CL.CompanyID
		,ISNULL(CO.CompanyName, ''NA'') AS Company
		,CL.OfficeIndex
		,ISNULL(O.OfcName, ''NA'') AS Office
		'+
		CASE WHEN @ReportType <> 3 THEN ',COALESCE(BH.CV_type,CM.CoverageType,CL.CV_Code,'''')' ELSE ',CL.CV_Code' END+
		',CL.ClaimNo
		,CL.ClaimIDNo
		,CM.CmtIDNo
		,CM.CmtStateOfJurisdiction
		,B.PRC_CD AS ProcedureCode
		,P.ProviderSpecialty
		,ISNULL(SR.ProviderType,''UNK'') ProviderType
		,ISNULL(SR.ProviderType_Desc,''UNKNOWN'')  ProviderType_Desc
		,B.LINE_NO_DISP
		,B.LINE_NO
		,B.REF_LINE_NO
		,B.LineType
		,B.OVER_RIDE
		,B.CHARGED
		,B.ALLOWED
		,B.PreApportionedAmount
		,B.ANALYZED
		,B.UNITS
		,'+CAST(@ReportType AS VARCHAR(1))+'
FROM #BILL_HDR BH
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CMT_HDR' ELSE'if_CMT_HDR(@RunPostingGroupAuditId)' END+' CH 
	ON BH.OdsCustomerId = CH.OdsCustomerId
	AND BH.CMT_HDR_IDNo = CH.CMT_HDR_IDNo
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CLAIMANT' ELSE'if_CLAIMANT(@RunPostingGroupAuditId)' END+' CM 
	ON CH.OdsCustomerId = CM.OdsCustomerId
	AND CH.CmtIDNo = CM.CmtIDNo 
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CLAIMS' ELSE'if_CLAIMS(@RunPostingGroupAuditId)' END+' CL 
	ON  CM.OdsCustomerId = CL.OdsCustomerId
	AND CM.ClaimIDNo  = CL.ClaimIDNo
	AND CL.ClaimNo NOT LIKE ''%TEST%''
	AND(CL.OdsCustomerId NOT IN (70,71) OR CL.Status <> ''C'')'+
	CASE WHEN @ReportType = 3 THEN CHAR(13)+CHAR(10)+CHAR(9)+'AND CONVERT(VARCHAR(10),CL.CreateDate,112) BETWEEN '''+CONVERT(VARCHAR(10),@StartDate,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+'''' ELSE '' END +'
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'prf_COMPANY' ELSE'if_prf_COMPANY(@RunPostingGroupAuditId)' END+' CO 
	ON CO.OdsCustomerId = CL.OdsCustomerId
	AND CO.CompanyID = CL.CompanyID
	AND CO.CompanyName NOT LIKE ''%TEST%''
	AND CO.CompanyName NOT LIKE ''%TRAIN%''	
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'prf_Office' ELSE'if_prf_Office(@RunPostingGroupAuditId)' END+' O 
	ON O.OdsCustomerId = CL.OdsCustomerId
	AND O.OfficeID = CL.OfficeIndex
	AND O.OfcName NOT LIKE ''%TEST%''
	AND O.OfcName NOT LIKE ''%TRAIN%''
INNER JOIN (SELECT
				 OdsCustomerId 
				,BillIDNo
				,LINE_NO_DISP
				,LINE_NO
				,REF_LINE_NO
				,1 AS LineType
				,PRC_CD
				,OVER_RIDE
				,ISNULL(CHARGED, 0) CHARGED
				,ISNULL(ALLOWED, 0) ALLOWED
				,PreApportionedAmount
				,ISNULL(ANALYZED, 0) ANALYZED
				,ISNULL(UNITS, 0) UNITS
			FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BILLS' ELSE'if_BILLS(@RunPostingGroupAuditId)' END+' 
			WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN 'OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ' ELSE '' END +'CHARGED IS NOT NULL
			
			UNION 
			
			SELECT 
				 OdsCustomerId
				,BillIDNo
				,LINE_NO_DISP
				,LINE_NO
				,0
				,2 AS LineType
				,NDC
				,Override
				,ISNULL(CHARGED, 0) CHARGED
				,ISNULL(ALLOWED, 0) ALLOWED
				,PreApportionedAmount
				,ISNULL(ANALYZED, 0) ANALYZED
				,ISNULL(UNITS, 0) UNITS
			FROM  '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BILLS_Pharm' ELSE'if_BILLS_Pharm(@RunPostingGroupAuditId)' END+'
			WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN 'OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ' ELSE '' END +'CHARGED IS NOT NULL
			) AS B
	ON BH.OdsCustomerId = B.OdsCustomerId
	AND BH.BillIDNo = B.BillIDNo
LEFT OUTER JOIN #Provider P
	ON  P.OdsCustomerId = CH.OdsCustomerId
	AND P.PvdIDNo = CH.PvdIDNo 
LEFT OUTER JOIN  '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'ProviderSpecialtyToProvType' ELSE'if_ProviderSpecialtyToProvType(@RunPostingGroupAuditId)' END+' SR
	ON P.ProviderSpecialty = SR.Specialty;'
				
EXEC (@SQLScript);

END 

GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.DP_PerformanceReport_GreenwichData') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.DP_PerformanceReport_GreenwichData
GO


CREATE PROCEDURE dbo.DP_PerformanceReport_GreenwichData (
@SourceDatabaseName VARCHAR(250) = 'AcsOds',
@TargetDatebaseName VARCHAR(250) = 'ReportDB')
AS
BEGIN

DECLARE @SQLQuery VARCHAR(MAX) = '
DELETE FROM  '+@TargetDatebaseName+'.dbo.DP_PerformanceReport_Output
WHERE Customer = ''Greenwich'';

INSERT INTO  '+@TargetDatebaseName+'.dbo.DP_PerformanceReport_Output
SELECT 0 AS OdsCustomerId
	,StartOfMonth
	,''Greenwich'' Customer
	,Year
	,Month
	,''Company1'' Company
	,''Office1'' Office
	,SOJ
	,Coverage
	,Form_Type
	,ClaimIDNo
	,CmtIDNo
	,SUM(Total_Claims)
	,SUM(Total_Claimants)
	,SUM(Total_Bills)
	,SUM(Total_Lines)
	,SUM(Total_Units)
	,SUM(Total_Provider_Charges)
	,SUM(Total_Final_Allowed)
	,SUM(Total_Reductions)
	,SUM(Total_Bill_Review_Reductions)
	,SUM(BillsWithOneOrMoreDuplicateLinesCount)
	,SUM(PartialDuplicateBills)
	,SUM(DuplicateBillsCount)
	,SUM(Dup_Lines_Count)
	,SUM(Duplicate_Reductions)
	,SUM(BenefitsExhausted_Bills_Count)
	,SUM(BenefitsExhausted_Lines_Count)
	,SUM(BenefitsExhausted_Reductions)
	,SUM(Analyst_Reductions)
	,SUM(Fee_Schedule_Reductions)
	,SUM(Benchmark_Reductions)
	,SUM(CTG_Reductions)
	,SUM(VPN_Reductions)
	,SUM(Override_Impact)
	,ReportTypeID
	,GETDATE()
	,GETDATE()
FROM '+@TargetDatebaseName+'.dbo.DP_PerformanceReport_Output
WHERE   Customer IN ( ''FBFS'', ''Sentry'', ''BristolWest'',''OneBeacon'')
GROUP BY StartOfMonth
	,Year  ,Month
	,SOJ
	,Coverage
	,Form_Type
	,ClaimIDNo
	,CmtIDNo
	,ReportTypeID;'

EXEC (@SQLQuery);

END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.DP_PerformanceReport_MaxPrePPOBillInfo') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.DP_PerformanceReport_MaxPrePPOBillInfo
GO

CREATE PROCEDURE dbo.DP_PerformanceReport_MaxPrePPOBillInfo (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 0)
AS
BEGIN

-- Setup Run parameters
-- DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@RunDate AS DATETIME = GETDATE(),@RunType INT = 1,@if_Date AS DATETIME = GETDATE();

TRUNCATE TABLE stg.DP_PerformanceReport_MaxPrePPOBillInfo;

ALTER INDEX ALL ON  stg.DP_PerformanceReport_MaxPrePPOBillInfo DISABLE;

DECLARE @SQLScript VARCHAR(MAX) = '
DECLARE @start_dt DATETIME, @end_dt DATETIME;
DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;
										
-- Get Latest date bill was sent to PPO
IF OBJECT_ID(''tempdb..#MaxPrePPOBillInfo'') IS NOT NULL DROP TABLE #MaxPrePPOBillInfo
SELECT
	 OdsCustomerId
	,billIDNo
	,line_no
	,PharmacyLine
	,MAX(dateSentToPPO) AS dateSentToPPO

INTO #MaxPrePPOBillInfo
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'PrePPOBillInfo' ELSE 'if_PrePPOBillInfo(@RunPostingGroupAuditId)' END+'
WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN 'OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ' ELSE '' END +'BillSnapshot = ''Pre-PPO''
GROUP BY OdsCustomerId
	,billIDNo
	,line_no
	,PharmacyLine;
	
-- Dump Max PrePPOInfo Data 
INSERT INTO stg.DP_PerformanceReport_MaxPrePPOBillInfo(
	 OdsCustomerId
	,billIDNo
	,line_no
	,line_type
	,Endnotes
	,OVER_RIDE
	,ALLOWED
	,ANALYZED)	
SELECT
	 p.OdsCustomerId
	,p.billIDNo
	,p.line_no
	,CASE WHEN p.PharmacyLine = 0 THEN 1 WHEN p.PharmacyLine = 1 THEN 2 END AS Line_type 
	,p.Endnotes
	,p.OVER_RIDE
	,p.ALLOWED
	,p.ANALYZED 

FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'PrePPOBillInfo' ELSE 'if_PrePPOBillInfo(@RunPostingGroupAuditId)' END+' p
INNER JOIN #MaxPrePPOBillInfo mp
	ON p.OdsCustomerId = mp.OdsCustomerId
	AND p.billIDNo = mp.billIDNo
    AND p.line_no = mp.line_no
    AND p.PharmacyLine = mp.PharmacyLine
    AND p.dateSentToPPO = mp.dateSentToPPO
    AND p.BillSnapshot = ''Pre-PPO'';'
 
EXEC(@SQLScript);

-- CreateIndex On MaxPrePPOInfoTable
ALTER INDEX ALL ON  stg.DP_PerformanceReport_MaxPrePPOBillInfo REBUILD;

-- Filter PrePPOData with input data
SET @SQLScript = '
IF OBJECT_ID(''tempdb..#MaxPrePPOBillInfo'') IS NOT NULL DROP TABLE #MaxPrePPOBillInfo
SELECT 
     pb.OdsCustomerId
	,pb.billIDNo
	,pb.line_no
	,pb.line_type
	,pb.Endnotes
	,pb.OVER_RIDE
	,pb.ALLOWED
	,pb.ANALYZED
INTO #MaxPrePPOBillInfo		
FROM  stg.DP_PerformanceReport_Input b
INNER JOIN stg.DP_PerformanceReport_MaxPrePPOBillInfo pb
	ON b.OdsCustomerId = pb.OdsCustomerId
	AND b.billIDNo = pb.billIDNo
	AND b.line_no = pb.line_no
	AND b.line_type = pb.line_type

-- Truncate Table and Drop indexes	
TRUNCATE TABLE stg.DP_PerformanceReport_MaxPrePPOBillInfo;
ALTER INDEX ALL ON  stg.DP_PerformanceReport_MaxPrePPOBillInfo DISABLE;

INSERT INTO stg.DP_PerformanceReport_MaxPrePPOBillInfo(
	 OdsCustomerId
	,billIDNo
	,line_no
	,line_type
	,Endnotes
	,OVER_RIDE
	,ALLOWED
	,ANALYZED)	
SELECT [OdsCustomerId]
      ,[billIDNo]
      ,[line_no]
      ,[line_type]
      ,LTRIM(RTRIM(e.StringText)) [Endnotes]
      ,[OVER_RIDE]
      ,[ALLOWED]
      ,[ANALYZED]

FROM #MaxPrePPOBillInfo pb
OUTER APPLY dbo.GetTableFromDelimitedString(pb.Endnotes,'','') e 
OPTION (FORCE ORDER);'

EXEC(@SQLScript);  

ALTER INDEX ALL ON  stg.DP_PerformanceReport_MaxPrePPOBillInfo REBUILD;

END
GO
  IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.DP_PerformanceReport_BenefitsExhausted') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.DP_PerformanceReport_BenefitsExhausted
GO

CREATE PROCEDURE dbo.DP_PerformanceReport_BenefitsExhausted (
@SourceDatabaseName VARCHAR(50) = 'AcsOds',
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 1)
AS
BEGIN

-- Setup Run parameters
-- DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@RunDate AS DATETIME = GETDATE(),@RunType INT = 1,@if_Date AS DATETIME = GETDATE(),@OdsCustomerId INT = 1;

DECLARE @SQLScript VARCHAR(MAX) = '
DECLARE @start_dt DATETIME, @end_dt DATETIME;
DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;
										
TRUNCATE TABLE stg.DP_PerformanceReport_BenefitsExhaustedReductions;
INSERT INTO stg.DP_PerformanceReport_BenefitsExhaustedReductions(
	 OdsCustomerId
	,billIDNo
	,line_no
	,line_type
	,EndNote
	,Charged
	,allowed
	,BenefitsExhaustedReductions
	,BenefitsExhaustedReductionsFlag)
SELECT DISTINCT
	 b.OdsCustomerId
	,b.billIDNo
	,b.line_no
	,b.line_type
	,CASE WHEN line_type = 1 THEN boen.OverrideEndNote
		  WHEN line_type = 2 THEN bpoen.OverrideEndNote END ''EndNote''
	,b.charged
	,b.allowed
	,CASE WHEN line_type = 1 THEN b.analyzed - b.allowed
		  WHEN line_type = 2 THEN CASE WHEN b.analyzed > b.charged	THEN ( b.charged - b.allowed )
									   ELSE ( b.analyzed - b.allowed ) END END ''reduction''
	,1 AS BenefitsExhaustedReductionsFlag
FROM    stg.DP_PerformanceReport_Input b
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Bills_OverrideEndNotes' ELSE 'if_Bills_OverrideEndNotes(@RunPostingGroupAuditId)' END+' boen 
	ON b.OdsCustomerId = boen.OdsCustomerId 
	AND b.billIDNo = boen.billIDNo
	AND b.line_no = boen.line_no
	AND boen.OverrideEndNote = 202
	AND b.line_type = 1
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Bills_Pharm_OverrideEndNotes' ELSE 'if_Bills_Pharm_OverrideEndNotes(@RunPostingGroupAuditId)' END+' bpoen 
	ON b.OdsCustomerId = bpoen.OdsCustomerId 
	AND b.billIDNo = bpoen.billIDNo
	AND b.line_no = bpoen.line_no
	AND bpoen.OverrideEndNote = 202
	AND b.line_type = 2

WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN ' b.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ' ELSE '' END +'b.over_ride != 0
	AND (boen.billIDNo IS NOT NULL OR bpoen.billIDNo IS NOT NULL);'
	
EXEC(@SQLScript)

END 

GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.DP_PerformanceReport_reductions_linelevelprioritized') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.DP_PerformanceReport_reductions_linelevelprioritized
GO

CREATE PROCEDURE dbo.DP_PerformanceReport_reductions_linelevelprioritized
AS
BEGIN
	IF OBJECT_ID('tempdb..#BenefitsExhaustedReductions', 'U') IS NOT NULL
		DROP TABLE #BenefitsExhaustedReductions

	SELECT OdsCustomerId
		,billIDNo
		,line_no
		,line_type
		,SUM(BenefitsExhaustedReductions) AS BenefitsExhaustedReductions
		,SUM(BenefitsExhaustedReductionsFlag) AS BenefitsExhaustedReductionsFlag
	INTO #BenefitsExhaustedReductions
	FROM stg.DP_PerformanceReport_BenefitsExhaustedReductions
	GROUP BY OdsCustomerId
		,billIDNo
		,line_no
		,line_type;

	IF OBJECT_ID('tempdb..#PreVPNReductions', 'U') IS NOT NULL
		DROP TABLE #PreVPNReductions

	SELECT OdsCustomerId
		,billIDNo
		,line_no
		,line_type
		,SUM(AnalystReductions) AnalystReductions
		,SUM(AnalystORReductions) AnalystORReductions
		,SUM(DuplicateReductions) DuplicateReductions
		,SUM(BenchmarkReductions) BenchmarkReductions
		,SUM(VPNReductions) VPNReductions
		,SUM(FeeScheduleReductions) FeeScheduleReductions
		,SUM(CTGReductions) CTGReductions
		,SUM(Overrides) Overrides
		,SUM(VPNReductionsFlag) VPNReductionsFlag
		,SUM(DuplicateReductionsFlag) DuplicateReductionsFlag
	INTO #PreVPNReductions
	FROM stg.DP_PerformanceReport_PreVPNReductions
	GROUP BY OdsCustomerId
		,billIDNo
		,line_no
		,line_type;

	IF OBJECT_ID('tempdb..#PostVPNReductions', 'U') IS NOT NULL
		DROP TABLE #PostVPNReductions

	SELECT OdsCustomerId
		,billIDNo
		,line_no
		,line_type
		,SUM(AnalystReductions) AnalystReductions
		,SUM(AnalystORReductions) AnalystORReductions
		,SUM(DuplicateReductions) DuplicateReductions
		,SUM(BenchmarkReductions) BenchmarkReductions
		,SUM(VPNReductions) VPNReductions
		,SUM(FeeScheduleReductions) FeeScheduleReductions
		,SUM(CTGReductions) CTGReductions
		,SUM(Overrides) Overrides
		,SUM(VPNReductionsFlag) VPNReductionsFlag
		,SUM(DuplicateReductionsFlag) DuplicateReductionsFlag
	INTO #PostVPNReductions 
	FROM stg.DP_PerformanceReport_PostVPNReductions
	GROUP BY OdsCustomerId
		,billIDNo
		,line_no
		,line_type

	IF OBJECT_ID('tempdb..#PreVPN_BenefitsExhaustedReductions', 'U') IS NOT NULL
		DROP TABLE #PreVPN_BenefitsExhaustedReductions

	SELECT COALESCE(B.OdsCustomerId, P.OdsCustomerId) OdsCustomerId
		,COALESCE(B.billIDNo, P.billIDNo) billIDNo
		,COALESCE(B.line_no, P.line_no) line_no
		,COALESCE(B.line_type, P.line_type) line_type
		,ISNULL(B.BenefitsExhaustedReductions, 0) BenefitsExhaustedReductions
		,ISNULL(P.AnalystReductions, 0) AnalystReductions
		,ISNULL(P.AnalystORReductions, 0) AnalystORReductions
		,ISNULL(P.DuplicateReductions, 0) DuplicateReductions
		,ISNULL(P.BenchmarkReductions, 0) BenchmarkReductions
		,ISNULL(P.VPNReductions, 0) VPNReductions
		,ISNULL(P.FeeScheduleReductions, 0) FeeScheduleReductions
		,ISNULL(P.CTGReductions, 0) CTGReductions
		,ISNULL(P.Overrides, 0) Overrides
		,ISNULL(P.VPNReductionsFlag, 0) VPNReductionsFlag
		,ISNULL(P.DuplicateReductionsFlag, 0) DuplicateReductionsFlag
		,ISNULL(B.BenefitsExhaustedReductionsFlag,0) BenefitsExhaustedReductionsFlag
		
	INTO #PreVPN_BenefitsExhaustedReductions
	FROM #BenefitsExhaustedReductions B
	FULL OUTER JOIN #PreVPNReductions P ON B.OdsCustomerId = P.OdsCustomerId
		AND B.billIDNo = P.billIDNo
		AND B.line_no = P.line_no
		AND B.line_type = P.line_type;
		
	TRUNCATE TABLE stg.DP_PerformanceReport_linelevelprioritized;
	INSERT INTO stg.DP_PerformanceReport_linelevelprioritized (
		 OdsCustomerId
		,billIDNo
		,line_no
		,line_type
		,BenefitsExhaustedReductions
		,AnalystReductions
		,AnalystORReductions
		,DuplicateReductions
		,BenchmarkReductions
		,VPNReductions
		,FeeScheduleReductions
		,CTGReductions
		,Overrides
		,VPNReductionsFlag
		,DuplicateReductionsFlag
		,BenefitsExhaustedReductionsFlag)
	SELECT COALESCE(B.OdsCustomerId, P.OdsCustomerId) 
		,COALESCE(B.billIDNo, P.billIDNo) billIDNo
		,COALESCE(B.line_no, P.line_no) line_no
		,COALESCE(B.line_type, P.line_type) line_type
		,ISNULL(B.BenefitsExhaustedReductions, 0) BenefitsExhaustedReductions
		,ISNULL(CASE WHEN P.FeeScheduleReductions <> 0 OR P.VPNReductionsFlag <> 0 OR P.BenchmarkReductions <> 0 OR P.DuplicateReductionsFlag <> 0 THEN 0 ELSE P.AnalystReductions END, 0) 
	   + ISNULL(CASE WHEN B.FeeScheduleReductions <> 0 OR B.VPNReductions <> 0 OR B.BenchmarkReductions <> 0 OR B.DuplicateReductions <> 0 OR ISNULL(P.DuplicateReductionsFlag,0) <> 0 THEN 0 ELSE B.AnalystReductions END, 0) 'AnalystReductions'
		,ISNULL(CASE WHEN P.DuplicateReductionsFlag <> 0 THEN 0 ELSE P.AnalystORReductions END, 0) 
	   + ISNULL(CASE WHEN B.DuplicateReductions <> 0 OR ISNULL(P.DuplicateReductionsFlag,0) <> 0 THEN 0 ELSE B.AnalystORReductions END, 0) 'AnalystORReductions'
		,ISNULL(P.DuplicateReductions, 0) + ISNULL(B.DuplicateReductions, 0) 'DuplicateReductions'
		,ISNULL(CASE WHEN P.FeeScheduleReductions <> 0 OR P.VPNReductionsFlag <> 0 OR P.DuplicateReductionsFlag <> 0 THEN 0 ELSE P.BenchmarkReductions END, 0) 
	   + ISNULL(CASE WHEN B.FeeScheduleReductions <> 0 OR B.VPNReductions <> 0 OR B.DuplicateReductions <> 0 OR ISNULL(P.DuplicateReductionsFlag,0) <> 0 THEN 0 ELSE B.BenchmarkReductions END, 0) 'BenchmarkReductions'
		,ISNULL(CASE WHEN P.DuplicateReductionsFlag <> 0 THEN 0 ELSE P.VPNReductions END, 0) 
	   + ISNULL(CASE WHEN B.DuplicateReductions <> 0 OR ISNULL(P.DuplicateReductionsFlag,0) <> 0 THEN 0 ELSE B.VPNReductions END, 0) VPNReductions
		,ISNULL(CASE WHEN P.VPNReductionsFlag <> 0 OR P.DuplicateReductionsFlag <> 0 THEN 0 ELSE P.FeeScheduleReductions END, 0) 
	   + ISNULL(CASE WHEN B.VPNReductions <> 0 OR B.DuplicateReductions <> 0 OR ISNULL(P.DuplicateReductionsFlag,0) <> 0 THEN 0 ELSE B.FeeScheduleReductions END, 0) 'FeeScheduleReductions'
		,ISNULL(CASE WHEN P.FeeScheduleReductions <> 0 OR P.VPNReductionsFlag <> 0 OR P.BenchmarkReductions <> 0 OR P.DuplicateReductionsFlag <> 0 OR P.AnalystReductions <> 0 THEN 0 ELSE P.CTGReductions END, 0) 
	   + ISNULL(CASE WHEN B.FeeScheduleReductions <> 0 OR B.VPNReductions <> 0 OR B.BenchmarkReductions <> 0 OR B.DuplicateReductions <> 0 OR B.AnalystReductions <> 0 OR ISNULL(P.DuplicateReductionsFlag,0) <> 0 THEN 0 ELSE B.CTGReductions END, 0) 'CTGReductions'
		,ISNULL(CASE WHEN ISNULL(B.BenefitsExhaustedReductionsFlag,0) <> 0 THEN 0 ELSE P.Overrides END, 0) 
	   + ISNULL(CASE WHEN ISNULL(P.DuplicateReductionsFlag,0) <> 0 THEN 0 ELSE B.Overrides END, 0) 'Overrides'
	   ,P.VPNReductionsFlag
	   ,ISNULL(P.DuplicateReductionsFlag,0) 'DuplicateReductionsFlag'
	   ,ISNULL(B.BenefitsExhaustedReductionsFlag,0) BenefitsExhaustedReductionsFlag
	FROM #PreVPN_BenefitsExhaustedReductions B
	FULL OUTER JOIN #PostVPNReductions P ON B.OdsCustomerId = P.OdsCustomerId
		AND B.billIDNo = P.billIDNo
		AND B.line_no = P.line_no
		AND B.line_type = P.line_type
END
GO



IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.DP_PerformanceReport_reductions_postvpn') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.DP_PerformanceReport_reductions_postvpn
GO

CREATE PROCEDURE dbo.DP_PerformanceReport_reductions_postvpn (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 1)
AS
BEGIN

-- Setup Run parameters
-- DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@RunDate AS DATETIME = GETDATE(),@RunType INT = 1,@if_Date AS DATETIME = GETDATE();

DECLARE @SQLScript VARCHAR(MAX) = '
DECLARE @start_dt DATETIME, @end_dt DATETIME;
DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;

-- Filter BILLS_Endnotes data
IF OBJECT_ID(''tempdb..#BILLS_Endnotes'') IS NOT NULL DROP TABLE #BILLS_Endnotes
SELECT be.OdsCustomerId
	,be.billIDNo
	,be.line_no
	,be.EndNote
INTO #BILLS_Endnotes
FROM stg.DP_PerformanceReport_Input b
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BILLS_Endnotes' ELSE 'if_BILLS_Endnotes(@RunPostingGroupAuditId)' END+' be ON be.OdsCustomerId = b.OdsCustomerId
	AND be.billIDNo = b.billIDNo
	AND be.line_no = b.line_no
	AND b.line_type = 1
'+CASE WHEN @OdsCustomerId <> 0 THEN 'WHERE b.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +';
	
CREATE CLUSTERED INDEX Idx_CustomerIdBillIdNoLineNoLineType ON #BILLS_Endnotes
(OdsCustomerId,BillIdNo,Line_no);
										

-- Get Bill Line EndNotes	
IF OBJECT_ID(''tempdb..#IntermPostVPNReductions'') IS NOT NULL DROP TABLE #IntermPostVPNReductions	
SELECT DISTINCT
	 m.OdsCustomerId
	,m.billIDNo
	,m.line_no
	,m.line_type
	,m.charged
	,m.allowed
	,ISNULL(r.CategoryIdNo,r2.CategoryIdNo) AS CategoryIdNo
	,m.OVER_RIDE
	,m.analyzed
-- Set Reductions
	,CASE WHEN m.over_ride = 0 AND (((r.CategoryIdNo = 1 AND be2.billIDNo IS NULL) 
									OR (m.line_type = 1 AND be.billIDNo IS NULL))
							  OR ((r2.CategoryIdNo = 1 AND bpe2.billIDNo IS NULL) 
									OR (m.line_type = 2 AND bpe.billIDNo IS NULL AND ctg.billIDNo IS NULL AND (m.charged - ISNULL(m.PreApportionedAmount,m.allowed)) > 0))) THEN (m.charged - ISNULL(m.PreApportionedAmount,m.allowed)) 
		 ELSE 0 END AS ''AnalystReductions''
	,CASE WHEN m.over_ride != 0 AND m.line_type = 1 THEN m.charged - m.analyzed 
		 WHEN m.over_ride != 0 AND m.line_type = 2 THEN CASE WHEN m.analyzed > m.charged THEN 0 ELSE m.charged - m.analyzed  END
		 ELSE 0 END AS ''AnalystORReductions''
	,CASE WHEN (m.over_ride = 0 AND be2.billIDNo IS NOT NULL) OR (m.over_ride = 0 AND bpe2.billIDNo IS NOT NULL AND r2.CategoryIdNo = 1) THEN m.charged - ISNULL(m.PreApportionedAmount,m.allowed) 
		 ELSE 0 END AS ''DuplicateReductions''
	,CASE WHEN m.over_ride = 0 AND (r.CategoryIdNo = 2 OR r2.CategoryIdNo = 2) THEN m.charged - ISNULL(m.PreApportionedAmount,m.allowed) 
		 ELSE 0 END AS ''BenchmarkReductions''
	,CASE WHEN m.over_ride = 0 
			AND (r.CategoryIdNo = 3 OR r2.CategoryIdNo = 3) 
			AND (r.ShortDesc NOT LIKE ''%reviewed%'' OR r2.ShortDesc NOT LIKE ''%reviewed%'') 
			AND p.billIDNo IS NOT NULL THEN p.ALLOWED - ISNULL(m.PreApportionedAmount,m.allowed)
		 ELSE 0 END AS ''VPNReductions''
	,CASE WHEN m.over_ride = 0 AND (r.CategoryIdNo = 4 OR r2.CategoryIdNo = 4) THEN  m.charged - ISNULL(m.PreApportionedAmount,m.allowed) 
		 ELSE 0 END AS ''FeeScheduleReductions'' 
	,CASE WHEN m.over_ride = 0 AND (((r.CategoryIdNo = 5 AND bctg.billIDNo IS NULL) OR (r.CategoryIdNo <> 5 AND bctg.billIDNo IS NOT NULL)) 
			  OR ((r2.CategoryIdNo = 5 AND ctg.billIDNo IS NULL) OR (r2.CategoryIdNo <> 5 AND ctg.billIDNo IS NOT NULL))) THEN  m.charged - ISNULL(m.PreApportionedAmount,m.allowed) 
		 ELSE 0 END AS ''CTGReductions''
	,CASE WHEN m.over_ride != 0 AND m.line_type = 1 THEN m.analyzed - ISNULL(m.PreApportionedAmount,m.allowed)
		 WHEN m.over_ride != 0 AND m.line_type = 2 THEN CASE WHEN m.analyzed > m.charged  THEN (m.charged - ISNULL(m.PreApportionedAmount,m.allowed)) ELSE ( m.analyzed - ISNULL(m.PreApportionedAmount,m.allowed) ) END
		 ELSE 0 END	 ''Overrides''
	,CASE WHEN m.over_ride = 0 
			AND (r.CategoryIdNo = 3 OR r2.CategoryIdNo = 3) 
			AND (r.ShortDesc NOT LIKE ''%reviewed%'' OR r2.ShortDesc NOT LIKE ''%reviewed%'') 
			AND p.billIDNo IS NOT NULL THEN 1
		 ELSE 0 END ''VPNReductionsFlag''
	,CASE WHEN (m.over_ride = 0 AND be2.billIDNo IS NOT NULL) OR (m.over_ride = 0 AND bpe2.billIDNo IS NOT NULL AND r2.CategoryIdNo = 1) THEN 1 
		 ELSE 0 END AS ''DuplicateReductionsFlag''

INTO #IntermPostVPNReductions			 
FROM stg.DP_PerformanceReport_Input m
LEFT OUTER JOIN #BILLS_Endnotes be 
	ON be.OdsCustomerId = m.OdsCustomerId
	AND be.billIDNo = m.billIDNo
    AND be.line_no = m.line_no
    AND m.line_type = 1
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'rsn_REASONS' ELSE 'if_rsn_REASONS(@RunPostingGroupAuditId)' END+' r 
	ON r.OdsCustomerId = be.OdsCustomerId
	AND r.ReasonNumber = be.EndNote
LEFT OUTER JOIN #BILLS_Endnotes be2
	ON be2.OdsCustomerId = m.OdsCustomerId
	AND be2.billIDNo = m.billIDNo
	AND be2.line_no = m.line_no
	AND m.line_type = 1
    AND be2.EndNote = 4
	AND m.allowed = 0
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Bills_CTG_Endnotes' ELSE 'if_Bills_CTG_Endnotes(@RunPostingGroupAuditId)' END+' bctg
    ON bctg.OdsCustomerId = m.OdsCustomerId
    AND bctg.billIDNo = m.billIDNo
    AND bctg.line_no = m.line_no 
    AND m.line_type = 1
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Bills_Pharm_Endnotes' ELSE 'if_Bills_Pharm_Endnotes(@RunPostingGroupAuditId)' END+' bpe 
	ON bpe.OdsCustomerId = m.OdsCustomerId
	AND bpe.billIDNo = m.billIDNo
    AND bpe.line_no = m.line_no
    AND m.line_type = 2
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'rsn_REASONS' ELSE 'if_rsn_REASONS(@RunPostingGroupAuditId)' END+' r2 
	ON r2.OdsCustomerId = bpe.OdsCustomerId
	AND r2.ReasonNumber = bpe.EndNote
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Bills_Pharm_Endnotes' ELSE 'if_Bills_Pharm_Endnotes(@RunPostingGroupAuditId)' END+' bpe2 
	ON bpe2.OdsCustomerId = m.OdsCustomerId
	AND bpe2.billIDNo = m.billIDNo
    AND bpe2.line_no = m.line_no
    AND m.line_type = 2
    AND bpe2.EndNote = 4
    AND m.allowed = 0 
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Bills_Pharm_CTG_Endnotes' ELSE 'if_Bills_Pharm_CTG_Endnotes(@RunPostingGroupAuditId)' END+' ctg
    ON ctg.OdsCustomerId = m.OdsCustomerId
    AND ctg.billIDNo = m.billIDNo
    AND ctg.line_no = m.line_no 
    AND m.line_type = 2
LEFT OUTER JOIN stg.DP_PerformanceReport_MaxPrePPOBillInfo p
	ON p.OdsCustomerId = m.OdsCustomerId
	AND p.billIDNo = m.billIDNo
    AND p.line_no = m.line_no
    AND p.Line_type = m.line_type
'+CASE WHEN @OdsCustomerId <> 0 THEN 'WHERE m.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +';

-- When Inserting the data into the table, rank by category so can use to zero-out repeated values.
TRUNCATE TABLE stg.DP_PerformanceReport_PostVPNReductions;
INSERT INTO stg.DP_PerformanceReport_PostVPNReductions(
	 OdsCustomerId
	,billIDNo
	,line_no
	,line_type
	,charged
	,allowed
	,categoryIDNo
	,OVER_RIDE
	,analyzed
	,AnalystReductions
	,AnalystORReductions
	,DuplicateReductions
	,BenchmarkReductions
	,VPNReductions
	,FeeScheduleReductions
	,CTGReductions
	,Overrides
	,VPNReductionsFlag
	,DuplicateReductionsFlag
	,LLevel )
SELECT OdsCustomerId
	,billIDNo
	,line_no
	,line_type
	,charged
	,allowed
	,categoryIDNo
	,OVER_RIDE
	,analyzed
	,AnalystReductions
	,AnalystORReductions
	,DuplicateReductions
	,BenchmarkReductions
	,VPNReductions
	,FeeScheduleReductions
	,CTGReductions
	,Overrides
	,VPNReductionsFlag
	,DuplicateReductionsFlag
	,Row_Number() OVER (PARTITION BY OdsCustomerId,billIDNo,line_no,line_type ORDER BY categoryIDNo) LLevel 
FROM #IntermPostVPNReductions   

-- Update these so they are only at the line level, else will result in duplicates when summed later.    
UPDATE stg.DP_PerformanceReport_PostVPNReductions
SET  AnalystORReductions = 0
	,Overrides = 0
	,DuplicateReductions  = 0
WHERE LLevel <> 1;'

EXEC(@SQLScript)

END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.DP_PerformanceReport_reductions_prevpn') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.DP_PerformanceReport_reductions_prevpn
GO

CREATE PROCEDURE dbo.DP_PerformanceReport_reductions_prevpn (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 1)
AS
BEGIN

-- Setup Run parameters
-- DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@RunDate AS DATETIME = GETDATE(),@RunType INT = 1,@if_Date AS DATETIME = GETDATE();

DECLARE @SQLScript VARCHAR(MAX) = '
DECLARE @start_dt DATETIME, @end_dt DATETIME;
DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;
										
-- Filter BILLS_Endnotes data
IF OBJECT_ID(''tempdb..#BILLS_Endnotes'') IS NOT NULL DROP TABLE #BILLS_Endnotes
SELECT be.OdsCustomerId
	,be.billIDNo
	,be.line_no
	,be.EndNote
INTO #BILLS_Endnotes
FROM stg.DP_PerformanceReport_Input b
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BILLS_Endnotes' ELSE 'if_BILLS_Endnotes(@RunPostingGroupAuditId)' END+' be ON be.OdsCustomerId = b.OdsCustomerId
	AND be.billIDNo = b.billIDNo
	AND be.line_no = b.line_no
	AND b.line_type = 1
'+CASE WHEN @OdsCustomerId <> 0 THEN 'WHERE b.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +';
	
CREATE CLUSTERED INDEX Idx_CustomerIdBillIdNoLineNoLineType ON #BILLS_Endnotes
(OdsCustomerId,BillIdNo,Line_no);
	
-- Get Bill Line EndNotes	
IF OBJECT_ID(''tempdb..#IntermPreVPNReductions'') IS NOT NULL DROP TABLE #IntermPreVPNReductions	
SELECT DISTINCT  
	 b.OdsCustomerId
	,b.billIDNo
	,b.line_no
	,b.line_type
	,b.charged
	,pb.ALLOWED
	,r3.CategoryIdNo
	,pb.OVER_RIDE
--	,e.StringText AS OriginalEndnote 
	,CASE WHEN pb.Endnotes = ''4'' THEN 1
		  ELSE 0 END AS IsZeroAllowedDuplicateLine
	,pb.ANALYZED
-- Set Reductions
	,CASE WHEN pb.OVER_RIDE = 0 AND r3.CategoryIdNo = 1 THEN b.charged - pb.ALLOWED
		  WHEN pb.OVER_RIDE = 0 AND r3.CategoryIdNo IS NULL THEN b.charged - pb.ALLOWED 
		  WHEN pb.OVER_RIDE = 0 AND r3.CategoryIdNo NOT IN (1,2,3,4,5) THEN b.charged - pb.ALLOWED 
		  ELSE 0.0 END AS ''AnalystReductions'' 
	,CASE WHEN pb.OVER_RIDE <> 0 AND b.line_type = 1 THEN b.charged - pb.ANALYZED
		  WHEN pb.OVER_RIDE <> 0 AND b.line_type = 2 THEN ( CASE WHEN pb.ANALYZED > b.charged THEN 0 ELSE (b.charged - pb.ANALYZED)END ) 
          ELSE 0 END AS ''AnalystORReductions''
-- Mirroring the Duplicate reduction logic here
    ,CASE WHEN pb.OVER_RIDE = 0 AND b.line_type = 1 AND pb.Endnotes = ''4'' THEN b.charged - pb.allowed
	      WHEN pb.OVER_RIDE = 0 AND b.line_type = 2 AND pb.Endnotes = ''4'' AND pb.allowed = 0 AND r3.categoryIDNo = 1 THEN b.charged - pb.allowed
		  ELSE 0 END AS ''DuplicateReductions''
	,CASE WHEN r3.CategoryIdNo = 2  AND pb.OVER_RIDE = 0 THEN b.charged - pb.allowed 
		  ELSE 0 END AS ''BenchmarkReductions''
	,CASE WHEN r3.CategoryIdNo = 3  AND pb.OVER_RIDE = 0 THEN b.charged - pb.allowed 
		  ELSE 0 END AS ''VPNReductions''
	,CASE WHEN r3.CategoryIdNo = 4  AND pb.OVER_RIDE = 0 THEN b.charged - pb.allowed 
		  ELSE 0 END AS ''FeeScheduleReductions''
	,CASE WHEN r3.CategoryIdNo = 5  AND pb.OVER_RIDE = 0 THEN b.charged - pb.allowed 
		  ELSE 0 END AS ''CTGReductions''
	,CASE WHEN pb.OVER_RIDE <> 0 THEN CASE WHEN b.line_type = 1 THEN (pb.analyzed - pb.allowed)
										   WHEN b.line_type = 2 THEN (CASE WHEN pb.analyzed > b.charged THEN (b.charged - pb.allowed) ELSE (pb.analyzed - pb.allowed)END)
										   ELSE 0 END   
		  ELSE 0 END AS ''Overrides''
	,0 AS ''VPNReductionsFlag''
	,0 AS ''DuplicateReductionsFlag''
	,COALESCE(r1.ReasonNumber,r2.ReasonNumber,0) ReasonNumber
INTO #IntermPreVPNReductions
FROM stg.DP_PerformanceReport_Input b
INNER JOIN stg.DP_PerformanceReport_MaxPrePPOBillInfo pb
	ON b.OdsCustomerId = pb.OdsCustomerId
	AND b.billIDNo = pb.billIDNo
	AND b.line_no = pb.line_no
	AND b.line_type = pb.line_type
	AND b.over_ride = 0
LEFT OUTER JOIN #BILLS_Endnotes be 
	ON be.OdsCustomerId = b.OdsCustomerId
	AND be.billIDNo = b.billIDNo
	AND be.line_no = b.line_no
	AND b.line_type = 1
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Bills_Pharm_Endnotes' ELSE 'if_Bills_Pharm_Endnotes(@RunPostingGroupAuditId)' END+' bpe 
	ON bpe.OdsCustomerId = b.OdsCustomerId
	AND bpe.billIDNo = b.billIDNo
    AND bpe.line_no = b.line_no
    AND b.line_type = 2
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'rsn_REASONS' ELSE 'if_rsn_REASONS(@RunPostingGroupAuditId)' END+' r1 
	ON r1.OdsCustomerId = bpe.OdsCustomerId
	AND r1.ReasonNumber = bpe.EndNote
	AND r1.CategoryIdNo = 3
	AND r1.ShortDesc NOT LIKE ''%reviewed%''
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'rsn_REASONS' ELSE 'if_rsn_REASONS(@RunPostingGroupAuditId)' END+' r2 
	ON r2.OdsCustomerId = be.OdsCustomerId
	AND r2.ReasonNumber = be.EndNote
	AND r2.CategoryIdNo = 3
	AND r2.ShortDesc NOT LIKE ''%reviewed%''
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'rsn_REASONS' ELSE 'if_rsn_REASONS(@RunPostingGroupAuditId)' END+' r3 
	ON pb.OdsCustomerId = r3.OdsCustomerId
	AND pb.Endnotes = r3.ReasonNumber
'+CASE WHEN @OdsCustomerId <> 0 THEN 'WHERE b.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +';

	  
TRUNCATE TABLE stg.DP_PerformanceReport_PreVPNReductions;
INSERT INTO stg.DP_PerformanceReport_PreVPNReductions(
	 OdsCustomerId
	,billIDNo
	,line_no
	,line_type
	,charged
	,allowed
	,categoryIDNo
	,OVER_RIDE
	,IsZeroAllowedDuplicateLine
	,analyzed
	,AnalystReductions
	,AnalystORReductions
	,DuplicateReductions
	,BenchmarkReductions
	,VPNReductions
	,FeeScheduleReductions
	,CTGReductions
	,Overrides
	,VPNReductionsFlag
	,DuplicateReductionsFlag
	,LLevel)
SELECT
	 OdsCustomerId
	,billIDNo
	,line_no
	,line_type
	,charged
	,allowed
	,categoryIDNo
	,OVER_RIDE
	,IsZeroAllowedDuplicateLine
	,analyzed
	,AnalystReductions
	,AnalystORReductions
	,DuplicateReductions
	,BenchmarkReductions
	,VPNReductions
	,FeeScheduleReductions
	,CTGReductions
	,Overrides
	,VPNReductionsFlag
	,DuplicateReductionsFlag
	,Row_Number() OVER (PARTITION BY OdsCustomerId,billIDNo,line_no,line_type ORDER BY CategoryIdNo) LLevel
FROM #IntermPreVPNReductions
WHERE ReasonNumber <> 0;
	  
-- Update these so they are only at the line level, else will result in duplicates when summed later.    
UPDATE stg.DP_PerformanceReport_PreVPNReductions
SET  AnalystORReductions = 0
	,Overrides = 0
WHERE LLevel <> 1;'

EXEC(@SQLScript);

END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.DP_PerformanceReport_reductions_rollup') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.DP_PerformanceReport_reductions_rollup
GO

CREATE PROCEDURE dbo.DP_PerformanceReport_reductions_rollup(
@SourceDatabaseName VARCHAR(50)='AcsOds',
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@ReportType INT = 1,
@OdsCustomerID INT = 0,
@TargetDatabaseName VARCHAR(50) = 'ReportDB')
AS
BEGIN
	--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@ReportType INT = 1,@RunType INT = 0,@if_Date AS DATETIME = GETDATE()
	DECLARE @SQLScript VARCHAR(MAX);
		
	IF OBJECT_ID('tempdb..#BillsWithDuplicateLineCount') IS NOT NULL	DROP TABLE #BillsWithDuplicateLineCount;
	SELECT OdsCustomerId
		,billIDNo
		,COUNT(1) LineCount
		,SUM(CASE WHEN DuplicateReductionsFlag <> 0 THEN 1 ELSE 0 END) DuplicateLineCount
	INTO #BillsWithDuplicateLineCount
	FROM stg.DP_PerformanceReport_linelevelprioritized
	GROUP BY OdsCustomerId,billIDNo
	HAVING SUM(CASE WHEN DuplicateReductionsFlag <> 0 THEN 1 ELSE 0 END) = COUNT(1); 
	
	IF OBJECT_ID('tempdb..#tempConsolidatedReductions') IS NOT NULL	DROP TABLE #tempConsolidatedReductions
	SELECT P.OdsCustomerId
		,P.billIDNo
		,B.billIDNo AS DuplicateBillidNo
		,P.line_no
		,P.line_type
		,P.BenefitsExhaustedReductions
		,CASE WHEN  (ISNULL(P.AnalystReductions,0) + ISNULL(P.AnalystORReductions,0)) = 0 
				AND P.FeeScheduleReductions = 0 
				AND P.BenchmarkReductions = 0
				AND P.VPNReductions = 0 
				AND P.CTGReductions = 0 
				AND P.DuplicateReductions = 0 
				AND P.BenefitsExhaustedReductions = 0
				AND P.Overrides = 0 THEN 1 ELSE 0 END AS RecompAnalystReductions
		,ISNULL(P.AnalystReductions,0) + ISNULL(P.AnalystORReductions,0) AnalystReductions
		,P.AnalystORReductions
		,P.DuplicateReductions
		,P.BenchmarkReductions
		,P.VPNReductions
		,P.FeeScheduleReductions
		,P.CTGReductions
		,P.Overrides
		,P.VPNReductionsFlag
		,P.DuplicateReductionsFlag
		,P.BenefitsExhaustedReductionsFlag
		
	INTO #tempConsolidatedReductions	
	FROM stg.DP_PerformanceReport_linelevelprioritized P
	LEFT OUTER JOIN #BillsWithDuplicateLineCount B
		ON P.OdsCustomerId = B.OdsCustomerId
		AND P.billIDNo = B.billIDNo;
		
	-- Indexes On Filtered Data
	CREATE CLUSTERED INDEX Idx_CustomerIdBillIdNoLineNoLineType 
	ON #tempConsolidatedReductions(OdsCustomerId,BillIdNo,Line_no,Line_type)
	WITH (DATA_COMPRESSION = PAGE);
	
	SET @SQLScript = '
	DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;

	DELETE FROM '+@TargetDatabaseName+'.dbo.DP_PerformanceReport_Output
	WHERE ReportTypeID  = '+CAST(@ReportType AS VARCHAR(2))+CASE WHEN @OdsCustomerID <> 0 THEN ' AND OdsCustomerId = '+CAST(@OdsCustomerID as VARCHAR(5)) ELSE '' END +';
										
	SELECT m.OdsCustomerId
		,DATEADD(MONTH, DATEDIFF(MONTH, 0, m.CreateDate), 0) AS StartOfMonth
		,C.CustomerName AS Customer
		,YEAR(m.CreateDate) AS Year
		,MONTH(m.CreateDate) AS Month
		,ISNULL(m.Company, ''NA'') AS Company
		,ISNULL(m.Office, ''NA'') AS Office
		,ISNULL(m.SOJ, ''NA'') AS SOJ
		,ISNULL(m.Coverage, ''NA'') AS Coverage
		,ISNULL(m.Form_Type, ''NA'') AS Form_Type
		,m.claimNo
		,m.ClaimIDNo
		,m.CmtIDNo
		,m.billIDNo
		,m.line_no
		,m.units
		,m.charged
		,m.allowed
		,r.DuplicateReductions 
		,CASE WHEN r.RecompAnalystReductions  = 1 AND (m.charged - m.allowed > 0) THEN (m.charged - m.allowed) ELSE r.AnalystReductions END RecompAnalystReductions 
		,r.FeeScheduleReductions 
		,r.BenchmarkReductions 
		,r.CTGReductions
		,CASE WHEN r.DuplicateReductions <> 0 THEN m.BillIDNo END AS BillsWithOneOrMoreDuplicateLines
		,CASE WHEN r.DuplicateReductions <> 0 THEN m.BillIDNo END AS PartialDuplicateBills
		,r.DuplicateBillidNo
		,CASE WHEN r.DuplicateReductionsFlag <> 0 THEN 1 ELSE 0 END Dup_Lines
		,CASE WHEN r.BenefitsExhaustedReductionsFlag <> 0 THEN m.BillIDNo END BenefitsExhausted_Bills
		,CASE WHEN r.BenefitsExhaustedReductionsFlag <> 0 THEN 1 ELSE 0 END BenefitsExhausted_Lines
		,r.BenefitsExhaustedReductions
		,CASE WHEN r.RecompAnalystReductions  = 1 AND (m.charged - m.allowed > 0) THEN (m.charged - m.allowed) ELSE r.AnalystReductions END AnalystReductions
		,r.VPNReductions
		,r.Overrides

	INTO #DP_PerformanceReport_rollup
	FROM stg.DP_PerformanceReport_Input m
	INNER JOIN #tempConsolidatedReductions r ON m.OdsCustomerId = r.OdsCustomerId
		AND m.billIDNo = r.billIDNo
		AND m.line_no = r.line_no
		AND m.line_type = r.line_type
	INNER JOIN '+@SourceDatabaseName+'.adm.Customer C
		ON m.OdsCustomerId = c.CustomerId
	LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CustomerBillExclusion' ELSE'if_CustomerBillExclusion(@RunPostingGroupAuditId)' END+' ex 
		ON C.CustomerDatabase = ex.Customer
		AND m.billIDNo = ex.billIDNo
		AND ex.ReportID = 1
	
	WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN ' m.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ' ELSE '' END +'ex.billIDNo IS NULL;
		
	CREATE CLUSTERED INDEX Idx_CustomerIdBillIdNoLineNoLineType 
	ON #DP_PerformanceReport_rollup(OdsCustomerId,StartOfMonth,Customer,Year,Month,Company,Office,SOJ,Coverage,Form_Type)
	WITH (DATA_COMPRESSION = PAGE);
		
	
	INSERT INTO '+@TargetDatabaseName+'.dbo.DP_PerformanceReport_Output(
		 OdsCustomerId
		,StartOfMonth
		,Customer
		,Year
		,Month
		,Company
		,Office
		,SOJ
		,Coverage
		,Form_Type'
		+ CASE WHEN @ReportType = 3 THEN CHAR(13)+CHAR(10)+CHAR(9)+CHAR(9)+',ClaimIDNo'+CHAR(13)+CHAR(10)+CHAR(9)+CHAR(9)+',CmtIDNo' ELSE '' END+CHAR(13)+CHAR(10)+CHAR(9)+CHAR(9)+  
		',Total_Claims
		,Total_Claimants
		,Total_Bills
		,Total_Lines
		,Total_Units
		,Total_Provider_Charges
		,Total_Final_Allowed
		,Total_Reductions
		,Total_Bill_Review_Reductions
		,BillsWithOneOrMoreDuplicateLinesCount
		,PartialDuplicateBills
		,DuplicateBillsCount
		,Dup_Lines_Count
		,Duplicate_Reductions
		,BenefitsExhausted_Bills_Count
		,BenefitsExhausted_Lines_Count
		,BenefitsExhausted_Reductions
		,Analyst_Reductions
		,Fee_Schedule_Reductions
		,Benchmark_Reductions
		,CTG_Reductions
		,VPN_Reductions
		,Override_Impact
		,ReportTypeID
		,LastUpdate)	
	SELECT
		 OdsCustomerId
		,StartOfMonth
		,Customer
		,Year
		,Month
		,Company
		,Office
		,SOJ
		,Coverage
		,Form_Type'
		+ CASE WHEN @ReportType = 3 THEN CHAR(13)+CHAR(10)+CHAR(9)+CHAR(9)+',ClaimIDNo'+CHAR(13)+CHAR(10)+CHAR(9)+CHAR(9)+',CmtIDNo' ELSE '' END+CHAR(13)+CHAR(10)+CHAR(9)+CHAR(9)+  
		',COUNT(DISTINCT claimNo) Total_Claims
		,COUNT(DISTINCT CmtIDNo) Total_Claimants
		,COUNT(DISTINCT billIDNo) Total_Bills
		,COUNT(line_no) Total_Lines
		,SUM(units) Total_Units
		,SUM(charged) Total_Provider_Charges
		,SUM(allowed) Total_Final_Allowed
		,SUM(charged) - SUM(allowed) Total_Reductions
		,SUM(DuplicateReductions) 
			+ SUM(RecompAnalystReductions)
			+ SUM(FeeScheduleReductions) 
			+ SUM(BenchmarkReductions) 
			+ SUM(CTGReductions) Total_Bill_Review_Reductions
		,COUNT(DISTINCT BillsWithOneOrMoreDuplicateLines) AS BillsWithOneOrMoreDuplicateLinesCount
		,COUNT(DISTINCT PartialDuplicateBills) - COUNT(DISTINCT DuplicateBillidNo) AS PartialDuplicateBills
		,COUNT(DISTINCT DuplicateBillidNo) AS DuplicateBillsCount
		,SUM(Dup_Lines) Dup_Lines_Count
		,SUM(DuplicateReductions) Duplicate_Reductions
		,COUNT(DISTINCT BenefitsExhausted_Bills) "BenefitsExhausted_Bills_Count"
		,SUM(BenefitsExhausted_Lines) "BenefitsExhausted_Lines_Count"
		,SUM(BenefitsExhaustedReductions) "BenefitsExhausted_Reductions"
		,SUM(AnalystReductions) Analyst_Reductions
		,SUM(FeeScheduleReductions) Fee_Schedule_Reductions
		,SUM(BenchmarkReductions) Benchmark_Reductions
		,SUM(CTGReductions) CTG_Reductions
		,SUM(VPNReductions) VPN_Reductions
		,SUM(Overrides) Override_Impact
		,'+CAST(@ReportType AS VARCHAR(2))+' AS ReportTypeID
		,GETDATE()
	FROM #DP_PerformanceReport_rollup R1
	GROUP BY OdsCustomerId
		,StartOfMonth
		,Customer
		,Year
		,Month
		,Company
		,Office
		,SOJ
		,Coverage
		,Form_Type'
		+ CASE WHEN @ReportType = 3 THEN CHAR(13)+CHAR(10)+CHAR(9)+CHAR(9)+',ClaimIDNo'+CHAR(13)+CHAR(10)+CHAR(9)+CHAR(9)+',CmtIDNo' ELSE '' END+CHAR(13)+CHAR(10)+  
	'OPTION (HASH GROUP);'
		
	EXEC (@SQLScript);	
	
END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.DP_PerformanceReport_SplitLines') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.DP_PerformanceReport_SplitLines
GO

CREATE PROCEDURE dbo.DP_PerformanceReport_SplitLines(
@OdsCustomerId INT = 0)
AS
BEGIN
-- Setup Run parameters
-- DECLARE @OdsCustomerId INT = 5;
DECLARE @SQLScript VARCHAR(MAX) = '	
DECLARE  @returnstatus INT;
									
-- Identify Split Lines and Join with child lines
IF OBJECT_ID(''tempdb..#GroupedLines'') IS NOT NULL DROP TABLE #GroupedLines
SELECT   T1.OdsCustomerId
		,T1.billIDNo
        ,1 AS actionIndicator
        ,T2.ref_line_no
        ,T2.line_no
        ,T2.charged
        
INTO #GroupedLines
FROM    stg.DP_PerformanceReport_Input T1
INNER JOIN stg.DP_PerformanceReport_Input T2
	ON T1.OdsCustomerId = T2.OdsCustomerId
	AND T1.billIDNo = T2.billIDNo
	AND T1.line_no = T2.ref_line_no 
	AND T1.line_no != T2.line_no

WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN ' T1.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ' ELSE '' END +'T1.line_type = 1
        AND T1.line_no_disp = 0
        AND T1.charged = 0
        AND T1.allowed > 0;

-- Update split line charges with sum of charged from children and set Children to zero
;WITH cte_LineCharges AS(
SELECT  billIDNo
		,OdsCustomerId
		,ref_line_no
		,SUM(ISNULL(charged,0)) AS Charged
FROM #GroupedLines
GROUP BY billIDNo
		 ,OdsCustomerId
		 ,ref_line_no)        
SELECT T.OdsCustomerId
      ,T.billIDNo
      ,T.line_type
      ,T.line_no
      ,T.CreateDate
      ,T.CompanyID
      ,T.Company
      ,T.OfficeID
      ,T.Office
      ,T.Coverage
      ,T.claimNo
      ,T.ClaimIDNo
      ,T.CmtIDNo
      ,T.SOJ
      ,T.Form_Type
      ,T.ProviderZipOfService
      ,T.TypeOfBill
      ,T.DiagnosisCode
      ,T.ProcedureCode
      ,T.ProviderSpecialty
      ,T.ProviderType
      ,T.ProviderType_Desc
      ,T.line_no_disp
      ,0 as ref_line_no
      ,T.over_ride
      ,CASE WHEN S.Billidno IS NOT NULL THEN S.Charged 
					 WHEN G.billIDNo IS NOT NULL THEN 0 ELSE T.Charged END AS charged
      ,T.allowed
      ,T.PreApportionedAmount
      ,T.analyzed
      ,T.units
      ,T.reporttype
      ,T.RunDate 
INTO #DP_PerformanceReport_Input
FROM stg.DP_PerformanceReport_Input T
LEFT OUTER JOIN #GroupedLines G
	ON T.OdsCustomerId = G.OdsCustomerId 
	AND T.billIDNo = G.billIDNo
	AND T.line_no = G.line_no
LEFT OUTER JOIN cte_LineCharges S 
	ON T.OdsCustomerId = S.OdsCustomerId	
	AND T.billIDNo = S.billIDNo
	AND T.line_no = S.ref_line_no'+
CASE WHEN @OdsCustomerId <> 0 THEN CHAR(13)+CHAR(10)+'WHERE  T.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+';' ELSE ';'+CHAR(13)+CHAR(10) END +
CASE WHEN @OdsCustomerID <> 0 THEN '

EXEC adm.Rpt_CreateUnpartitionedTableSchema '+CAST(@OdsCustomerId AS VARCHAR(3))+',16,1,@returnstatus;
EXEC adm.Rpt_CreateUnpartitionedTableIndexes '+CAST(@OdsCustomerId AS VARCHAR(3))+',16,@returnstatus;
EXEC adm.Rpt_SwitchUnpartitionedTable '+CAST(@OdsCustomerId AS VARCHAR(3))+',16,'''',1,@returnstatus;

DROP TABLE stg.DP_PerformanceReport_Input_Unpartitioned;' 

ELSE '
TRUNCATE TABLE stg.DP_PerformanceReport_Input;' END+'

INSERT INTO stg.DP_PerformanceReport_Input
SELECT OdsCustomerId
      ,billIDNo
      ,line_type
      ,line_no
      ,CreateDate
      ,CompanyID
      ,Company
      ,OfficeID
      ,Office
      ,Coverage
      ,claimNo
      ,ClaimIDNo
      ,CmtIDNo
      ,SOJ
      ,Form_Type
      ,ProviderZipOfService
      ,TypeOfBill
      ,DiagnosisCode
      ,ProcedureCode
      ,ProviderSpecialty
      ,ProviderType
      ,ProviderType_Desc
      ,line_no_disp
      ,ref_line_no
      ,over_ride
      ,charged
      ,allowed
      ,PreApportionedAmount
      ,analyzed
      ,units
      ,reporttype
      ,RunDate
FROM #DP_PerformanceReport_Input;'
	
EXEC (@SQLScript);

END 
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.DP_PerformanceReport_3rdParty_Adjustments') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.DP_PerformanceReport_3rdParty_Adjustments
GO

CREATE PROCEDURE dbo.DP_PerformanceReport_3rdParty_Adjustments(
@SourceDatabaseName VARCHAR(50)='AcsOds',
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@ReportType INT = 1,
@OdsCustomerID INT = 0)
AS
BEGIN

--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@ReportType INT = 1,@RunType INT = 0,@if_Date AS DATETIME = GETDATE(),@OdsCustomerID INT = 62
DECLARE  @SQLScript VARCHAR(MAX);

SET @SQLScript = '
DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;

'+CHAR(13)+CHAR(10)+
-- Clean up stsging table for adjustments
CASE WHEN @OdsCustomerID <> 0 THEN 'DELETE FROM stg.DP_PerformanceReport_3rdParty_Adjustments WHERE OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(5))+';'
ELSE 'TRUNCATE TABLE stg.DP_PerformanceReport_3rdParty_Adjustments;' END +'

-- Insert Adjustments data into staging table
;WITH cte_Rsn_Override AS ( 
SELECT OdsCustomerId,
	   ReasonNumber,
       ShortDesc,
       LongDesc
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Rsn_Override' ELSE 'if_Rsn_Override(@RunPostingGroupAuditId)' END+'
UNION ALL
SELECT CustomerId,
	0,
    ''No endnote given'',
    ''No endnote given''
FROM '+@SourceDatabaseName+'.adm.Customer
WHERE IsActive = 1),

-- Adjustment360OverrideEndNoteSubCategory
cte_Adjustment360OverrideEndNoteSubCategory AS(
SELECT OdsCustomerId,
	   ReasonNumber,
       SubCategoryId
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Adjustment360OverrideEndNoteSubCategory' ELSE 'if_Adjustment360OverrideEndNoteSubCategory(@RunPostingGroupAuditId)' END+'
UNION ALL
SELECT CustomerId,
	0,
    6
FROM '+@SourceDatabaseName+'.adm.Customer
WHERE IsActive = 1),

-- Let''s grab the latest description UB_APC_DICT
cte_UB_APC_DICT AS(
SELECT  OdsCustomerId,
		APC,
        MAX(EndDate) AS EndDate
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'UB_APC_DICT' ELSE 'if_UB_APC_DICT(@RunPostingGroupAuditId)' END+' rs
GROUP BY APC,OdsCustomerId),

-- Get Endnote and Descriptions
cte_EndNoteDescriptions AS (
SELECT  rs.OdsCustomerId,
		rs.ReasonNumber AS Endnote,
        rs.ShortDesc AS ShortDescription,
        rs.LongDesc AS LongDescription,
        1 AS EndnoteTypeId,
        sc.SubCategoryId AS Adjustment360SubCategoryId
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'rsn_REASONS' ELSE 'if_rsn_REASONS(@RunPostingGroupAuditId)' END+' rs 
LEFT JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Adjustment360EndNoteSubCategory' ELSE 'if_Adjustment360EndNoteSubCategory(@RunPostingGroupAuditId)' END+' sc
ON rs.OdsCustomerId = sc.OdsCustomerId AND rs.ReasonNumber = sc.ReasonNumber 
UNION ALL
SELECT  OdsCustomerId,
		rs.RuleID,
        rs.EndnoteShort,
        rs.EndnoteLong,
        2 AS EndNoteTypeId, 
        15 AS SubCategoryId
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'SENTRY_RULE_ACTION_HEADER' ELSE 'if_SENTRY_RULE_ACTION_HEADER(@RunPostingGroupAuditId)' END+' rs
--UNION ALL
--SELECT rs.OdsCustomerId
--		 rs.Endnote,
--       rs.ShortDesc,
--       rs.LongDesc,
--       3 AS EndNoteTypeId, 
--       7 AS SubCategoryId
--FROM dbo.CTG_Endnotes rs
UNION ALL
SELECT  rs.OdsCustomerId,
		rs.ReasonNumber,
        rs.ShortDesc,
        rs.LongDesc,
        4 AS EndNoteTypeId, 
        sc.SubCategoryId
FROM  cte_Rsn_Override rs
LEFT JOIN  cte_Adjustment360OverrideEndNoteSubCategory sc
ON rs.OdsCustomerId = sc.OdsCustomerId AND rs.ReasonNumber = sc.ReasonNumber
UNION ALL
SELECT  rs.OdsCustomerId,
		rs.APC,
        rs.Description,
        rs.Description,
        5 AS EndNoteTypeId, 
        sc.SubCategoryId
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'UB_APC_DICT' ELSE 'if_UB_APC_DICT(@RunPostingGroupAuditId)' END+' rs
INNER JOIN cte_UB_APC_DICT rs1
ON rs.OdsCustomerId = rs1.OdsCustomerId AND rs1.APC = rs.APC
    AND rs1.EndDate = rs.EndDate
LEFT JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Adjustment360ApcEndNoteSubCategory' ELSE 'if_Adjustment360ApcEndNoteSubCategory(@RunPostingGroupAuditId)' END+' sc
ON rs.OdsCustomerId = sc.OdsCustomerId AND rs.APC = sc.ReasonNumber 
--UNION ALL
--SELECT rs.OdsCustomerId,
--		 rs.ReasonNumber,
--       rs.ShortDesc,
--       rs.LongDesc,
--       6 AS EndNoteTypeId, 
--       sc.SubCategoryId
--FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Rsn_Reasons_3rdParty' ELSE 'if_Rsn_Reasons_3rdParty(@RunPostingGroupAuditId)' END+' rs
--LEFT JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Adjustment3603rdPartyEndNoteSubCategory' ELSE 'if_Adjustment3603rdPartyEndNoteSubCategory(@RunPostingGroupAuditId)' END+' sc
--ON rs.OdsCustomerId = sc.OdsCustomerId AND rs.ReasonNumber = sc.ReasonNumber 
    
)

SELECT I.OdsCustomerId
	,I.billIDNo
	,I.line_no
	,I.line_type
	,I.Coverage
	,A.EndNoteTypeId
	,I.charged
	,I.allowed
	,CASE WHEN AC.Adjustment360CategoryId = 1  THEN A.Adjustment ELSE 0.00 END AS ''Standard''
	,CASE WHEN AC.Adjustment360CategoryId = 2  THEN A.Adjustment ELSE 0.00 END AS ''Premium''
	,CASE WHEN AC.Adjustment360CategoryId = 3  THEN A.Adjustment ELSE 0.00 END AS ''FeeSchedule''
	,CASE WHEN AC.Adjustment360CategoryId = 4  THEN A.Adjustment ELSE 0.00 END AS ''Benchmark''
	,CASE WHEN AC.Adjustment360CategoryId = 5  THEN A.Adjustment ELSE 0.00 END AS ''VPN''
	,CASE WHEN AC.Adjustment360CategoryId = 6  THEN A.Adjustment ELSE 0.00 END AS ''Override''
	,I.ReportType
INTO #DP_PerformanceReport_3rdParty_Adjustments
FROM stg.DP_PerformanceReport_Input I
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BillAdjustment' ELSE 'if_BillAdjustment(@RunPostingGroupAuditId)' END+' A
ON I.OdsCustomerId = A.OdsCustomerId
	AND I.billIDNo = A.BillIdNo
	AND I.line_no = A.LineNumber
LEFT OUTER JOIN   cte_EndNoteDescriptions R
ON  A.OdsCustomerId = R.OdsCustomerId
	AND A.EndNote = R.Endnote
	AND A.EndNoteTypeId = R.EndnoteTypeId
-- Let''s create our AdjustmentSubCategory lookup. 
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Adjustment360SubCategory' ELSE 'if_Adjustment360SubCategory(@RunPostingGroupAuditId)' END+' A3S
    ON R.OdsCustomerId = A3S.OdsCustomerId
	AND R.Adjustment360SubCategoryId = A3S.Adjustment360SubCategoryId
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Adjustment360Category' ELSE 'if_Adjustment360Category(@RunPostingGroupAuditId)' END+' AC
    ON A3S.OdsCustomerId = AC.OdsCustomerId
	AND A3S.Adjustment360CategoryId = AC.Adjustment360CategoryId
'+
CASE WHEN @OdsCustomerID <> 0 THEN 
CHAR(13)+CHAR(10)+'WHERE I.OdsCustomerId = '+CAST(@OdsCustomerID AS VARCHAR(5)) ELSE '' END +';

INSERT INTO stg.DP_PerformanceReport_3rdParty_Adjustments(
	   OdsCustomerId
      ,billIDNo
      ,line_no
      ,line_type
      ,Standard
      ,Premium
      ,FeeSchedule
      ,Benchmark
      ,VPN
      ,Override
	  ,ReportType
      ,RunDate)
SELECT 
	 OdsCustomerId
	,billIDNo
	,line_no
	,line_type
	,SUM(Standard) AS ''Standard''
	,SUM(Premium) AS  ''Premium''
	,SUM(FeeSchedule) AS  ''FeeSchedule''
	,SUM(Benchmark) AS  ''Benchmark''
	,SUM(VPN) AS ''VPN''
	,SUM(Override) AS ''Override''
	,ReportType
	,GETDATE() AS RunDate
FROM #DP_PerformanceReport_3rdParty_Adjustments I
GROUP BY  OdsCustomerId
	,billIDNo
	,line_no
	,line_type
	,ReportType'

EXEC (@SQLScript)

END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.DP_PerformanceReport_3rdParty_Data') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.DP_PerformanceReport_3rdParty_Data
GO


CREATE PROCEDURE dbo.DP_PerformanceReport_3rdParty_Data (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@StartDate AS DATETIME,
@EndDate AS DATETIME,
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@ReportId INT = 1,
@ReportType INT = 1,
@OdsCustomerId INT = 0)
AS
BEGIN

-- Setup Run parameters
-- DECLARE @SourceDatabaseName VARCHAR(50)='AcsOdsDemo',@StartDate AS DATETIME = '19000101',@EndDate AS DATETIME = '20191231',@RunType INT = 0,@if_Date AS DATETIME = GETDATE(),@ReportId INT = 1,@ReportType INT = 4,@OdsCustomerId INT = 0;

DECLARE  @SQLScript VARCHAR(MAX)
		,@WhereClause VARCHAR(MAX);

-- Build Where clause to be used only when Claimant report or Bill Header Createdate report		

SET @SQLScript = '
DECLARE  @returnstatus INT
DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;

'+
CASE WHEN @OdsCustomerID <> 0 THEN '
EXEC adm.Rpt_CreateUnpartitionedTableSchema '+CAST(@OdsCustomerId AS VARCHAR(3))+',16,1,@returnstatus;
EXEC adm.Rpt_CreateUnpartitionedTableIndexes '+CAST(@OdsCustomerId AS VARCHAR(3))+',16,@returnstatus;
EXEC adm.Rpt_SwitchUnpartitionedTable '+CAST(@OdsCustomerId AS VARCHAR(3))+',16,'''',1,@returnstatus;

DROP TABLE stg.DP_PerformanceReport_Input_Unpartitioned;' 

ELSE '
TRUNCATE TABLE stg.DP_PerformanceReport_Input;' END+'

--Test: SELECT @start_dt,@end_dt

--Get Primary Diagnosis Code From CMT_DX table
IF OBJECT_ID(''tempdb..#Diagnosis'') IS NOT NULL DROP TABLE #Diagnosis;  /*Get Diagnosis Code*/
SELECT OdsCustomerId,BillIDNo,DX
INTO #Diagnosis
FROM (
SELECT C.OdsCustomerId
	,C.BillIDNo
	,C.DX
	, ROW_NUMBER() Over (Partition By OdsCustomerId,BillIDNo ORDER By SeqNum asc) Rnk
FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CMT_DX' ELSE 'if_CMT_DX(@RunPostingGroupAuditId)' END + ' C
'+CASE WHEN @OdsCustomerId <> 0 THEN 'WHERE C.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +' 
)X WHERE Rnk = 1;

--Get Provider Data into temp table
IF OBJECT_ID(''tempdb..#Provider'') IS NOT NULL DROP TABLE #Provider; 
SELECT DISTINCT 
	 OdsCustomerId
	,PvdIDNo
	,PvdSPC_List
	,Case WHEN SUBSTRING(PvdSPC_List,0,Charindex('':'',PvdSPC_List)) = ''XX'' THEN ''UNK''
				When PvdSPC_List LIKE ''%:%'' AND (LTRIM(RTRIM(PvdSPC_List)) LIKE ''%Unknown%'' OR LTRIM(RTRIM(PvdSPC_List)) = '''' OR LTRIM(RTRIM(PvdSPC_List)) IS NULL) Then ''UNK''
				When PvdSPC_List LIKE ''%:%'' Then SUBSTRING(PvdSPC_List,0,Charindex('':'',PvdSPC_List))
				When LTRIM(RTRIM(PvdSPC_List)) = '','' OR  LTRIM(RTRIM(PvdSPC_List)) IS NULL OR LTRIM(RTRIM(PvdSPC_List)) = '''' OR LTRIM(RTRIM(PvdSPC_List)) LIKE ''%Unknown%'' OR LTRIM(RTRIM(PvdSPC_List)) =''XX'' THEN ''UNK''
				Else PvdSPC_List End AS ProviderSpecialty
INTO #Provider
FROM '+@SourceDatabaseName+'.dbo.'+ CASE WHEN @RunType = 0 THEN 'PROVIDER' ELSE 'if_PROVIDER(@RunPostingGroupAuditId)' END +
CASE WHEN @OdsCustomerId <> 0 THEN ' WHERE  OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +  
'

CREATE NONCLUSTERED INDEX idx_Pvd ON #Provider(OdsCustomerId,PvdIDNo); 

-- Get Bills of interest
IF OBJECT_ID(''tempdb..#BILL_HDR'') IS NOT NULL DROP TABLE #BILL_HDR
SELECT DISTINCT
	 BH.OdsCustomerId
	,BH.BillIDNo
	,BH.CMT_HDR_IDNo	
	,CONVERT(VARCHAR(8),BH.CreateDate,112) AS CreateDateformated
	,BH.CreateDate
	,CASE WHEN BH.Flags & 4096 > 0 THEN ''UB-04''  ELSE ''CMS-1500''  END AS Form_Type
	,ISNULL(d.DX,-1) AS DiagnosisCode
	,BH.TypeOfBill
	,LEFT(BH.PvdZOS,5) as ProviderZipOfService
INTO #BILL_HDR
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BILL_HDR' ELSE 'if_BILL_HDR(@RunPostingGroupAuditId)' END+' BH
LEFT OUTER JOIN #Diagnosis d ON BH.OdsCustomerId = d.OdsCustomerId
	AND BH.BillIDNo = d.BillIDNo
WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN ' BH.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))ELSE '' END+
	CASE WHEN @ReportType = 1 THEN CASE WHEN @OdsCustomerId <> 0 THEN  CHAR(13)+CHAR(10)+CHAR(9)+'AND' ELSE '' END + ' CONVERT(VARCHAR(10),BH.CreateDate,112) BETWEEN '''+CONVERT(VARCHAR(10),@StartDate,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+'''' ELSE '' END+
	CASE WHEN @OdsCustomerId <> 0 OR @ReportType = 1 THEN CHAR(13)+CHAR(10)+CHAR(9)+'AND' ELSE '' END +' BH.Flags & 16 = 0;'+
-- Get the First Bill Create date and Apply across all the other bills
CASE WHEN @ReportType IN (1,5) THEN '

IF OBJECT_ID(''tempdb..#BILLCreated'') IS NOT NULL DROP TABLE #BILLCreated
SELECT  BH.OdsCustomerId
	,CH.CmtIDNo
	,'+CASE WHEN @ReportType = 1 THEN 'MIN' ELSE 'MAX' END+'(BH.CreateDate) BillCreateDate
INTO #BILLCreated
FROM #BILL_HDR BH
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CMT_HDR' ELSE'if_CMT_HDR(@RunPostingGroupAuditId)' END+' CH 
	ON BH.OdsCustomerId = CH.OdsCustomerId
	AND BH.CMT_HDR_IDNo = CH.CMT_HDR_IDNo
GROUP BY BH.OdsCustomerId
	,CH.CmtIDNo;' ELSE '' END +

CASE WHEN @ReportType = 4 THEN '

-- Get MitchellCompleteDate Claimants
IF OBJECT_ID(''tempdb..#MitchellCompleteDateClaimants'') IS NOT NULL DROP TABLE #MitchellCompleteDateClaimants
SELECT   OdsCustomerId
		,CmtIdNo
		,Max(UDFValueDate) MitchellCmptDate
INTO #MitchellCompleteDateClaimants
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'UDFClaimant' ELSE'if_UDFClaimant(@RunPostingGroupAuditId)' END+'
WHERE UDFIdNo IN (''-3'',''-4'',''5'')'+
CASE WHEN @OdsCustomerId <> 0 THEN CHAR(13)+CHAR(10)+CHAR(9)+'AND OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +'
GROUP BY OdsCustomerId
		,CmtIdNo
HAVING CONVERT(VARCHAR(10),Max(UDFValueDate),112) BETWEEN '''+CONVERT(VARCHAR(10),@StartDate,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+''''
ELSE '' END +'
	
--Add Lines, Claim and Claimant level InfO.
INSERT INTO stg.DP_PerformanceReport_Input(
		 OdsCustomerId
		,BillIDNo
		,CreateDate
		,Form_Type
		,ProviderZipOfService
		,TypeOfBill
		,DiagnosisCode
		,CompanyID
		,Company
		,OfficeID
		,Office
		,Coverage
		,ClaimNo
		,ClaimIDNo
		,CmtIDNO
		,SOJ
		,ProcedureCode
		,ProviderSpecialty
		,ProviderType
		,ProviderType_Desc
		,LINE_NO_DISP
		,LINE_NO
		,REF_LINE_NO
		,Line_Type
		,OVER_RIDE
		,CHARGED
		,ALLOWED
		,PreApportionedAmount
		,ANALYZED
		,UNITS
		,ReportType
)
SELECT   BH.OdsCustomerId
		,BH.BillIDNo
		,'+CASE WHEN @ReportType IN (1,5) THEN 'BFCD.BillCreateDate' 
				WHEN @ReportType = 2 THEN 'CL.DateLoss'
				WHEN @ReportTYpe = 3 THEN 'CL.CreateDate' 
				WHEN @ReportType = 4 THEN 'MCD.MitchellCmptDate'
				ELSE 'BH.CreateDate' END+'
		,BH.Form_Type
		,BH.ProviderZipOfService
		,BH.TypeOfBill
		,BH.DiagnosisCode
		,CL.CompanyID
		,ISNULL(CO.CompanyName, ''NA'') AS Company
		,CL.OfficeIndex
		,ISNULL(O.OfcName, ''NA'') AS Office
		,CL.CV_Code
		,CL.ClaimNo
		,CL.ClaimIDNo
		,CM.CmtIDNo
		,CM.CmtStateOfJurisdiction
		,B.PRC_CD AS ProcedureCode
		,P.ProviderSpecialty
		,ISNULL(SR.ProviderType,''UNK'') ProviderType
		,ISNULL(SR.ProviderType_Desc,''UNKNOWN'')  ProviderType_Desc
		,B.LINE_NO_DISP
		,B.LINE_NO
		,B.REF_LINE_NO
		,B.LineType
		,B.OVER_RIDE
		,B.CHARGED
		,B.ALLOWED
		,B.PreApportionedAmount
		,B.ANALYZED
		,B.UNITS
		,'+CAST(@ReportType AS VARCHAR(1))+'
FROM #BILL_HDR BH
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CMT_HDR' ELSE'if_CMT_HDR(@RunPostingGroupAuditId)' END+' CH 
	ON BH.OdsCustomerId = CH.OdsCustomerId
	AND BH.CMT_HDR_IDNo = CH.CMT_HDR_IDNo
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CLAIMANT' ELSE'if_CLAIMANT(@RunPostingGroupAuditId)' END+' CM 
	ON CH.OdsCustomerId = CM.OdsCustomerId
	AND CH.CmtIDNo = CM.CmtIDNo'+
CASE WHEN @ReportType IN (1,5) THEN '
INNER JOIN #BILLCreated BFCD
	ON CM.OdsCustomerId = BFCD.OdsCustomerId
	AND CM.CmtIDNo = BFCD.CmtIDNo' ELSE '' END +
CASE WHEN @ReportType = 4 THEN '
INNER JOIN #MitchellCompleteDateClaimants MCD
	ON CM.OdsCustomerId = MCD.OdsCustomerId
	AND CM.CmtIDNo = MCD.CmtIDNo' ELSE '' END +'
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CLAIMS' ELSE'if_CLAIMS(@RunPostingGroupAuditId)' END+' CL 
	ON  CM.OdsCustomerId = CL.OdsCustomerId
	AND CM.ClaimIDNo  = CL.ClaimIDNo
	AND CL.ClaimNo NOT LIKE ''%TEST%''
	AND(CL.OdsCustomerId NOT IN (70,71) OR CL.Status <> ''C'')'+
	CASE WHEN @ReportType = 3 THEN CHAR(13)+CHAR(10)+CHAR(9)+'AND CONVERT(VARCHAR(10),CL.CreateDate,112) BETWEEN '''+CONVERT(VARCHAR(10),@StartDate,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+'''' ELSE '' END +
	CASE WHEN @ReportType = 2 THEN CHAR(13)+CHAR(10)+CHAR(9)+'AND CONVERT(VARCHAR(10),CL.DateLoss,112) BETWEEN '''+CONVERT(VARCHAR(10),@StartDate,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+'''' ELSE '' END +'
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'prf_COMPANY' ELSE'if_prf_COMPANY(@RunPostingGroupAuditId)' END+' CO 
	ON CO.OdsCustomerId = CL.OdsCustomerId
	AND CO.CompanyID = CL.CompanyID
	AND CO.CompanyName NOT LIKE ''%TEST%''
	AND CO.CompanyName NOT LIKE ''%TRAIN%''	
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'prf_Office' ELSE'if_prf_Office(@RunPostingGroupAuditId)' END+' O 
	ON O.OdsCustomerId = CL.OdsCustomerId
	AND O.OfficeID = CL.OfficeIndex
	AND O.OfcName NOT LIKE ''%TEST%''
	AND O.OfcName NOT LIKE ''%TRAIN%''
INNER JOIN (SELECT
				 OdsCustomerId 
				,BillIDNo
				,LINE_NO_DISP
				,LINE_NO
				,REF_LINE_NO
				,1 AS LineType
				,PRC_CD
				,OVER_RIDE
				,ISNULL(CHARGED, 0) CHARGED
				,ISNULL(ALLOWED, 0) ALLOWED
				,PreApportionedAmount
				,ISNULL(ANALYZED, 0) ANALYZED
				,ISNULL(UNITS, 0) UNITS
			FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BILLS' ELSE'if_BILLS(@RunPostingGroupAuditId)' END+' 
			WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN 'OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ' ELSE '' END +'CHARGED IS NOT NULL
			
			UNION 
			
			SELECT 
				 OdsCustomerId
				,BillIDNo
				,LINE_NO_DISP
				,LINE_NO
				,0
				,2 AS LineType
				,NDC
				,Override
				,ISNULL(CHARGED, 0) CHARGED
				,ISNULL(ALLOWED, 0) ALLOWED
				,PreApportionedAmount
				,ISNULL(ANALYZED, 0) ANALYZED
				,ISNULL(UNITS, 0) UNITS
			FROM  '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BILLS_Pharm' ELSE'if_BILLS_Pharm(@RunPostingGroupAuditId)' END+'
			WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN 'OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ' ELSE '' END +'CHARGED IS NOT NULL
			) AS B
	ON BH.OdsCustomerId = B.OdsCustomerId
	AND BH.BillIDNo = B.BillIDNo
LEFT OUTER JOIN #Provider P
	ON  P.OdsCustomerId = CH.OdsCustomerId
	AND P.PvdIDNo = CH.PvdIDNo 
LEFT OUTER JOIN  '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'ProviderSpecialtyToProvType' ELSE'if_ProviderSpecialtyToProvType(@RunPostingGroupAuditId)' END+' SR
	ON P.ProviderSpecialty = SR.Specialty;'
				
EXEC (@SQLScript);

END 

GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.DP_PerformanceReport_3rdParty_GreenwichData') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.DP_PerformanceReport_3rdParty_GreenwichData
GO


CREATE PROCEDURE dbo.DP_PerformanceReport_3rdParty_GreenwichData(
@SourceDatabaseName VARCHAR(50) = 'AcsOds',
@TargetDatabaseName VARCHAR(50) = 'ReportDB')
AS
BEGIN
DECLARE @SQLQuery VARCHAR(MAX) = '

DELETE FROM  '+@TargetDatabaseName+'.dbo.DP_PerformanceReport_3rdParty_Output
WHERE Customer = ''Greenwich'';

INSERT INTO  '+@TargetDatabaseName+'.dbo.DP_PerformanceReport_3rdParty_Output
SELECT 0 AS OdsCustomerId
	,StartOfMonth
	,''Greenwich'' Customer
	,Year
	,Month
	,''Company1'' Company
	,''Office1'' Office
	,SOJ
	,Coverage
	,Form_Type
	,ClaimIDNo
	,CmtIDNo
	,SUM(Total_Claims)
	,SUM(Total_Claimants)
	,SUM(Total_Bills)
	,SUM(Total_Lines)
	,SUM(Total_Units)
	,SUM(Total_Provider_Charges)
	,SUM(Total_Final_Allowed)
	,SUM(Total_Reductions)
	,SUM(Total_BillAdjustments)
	,SUM(Standard) AS Standard
	,SUM(Premium) AS Premium
	,SUM(FeeSchedule) AS FeeSchedule
	,SUM(Benchmark) AS Benchmark
	,SUM(VPN) AS VPN
	,SUM(Override) AS Override
	,ReportTypeID
	,GETDATE()
FROM '+@TargetDatabaseName+'.dbo.DP_PerformanceReport_3rdParty_Output
WHERE   Customer IN ( ''FBFS'', ''Sentry'', ''BristolWest'',''OneBeacon'')
GROUP BY StartOfMonth
	,Year  ,Month
	,SOJ
	,Coverage
	,Form_Type
	,ClaimIDNo
	,CmtIDNo
	,ReportTypeID;'

EXEC (@SQLQuery);
END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.DP_PerformanceReport_3rdParty_Rollup') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.DP_PerformanceReport_3rdParty_Rollup
GO

CREATE PROCEDURE dbo.DP_PerformanceReport_3rdParty_Rollup(
@SourceDatabaseName VARCHAR(50)='AcsOds',
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@ReportType INT = 1,
@OdsCustomerID INT = 0,
@TargetDatabaseName VARCHAR(50) = 'ReportDB')
AS
BEGIN
	--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@ReportType INT = 3,@RunType INT = 0,@if_Date AS DATETIME = GETDATE(), @OdsCustomerID INT = 0
	DECLARE @SQLScript VARCHAR(MAX);
		
	SET @SQLScript = '
	DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;

	DELETE FROM '+@TargetDatabaseName+'.dbo.DP_PerformanceReport_3rdParty_Output
	WHERE ReportTypeID  = '+CAST(@ReportType AS VARCHAR(2))+CASE WHEN @OdsCustomerID <> 0 THEN ' AND OdsCustomerId = '+CAST(@OdsCustomerID as VARCHAR(5)) ELSE '' END +';
										
	SELECT m.OdsCustomerId
		,DATEADD(MONTH, DATEDIFF(MONTH, 0, m.CreateDate), 0) AS StartOfMonth
		,C.CustomerName AS Customer
		,YEAR(m.CreateDate) AS Year
		,MONTH(m.CreateDate) AS Month
		,ISNULL(m.Company, ''NA'') AS Company
		,ISNULL(m.Office, ''NA'') AS Office
		,ISNULL(m.SOJ, ''NA'') AS SOJ
		,ISNULL(m.Coverage, ''NA'') AS Coverage
		,ISNULL(m.Form_Type, ''NA'') AS Form_Type
		,m.claimNo
		,m.ClaimIDNo
		,m.CmtIDNo
		,m.billIDNo
		,m.line_no
		,m.units
		,m.charged
		,ISNULL(m.PreApportionedAmount,m.allowed) allowed
		,r.Standard
		,r.Premium
		,r.FeeSchedule
		,r.Benchmark
		,r.VPN
		,r.Override
		,r.ReportType

	INTO #DP_PerformanceReport_3rdParty_rollup
	FROM stg.DP_PerformanceReport_Input m
	INNER JOIN stg.DP_PerformanceReport_3rdParty_Adjustments r ON m.OdsCustomerId = r.OdsCustomerId
		AND m.billIDNo = r.billIDNo
		AND m.line_no = r.line_no
		AND m.ReportType = r.ReportType
	INNER JOIN '+@SourceDatabaseName+'.adm.Customer C
		ON m.OdsCustomerId = c.CustomerId
	LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CustomerBillExclusion' ELSE'if_CustomerBillExclusion(@RunPostingGroupAuditId)' END+' ex 
		ON C.CustomerDatabase = ex.Customer
		AND m.billIDNo = ex.billIDNo
		AND ex.ReportID = 8
	
	WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN ' m.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ' ELSE '' END +'ex.billIDNo IS NULL;
		
	CREATE CLUSTERED INDEX Idx_CustomerIdBillIdNoLineNoLineType 
	ON #DP_PerformanceReport_3rdParty_rollup(OdsCustomerId,StartOfMonth,Customer,Year,Month,Company,Office,SOJ,Coverage,Form_Type)
	WITH (DATA_COMPRESSION = PAGE);
		
	
	INSERT INTO '+@TargetDatabaseName+'.dbo.DP_PerformanceReport_3rdParty_Output(
	   OdsCustomerId
      ,StartOfMonth
      ,Customer
      ,Year
      ,Month
      ,Company
      ,Office
      ,SOJ
      ,Coverage
      ,Form_Type
	  ,ClaimIDNo
	  ,CmtIDNo
	  ,Total_Claims
      ,Total_Claimants
      ,Total_Bills
      ,Total_Lines
      ,Total_Units
      ,Total_Provider_Charges
      ,Total_Final_Allowed
      ,Total_Reductions
      ,Total_BillAdjustments
      ,Standard
      ,Premium
      ,FeeSchedule
      ,Benchmark
      ,VPN
      ,Override
      ,ReportTypeID
      ,RunDate)
	SELECT
		 OdsCustomerId
		,StartOfMonth
		,Customer
		,Year
		,Month
		,Company
		,Office
		,SOJ
		,Coverage
		,Form_Type
		,ClaimIDNo
		,CmtIDNo
		,COUNT(DISTINCT claimNo) Total_Claims
		,COUNT(DISTINCT CmtIDNo) Total_Claimants
		,COUNT(DISTINCT billIDNo) Total_Bills
		,COUNT(line_no) Total_Lines
		,SUM(units) Total_Units
		,SUM(charged) Total_Provider_Charges
		,SUM(allowed) Total_Final_Allowed
		,SUM(charged) - SUM(allowed) Total_Reductions
		,SUM(Standard)
			+SUM(Premium)
			+SUM(FeeSchedule)
			+SUM(Benchmark)
			+SUM(VPN)
			+SUM(Override) Total_BillAdjustments
		,SUM(Standard) AS Standard
		,SUM(Premium) AS Premium
		,SUM(FeeSchedule) AS FeeSchedule
		,SUM(Benchmark) AS Benchmark
		,SUM(VPN) AS VPN
		,SUM(Override) AS Override
		,ReportType
		,GETDATE() AS RunDate
	
	FROM #DP_PerformanceReport_3rdParty_rollup R1
	GROUP BY OdsCustomerId
		,StartOfMonth
		,Customer
		,Year
		,Month
		,Company
		,Office
		,SOJ
		,Coverage
		,Form_Type
		,ReportType
		,ClaimIDNo
		,CmtIDNo
	OPTION (HASH GROUP);'
		
	EXEC (@SQLScript);	
	
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.ERDReport_Output') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ERDReport_Output
GO

CREATE PROCEDURE dbo.ERDReport_Output (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@StartDate AS DATETIME,
@EndDate AS DATETIME,
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@ReportID INT,
@OdsCustomerId INT = 0,
@TargetDatabaseName VARCHAR(50) = 'ReportDB')
AS
BEGIN


--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@StartDate AS DATETIME = '2012-01-01',@EndDate AS DATETIME = '2016-12-31',RunType INT = 0,@if_Date AS DATETIME = NULL,@ReportID INT = 6,@OdsCustomerId INT = 82;

DECLARE @SQLScript VARCHAR(MAX) 

SET @SQLScript = CAST ('' AS VARCHAR(MAX)) + '
DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;

'+CASE WHEN @OdsCustomerID <> 0 THEN 
'DELETE FROM '+@TargetDatabaseName+'.dbo.ERDReport
WHERE OdsCustomerId = '+CAST(@OdsCustomerID as VARCHAR(5))+';' ELSE 

'TRUNCATE TABLE '+@TargetDatabaseName+'.dbo.ERDReport;' END+'

--1) Get Bill Exclusion Info
IF OBJECT_ID(''tempdb..#Outlier'') IS NOT NULL DROP TABLE #Outlier;
SELECT C.CustomerId
	,B.BillIdNo
INTO #Outlier
FROM '+@SourceDatabaseName+'.adm.Customer C
JOIN  '+@SourceDatabaseName+'.dbo.CustomerBillExclusion B
ON C.CustomerDatabase = B.Customer
Where B.ReportID = ' + CAST (@ReportID as Varchar(2))  + 


--2) Get Claims info
'
IF OBJECT_ID(''tempdb..#CLAIMS'') IS NOT NULL DROP TABLE #CLAIMS;  
SELECT OdsCustomerId
	,ClaimIDNo
	,ClaimNo
	,CV_Code
	,DateLoss
	,CompanyID
	,OfficeIndex
	,AdjIdNo
	,[Status]  --24 sec
INTO #CLAIMS
FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CLAIMS' ELSE 'if_CLAIMS(@RunPostingGroupAuditId)' END + ' CL 
WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN 'CL.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) + ' AND ' ELSE '' END +' 
       CONVERT(VARCHAR(10),CL.DateLoss,112) BETWEEN '''+CONVERT(VARCHAR(10),@StartDate,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+'''

CREATE CLUSTERED INDEX cidx_CustIdClaimIdNo ON #CLAIMS
(OdsCustomerId,ClaimIDNo)

 ' +

--3) Get Bill_Hdr info
'

IF OBJECT_ID(''tempdb..#BILL_HDR'') IS NOT NULL DROP TABLE #BILL_HDR;    
SELECT BH.OdsCustomerId
	,BH.BillIDNo
	,BH.CMT_HDR_IDNo
	,ClaimDateLoss
	,CH.CmtIDNo
	,BH.Flags & 16 AS Migrated
	,BH.AmtAllowed
	,BH.AmtCharged  --2min
INTO #BILL_HDR
FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'BILL_HDR' ELSE 'if_BILL_HDR(@RunPostingGroupAuditId)' END + ' BH
INNER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CMT_HDR' ELSE 'if_CMT_HDR(@RunPostingGroupAuditId)' END + ' CH
ON CH.OdsCustomerID = BH.OdsCustomerID 
    AND BH.CMT_HDR_IDNo = CH.CMT_HDR_IDNo
LEFT JOIN #Outlier O
	ON BH.OdsCustomerId = O.CustomerId
	AND BH.billIDNo = O.BillIdNo
WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN 'BH.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) + ' AND ' ELSE '' END +'
       CONVERT(VARCHAR(10),BH.CreateDate,112) > '''+CONVERT(VARCHAR(10),@StartDate,112)+''' AND O.CustomerId IS NULL

CREATE NONCLUSTERED INDEX nidx_CustIdCmtIDNoBillIDNo 
ON #BILL_HDR(OdsCustomerId,CmtIDNo,BillIDNo) 
INCLUDE(AmtAllowed,AmtCharged)

--4) Get Duration and InjuryType Info 

IF OBJECT_ID(''tempdb..#InjuryNature'') IS NOT NULL DROP TABLE #InjuryNature;    
SELECT DISTINCT OdsCustomerId
	,CmtIDNo
	,Duration
	,InjuryNatureId
	,InjuryNatureDesc
INTO #InjuryNature
FROM (
SELECT cdx.OdsCustomerId
	,BH.CmtIDNo
	,cdx.BillIDNo
	,dx.DiagnosisCode
	,ISNULL(dx.Duration,0) Duration
	,ISNULL(I.InjuryNatureId,99) InjuryNatureId
	,ISNULL(I.[Description],''Unknown'') InjuryNatureDesc
	,I.InjuryNaturePriority
	,ROW_NUMBER() OVER (PARTITION BY cdx.OdsCustomerId,bh.CmtIDNo ORDER BY ISNULL(dx.Duration,0) desc,InjuryNaturePriority desc) rnk 
FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CMT_DX' ELSE 'if_CMT_DX(@RunPostingGroupAuditId)' END + ' cdx  
INNER JOIN #BILL_HDR BH
     ON  BH.OdsCustomerID = cdx.OdsCustomerID
	AND BH.BillIDNo = cdx.BillIDNo
LEFT JOIN (
     SELECT 
	    OdsCustomerID,
		ICD9 AS DiagnosisCode,
		Duration,
		9 AS IcdVersion
	FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'cpt_DX_DICT' ELSE 'if_cpt_DX_DICT(@RunPostingGroupAuditId)' END +  
	CASE WHEN @OdsCustomerId <> 0 THEN ' WHERE OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3))  ELSE '' END + ' 
	
	UNION ALL
	
	SELECT 
	    OdsCustomerID,
		DiagnosisCode,
		Duration,
		10 AS IcdVersion
    FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'Icd10DiagnosisVersion' ELSE 'if_Icd10DiagnosisVersion(@RunPostingGroupAuditId)' END + 
    CASE WHEN @OdsCustomerId <> 0 THEN ' WHERE OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3))  ELSE '' END + ' 
)dx
    ON  dx.OdsCustomerID = cdx.ODSCustomerID
    AND dx.DiagnosisCode = cdx.dx
    AND dx.IcdVersion = cdx.IcdVersion  
LEFT JOIN (   SELECT OdsCustomerId, DiagnosisCode, IcdVersion, InjuryNatureId
		    FROM (
		    SELECT OdsCustomerId
				, DiagnosisCode
				, IcdVersion
				, InjuryNatureId
				,ROW_NUMBER() OVER (PARTITION BY OdsCustomerId, DiagnosisCode, IcdVersion ORDER BY EndDate DESC) rnk
		    FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'IcdDiagnosisCodeDictionary' ELSE 'if_IcdDiagnosisCodeDictionary(@RunPostingGroupAuditId)' END + 
                     CASE WHEN @OdsCustomerId <> 0 THEN ' WHERE OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3))  ELSE '' END + '
		) X WHERE rnk = 1) dict
    ON dx.OdsCustomerId = dict.OdsCustomerId
    AND dx.DiagnosisCode = dict.DiagnosisCode
    AND dx.IcdVersion = dict.IcdVersion
LEFT JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'InjuryNature' ELSE 'if_InjuryNature(@RunPostingGroupAuditId)' END + ' I 
    ON dict.OdsCustomerId = I.OdsCustomerId
    AND dict.InjuryNatureId = I.InjuryNatureId
) X WHERE rnk = 1;


CREATE NONCLUSTERED INDEX nidx_CustIdCmtIDNo ON #InjuryNature
(OdsCustomerId,CmtIDNo) INCLUDE (Duration,InjuryNatureId,InjuryNatureDesc)

--5)Insert Results

IF OBJECT_ID(''tempdb..#temp'') IS NOT NULL DROP TABLE #temp;    
SELECT BH.OdsCustomerId,
      D.CustomerName AS CustomerName,
      CL.ClaimIDNo,
	  CL.ClaimNo,
      CM.CmtIDNo,
	  BH.BillIDNo,
	  B.LINE_NO,
	  CL.CV_Code,
	  CV.LongName CoverageTypeDesc,
	  Z.County,
      CM.CmtStateOfJurisdiction SOJ,
	  ISNULL(Co.CompanyName,''Unknown'') CompanyName,
	  ISNULL(O.OfcName,''Unknown'') OfcName,
	  AD.FirstName as AdjustorFirstName,
	  AD.Lastname as AdjustorLastName,
	  CL.DateLoss,
	  CASE WHEN B.EndDateOfService > B.DateOfService THEN B.EndDateOfService
                                      ELSE B.DateOfService END DOS,
      dx.InjuryNatureId,
	  ISNULL(dx.InjuryNatureDesc,''UNKNOWN'') InjuryNatureDesc,
	  ISNULL(dx.Duration,0) AS ERDDuration_Weeks,
	  ISNULL(dx.Duration,0)*7 AS ERDDuration_Days,
      B.ALLOWED,
	  B.CHARGED
into #temp	 
FROM #BILL_HDR BH
INNER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CLAIMANT' ELSE 'if_CLAIMANT(@RunPostingGroupAuditId)' END + ' CM  
    ON BH.OdsCustomerId = CM.OdsCustomerId
    AND BH.CmtIDNo = CM.CmtIDNo
INNER JOIN #CLAIMS CL 
	ON  CM.OdsCustomerId = CL.OdsCustomerId
	AND CM.ClaimIDNo  = CL.ClaimIDNo
	AND CL.ClaimNo NOT LIKE ''%TEST%''
	AND(CL.OdsCustomerId NOT IN (70,71) OR CL.Status <> ''C'')
INNER JOIN (
	SELECT 
	     OdsCustomerID,
		BillIDNo,
		LINE_NO,
		DT_SVC AS DateOfService,
		EndDateOfService,
		ISNULL(PreApportionedAmount,Allowed) AS Allowed,
		Charged
	FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'bills' ELSE 'if_bills(@RunPostingGroupAuditId)' END +
	CASE WHEN @OdsCustomerId <> 0 THEN ' WHERE OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3))  ELSE '' END + '  
	
	UNION ALL
	
	SELECT 
	     OdsCustomerID,
		BillIDNo,
		LINE_NO,
		DateOfService,
		EndDateOfService,
		ISNULL(PreApportionedAmount,Allowed) AS Allowed,
		Charged
	FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'bills_pharm' ELSE 'if_bills_pharm(@RunPostingGroupAuditId)' END +
	CASE WHEN @OdsCustomerId <> 0 THEN ' WHERE OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3))  ELSE '' END + '
	) B 
	
	ON  B.OdsCustomerID = BH.OdsCustomerID
     AND B.BillIDNo = BH.BillIDNo
INNER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'prf_COMPANY' ELSE 'if_prf_COMPANY(@RunPostingGroupAuditId)' END + ' CO 
	ON CO.OdsCustomerId = CL.OdsCustomerId
	AND CO.CompanyID = CL.CompanyID
	AND CO.CompanyName NOT LIKE ''%TEST%''
	AND CO.CompanyName NOT LIKE ''%TRAIN%''
INNER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'prf_Office' ELSE 'if_prf_Office(@RunPostingGroupAuditId)' END + ' O
    ON CL.OdsCustomerId = O.OdsCustomerId
    AND CL.OfficeIndex = O.OfficeId
LEFT JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'Adjustor' ELSE 'if_Adjustor(@RunPostingGroupAuditId)' END + ' AD
    ON CL.OdsCustomerId = AD.OdsCustomerId
    AND CL.AdjIdNo = AD.lAdjIdNo
LEFT JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CoverageType' ELSE 'if_CoverageType(@RunPostingGroupAuditId)' END + ' CV
    ON CL.OdsCustomerId = CV.OdsCustomerId
    AND CL.CV_Code = CV.ShortName
LEFT JOIN '+@SourceDatabaseName+'.adm.Customer D
	ON BH.OdsCustomerId = D.CustomerId
LEFT JOIN (
	 SELECT OdsCustomerId,ZipCode,County
	 FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'ZipCode' ELSE 'if_ZipCode(@RunPostingGroupAuditId)' END + ' 
	 WHERE PrimaryRecord = 1 ) Z
	 ON  CM.OdsCustomerId = Z.OdsCustomerId
	 AND LEFT(CM.CmtZip,5) = Z.Zipcode  
LEFT JOIN #InjuryNature dx
    ON  dx.OdsCustomerID = CM.ODSCustomerID
    AND dx.CmtIDNo = CM.CmtIDNo' +
CASE WHEN @OdsCustomerId <> 0 THEN ' WHERE BH.OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3))  ELSE '' END + '

;WITH BeforeERD 
AS
(
SELECT OdsCustomerId
	,CmtIDNo
	,SUM(Allowed) AllowedBeforeERD
	,SUM(Charged) ChargedBeforeERD
FROM #temp
WHERE DOS <= DATEADD(dd,ERDDuration_Days,DateLoss) 
GROUP BY OdsCustomerId,CmtIDNo
)
,AfterERD
AS
(
SELECT OdsCustomerId
	,CmtIDNo
	,SUM(Allowed) AllowedAfterERD
	,SUM(Charged) ChargedAfterERD
FROM #temp
WHERE DOS > DATEADD(dd,ERDDuration_Days,DateLoss) 
GROUP BY OdsCustomerId,CmtIDNo
)
INSERT INTO '+@TargetDatabaseName+'.dbo.ERDReport
SELECT
	  A.OdsCustomerId,
	  ''ERDReport'' AS ReportName,
      CustomerName,
      ClaimIDNo,
	  ClaimNo,
      A.CmtIDNo,
	  ISNULL(CV_Code,''NA'') CoverageType,
	  ISNULL(CoverageTypeDesc,''UNKNOWN'') CoverageTypeDesc,
	  CompanyName AS Company,
	  OfcName AS Office,	
	  ISNULL(SOJ,''UN'') SOJ,
	  ISNULL(County,''UNKNOWN'') County,
	  ISNULL(AdjustorFirstName,''UNKNOWN'') AdjustorFirstName,
	  ISNULL(AdjustorLastName,''UNKNOWN'') AdjustorLastName,
	  Min(DateLoss) ClaimDateLoss,
	  MAX(DOS) DOS,
	  InjuryNatureId,
	  InjuryNatureDesc,
	  ERDDuration_Weeks,
	  ERDDuration_Days,
	  DATEDIFF(DD,Min(DateLoss),MAX(DOS)) AllowedTreatmentDuration_Days,
	  DATEDIFF(WW,Min(DateLoss),MAX(DOS)) AllowedTreatmentDuration_Weeks,
	  SUM(Charged) Charged,
	  SUM(Allowed) Allowed,
	  MAX(ISNULL(B.ChargedAfterERD,0)) ChargedAfterERD,
      MAX(ISNULL(B.AllowedAfterERD,0)) AllowedAfterERD,
	  GETDATE() Rundate	  
FROM #temp A
LEFT JOIN AfterERD B
ON A.OdsCustomerId = B.OdsCustomerId
AND A.CmtIDNo = B.CmtIDNo
GROUP BY
	  A.OdsCustomerId,
      CustomerName,
      ClaimIDNo,
	  ClaimNo,
      A.CmtIDNo,
	  ISNULL(CV_Code,''NA''),
	  ISNULL(CoverageTypeDesc,''UNKNOWN''),
	  ISNULL(SOJ,''UN''),
	  ISNULL(County,''UNKNOWN''),
	  ISNULL(AdjustorFirstName,''UNKNOWN''),
	  ISNULL(AdjustorLastName,''UNKNOWN''),
      InjuryNatureId,
	  InjuryNatureDesc,
	  ERDDuration_Weeks,
	  ERDDuration_Days,
	  CompanyName,
	  OfcName'


EXEC(@SQLScript); 

END


GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.IndustryComparisonReport_CountyClient') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.IndustryComparisonReport_CountyClient
GO

CREATE PROCEDURE  dbo.IndustryComparisonReport_CountyClient (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@ReportID int,
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 0)
AS
BEGIN
--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@ReportID int = 3,@if_Date AS DATETIME = NULL,@RunType INT = 0,@OdsCustomerId INT = 0
DECLARE @SQL VARCHAR(MAX)

SET @SQL = CASE WHEN @OdsCustomerID <> 0 THEN 
'DELETE FROM stg.IndustryComparison_CountyClient
WHERE OdsCustomerId = '+CAST(@OdsCustomerID as VARCHAR(5))+';' ELSE 

'TRUNCATE TABLE stg.IndustryComparison_CountyClient;' END+'

INSERT INTO stg.IndustryComparison_CountyClient
SELECT ''County'' as ReportName
       ,R.OdsCustomerId
       ,CASE WHEN LTRIM(RTRIM(ISNULL(Coverage,''Uncategorized''))) = '''' THEN ''Uncategorized'' ELSE ISNULL(Coverage,''Uncategorized'') END CoverageType
       ,Form_Type as FormType
       ,CASE WHEN LTRIM(RTRIM(ISNULL(Z.State,''UN''))) = '''' THEN ''UN'' ELSE ISNULL(Z.State,''UN'') END State
       ,CASE WHEN LTRIM(RTRIM(ISNULL(Z.County,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(Z.County,''Unknown'') END County
       ,YEAR(R.CreateDate) Year
       ,DATEPART(Quarter,R.CreateDate) Quarter
       ,COUNT(DISTINCT ClaimIDNo) TotalClaims
       ,COUNT(DISTINCT CmtIDNo) TotalClaimants
       ,SUM(CHARGED) TotalCharged
       ,SUM(ISNULL(PreApportionedAmount,ALLOWED)) TotalAllowed
       ,SUM(CHARGED) - SUM(ALLOWED) TotalReductions
       ,COUNT(DISTINCT R.BillIDNo) TotalBills
       ,Cast(SUM(UNITS) as Numeric(9,2)) TotalUnits
       ,Count(LINE_NO) TotalLines
FROM stg.DP_PerformanceReport_Input R 
LEFT OUTER JOIN '+@SourceDatabaseName+'.adm.Customer C
	ON R.OdsCustomerId = C.CustomerId
LEFT OUTER JOIN  '+@SourceDatabaseName+'.dbo.CustomerBillExclusion O
	ON C.CustomerDatabase = O.Customer 
	AND R.billIDNo = O.BillIdNo
	AND O.ReportID = ' + CAST (@ReportID as Varchar(2))  + '
LEFT JOIN '+@SourceDatabaseName+'.dbo.ZipCode Z
	ON R.OdsCustomerId = Z.OdsCustomerId
	AND LEFT(R.ProviderZipOfService,5) = Z.ZipCode
	AND Z.PrimaryRecord = 1
WHERE  ISNULL(PreApportionedAmount,ALLOWED) > 0 
	AND O.BillIdNo IS NULL
'+CASE WHEN @OdsCustomerId <> 0 THEN '	AND  R.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +'
GROUP BY R.OdsCustomerId
       ,CASE WHEN LTRIM(RTRIM(ISNULL(Coverage,''Uncategorized''))) = '''' THEN ''Uncategorized'' ELSE ISNULL(Coverage,''Uncategorized'') END
       ,Form_Type 
       ,CASE WHEN LTRIM(RTRIM(ISNULL(Z.State,''UN''))) = '''' THEN ''UN'' ELSE ISNULL(Z.State,''UN'') END 
       ,CASE WHEN LTRIM(RTRIM(ISNULL(Z.County,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(Z.County,''Unknown'') END 
       ,YEAR(R.CreateDate) 
       ,DATEPART(Quarter,R.CreateDate) 
OPTION (HASH GROUP)'
	
EXEC (@SQL);

END

GO



IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.IndustryComparisonReport_CountyIndustry') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.IndustryComparisonReport_CountyIndustry
GO

CREATE PROCEDURE  dbo.IndustryComparisonReport_CountyIndustry (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@ReportID int,
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 0)
AS
BEGIN
--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@ReportID int = 3,@if_Date AS DATETIME = NULL,@RunType INT = 0,@OdsCustomerId INT = 0
DECLARE @SQL VARCHAR(MAX)

SET @SQL = '
TRUNCATE TABLE stg.IndustryComparison_CountyIndustry;
INSERT INTO stg.IndustryComparison_CountyIndustry
SELECT ''County'' as ReportName
       ,CoverageType
       ,FormType
       ,State
       ,County
       ,Year
       ,Quarter
       ,SUM(TotalClaims) IndTotalClaims
       ,SUM(TotalClaimants) IndTotalClaimants
       ,SUM(TotalCharged) IndTotalCharged
       ,SUM(TotalAllowed) IndTotalAllowed
       ,SUM(TotalCharged) - SUM(TotalAllowed) IndTotalReductions
       ,SUM(TotalBills) IndTotalBills
       ,Cast(SUM(TotalUnits) as Numeric(9,2)) IndTotalUnits
       ,SUM(TotalLines) IndTotalLines
FROM stg.IndustryComparison_CountyClient IC
INNER JOIN ' + @SourceDatabaseName + '.adm.Customer C
	ON IC.OdsCustomerId = C.CustomerId
	AND C.IncludeInIndustry = 1
GROUP BY CoverageType
       ,FormType 
       ,State
       ,County
       ,Year
       ,Quarter
OPTION (HASH GROUP);
'
	
EXEC (@SQL);

END
GO



IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.IndustryComparisonReport_CountyOutput') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.IndustryComparisonReport_CountyOutput
GO

CREATE PROCEDURE  dbo.IndustryComparisonReport_CountyOutput (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@ReportID int,
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 0,
@TargetDatabaseName VARCHAR(50) = 'ReportDB')
AS
BEGIN
--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@ReportID int = 3,@if_Date AS DATETIME = NULL,@RunType INT = 0,@OdsCustomerId INT = 0
DECLARE @SQL VARCHAR(MAX);

SET @SQL = '

DELETE FROM '+@TargetDatabaseName+'.dbo.IndustryComparison_Output
WHERE ReportName = ''County''
'+CASE WHEN @OdsCustomerId <> 0 THEN ' AND  OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +'

/*Insert Results data into Table*/
INSERT INTO '+@TargetDatabaseName+'.dbo.IndustryComparison_Output (
	   OdsCustomerId
	  ,ReportName
      ,DisplayName
      ,CoverageType
      ,CoverageTypeDesc
      ,FormType
      ,State
      ,County
      ,Year
      ,Quarter
      ,DateQuarter
      ,ClaimCnt
      ,IndClaimCnt
      ,ClaimantCnt
      ,IndClaimantCnt
      ,TotalCharged
      ,IndTotalCharged
      ,TotalAllowed
      ,IndTotalAllowed
      ,TotalReduction
      ,IndTotalReduction
      ,TotalBills
      ,IndTotalBills
      ,TotalLines
      ,IndTotalLines
      ,TotalUnits
      ,IndTotalUnits
	  ,RunDate
)
SELECT  C.OdsCustomerId
	   ,C.ReportName
       ,D.CustomerName DisplayName
       ,C.CoverageType
       ,CASE WHEN LTRIM(RTRIM(ISNULL(CV.LongName,''Uncategorized''))) = '''' THEN ''Uncategorized'' ELSE ISNULL(CV.LongName,''Uncategorized'') END CoverageTypeDesc
       ,C.FormType
       ,CASE WHEN LTRIM(RTRIM(ISNULL(C.State,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(C.State,''Unknown'') END State
       ,CASE WHEN LTRIM(RTRIM(ISNULL(C.County,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(C.County,''Unknown'') END County
       ,C.Year
       ,C.Quarter
       ,CAST(C.Year as Varchar(4)) + ''-'' + CASE WHEN C.Quarter = 1 THEN ''01'' WHEN C.Quarter = 2 THEN ''04'' WHEN C.Quarter = 3 THEN ''07'' ELSE ''10'' END    + ''-01'' as DateQuarter
       ,C.TotalClaims
       ,I.IndTotalClaims - C.TotalClaims
       ,C.TotalClaimants
       ,I.IndTotalClaimants - C.TotalClaimants
       ,C.TotalCharged
       ,I.IndTotalCharged - C.TotalCharged
       ,C.TotalAllowed
       ,I.IndTotalAllowed - C.TotalAllowed
       ,C.TotalReductions
       ,I.IndTotalReductions - C.TotalReductions
       ,C.TotalBills
       ,I.IndTotalBills - C.TotalBills
       ,C.TotalLines
       ,I.IndTotalLines - C.TotalLines
       ,C.TotalUnits
       ,I.IndTotalUnits - C.TotalUnits
	   ,GETDATE()
FROM stg.IndustryComparison_CountyClient C
LEFT JOIN stg.IndustryComparison_CountyIndustry I
	ON C.ReportName    = I.ReportName
    AND C.CoverageType = I.CoverageType
    AND C.FormType     = I.FormType
    AND C.State        = I.State
    AND C.County       = I.County
    AND C.Year         = I.Year
    AND C.Quarter        = I.Quarter
LEFT JOIN '+@SourceDatabaseName+'.adm.Customer D
	ON C.OdsCustomerID = D.CustomerId
LEFT JOIN '+@SourceDatabaseName+'.dbo.CoverageType CV
	ON  C.OdsCustomerID = CV.OdsCustomerId
	AND C.CoverageType = CV.ShortName
'+CASE WHEN @OdsCustomerId <> 0 THEN ' WHERE C.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END  +';'
	
EXEC (@SQL);


END


GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.IndustryComparisonReport_DiagnosisCodeClient') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.IndustryComparisonReport_DiagnosisCodeClient
GO

CREATE PROCEDURE  dbo.IndustryComparisonReport_DiagnosisCodeClient (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@ReportID int,
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 0)
AS
BEGIN
--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@ReportID int = 3,@if_Date AS DATETIME = NULL,@RunType INT = 0,@OdsCustomerId INT = 0
DECLARE @SQL VARCHAR(MAX)

SET @SQL = CASE WHEN @OdsCustomerID <> 0 THEN 
'DELETE FROM stg.IndustryComparison_DiagnosisCodeClient
WHERE OdsCustomerId = '+CAST(@OdsCustomerID as VARCHAR(5))+';' ELSE 

'TRUNCATE TABLE stg.IndustryComparison_DiagnosisCodeClient;' END+'

IF OBJECT_ID(''tempdb..#DPPerformaceInput'') IS NOT NULL DROP TABLE #DPPerformaceInput;
SELECT R.OdsCustomerId
	,R.BillIDNo
	,LINE_No
	,Coverage
	,Form_Type
	,Z.STATE
	,Z.County
	,R.CreateDate
	,DiagnosisCode
	,ClaimIDNo
	,CmtIDNo
	,CHARGED
	,ISNULL(PreApportionedAmount,ALLOWED) AS ALLOWED
	,UNITS
INTO #DPPerformaceInput
FROM stg.DP_PerformanceReport_Input R 
LEFT OUTER JOIN '+@SourceDatabaseName+'.adm.Customer C
	ON R.OdsCustomerId = C.CustomerId
LEFT OUTER JOIN  '+@SourceDatabaseName+'.dbo.CustomerBillExclusion O
	ON C.CustomerDatabase = O.Customer 
	AND R.billIDNo = O.BillIdNo
	AND O.ReportID = ' + CAST (@ReportID as Varchar(2))  + '
LEFT JOIN '+@SourceDatabaseName+'.dbo.ZipCode Z
	 ON R.OdsCustomerId = Z.OdsCustomerId
	 AND LEFT(R.ProviderZipOfService, 5) = Z.ZipCode
	 AND Z.PrimaryRecord = 1
WHERE ISNULL(PreApportionedAmount,ALLOWED) > 0
	AND O.BillIdNo IS NULL
	'+CASE WHEN @OdsCustomerId <> 0 THEN 'AND  R.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +'
	

INSERT INTO stg.IndustryComparison_DiagnosisCodeClient
SELECT ''Diagnosis'' as ReportName
       ,OdsCustomerId
       ,CASE WHEN LTRIM(RTRIM(ISNULL(Coverage,''Uncategorized''))) = '''' THEN ''Uncategorized'' ELSE ISNULL(Coverage,''Uncategorized'') END CoverageType
	   ,Form_Type as FormType
	   ,CASE WHEN LTRIM(RTRIM(ISNULL(State,''UN''))) = '''' THEN ''UN'' ELSE ISNULL(State,''UN'') END State
	   ,CASE WHEN LTRIM(RTRIM(ISNULL(County,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(County,''Unknown'') END County
	   ,YEAR(R.CreateDate) Year
	   ,DATEPART(Quarter,R.CreateDate) Quarter
	   ,CASE WHEN LTRIM(RTRIM(ISNULL(DiagnosisCode,''Uncategorized''))) = '''' THEN ''Uncategorized'' ELSE ISNULL(DiagnosisCode,''Uncategorized'') END DiagnosisCode
       ,COUNT(DISTINCT ClaimIDNo) TotalClaims
	   ,COUNT(DISTINCT CmtIDNo) TotalClaimants
	   ,SUM(CHARGED) TotalCharged
	   ,SUM(ALLOWED) TotalAllowed
	   ,SUM(CHARGED) - SUM(ALLOWED) TotalReductions
	   ,COUNT(DISTINCT BillIDNo) TotalBills
	   ,Cast(SUM(UNITS) as Numeric(9,2)) TotalUnits
	   ,Count(LINE_NO) TotalLines
FROM #DPPerformaceInput R
GROUP BY R.OdsCustomerId
      ,CASE WHEN LTRIM(RTRIM(ISNULL(Coverage,''Uncategorized''))) = '''' THEN ''Uncategorized'' ELSE ISNULL(Coverage,''Uncategorized'') END
	   ,Form_Type 
	   ,CASE WHEN LTRIM(RTRIM(ISNULL(State,''UN''))) = '''' THEN ''UN'' ELSE ISNULL(State,''UN'') END 
	   ,CASE WHEN LTRIM(RTRIM(ISNULL(County,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(County,''Unknown'') END 
	   ,YEAR(R.CreateDate) 
	   ,DATEPART(Quarter,R.CreateDate)  
	   ,CASE WHEN LTRIM(RTRIM(ISNULL(DiagnosisCode,''Uncategorized''))) = '''' THEN ''Uncategorized'' ELSE ISNULL(DiagnosisCode,''Uncategorized'') END
OPTION (HASH GROUP)'
	
EXEC (@SQL);
	
END

GO



IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.IndustryComparisonReport_DiagnosisCodeIndustry') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.IndustryComparisonReport_DiagnosisCodeIndustry
GO

CREATE PROCEDURE  dbo.IndustryComparisonReport_DiagnosisCodeIndustry (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@ReportID int,
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 0)
AS
BEGIN
--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@ReportID int = 3,@if_Date AS DATETIME = NULL,@RunType INT = 0,@OdsCustomerId INT = 0
DECLARE @SQL VARCHAR(MAX)

SET @SQL = '
TRUNCATE TABLE stg.IndustryComparison_DiagnosisCodeIndustry;
INSERT INTO stg.IndustryComparison_DiagnosisCodeIndustry
SELECT ''Diagnosis'' as ReportName
       ,CoverageType
       ,FormType
       ,State
       ,County
       ,Year
       ,Quarter
	   ,DiagnosisCode
       ,SUM(TotalClaims) IndTotalClaims
       ,SUM(TotalClaimants) IndTotalClaimants
       ,SUM(TotalCharged) IndTotalCharged
       ,SUM(TotalAllowed) IndTotalAllowed
       ,SUM(TotalCharged) - SUM(TotalAllowed) IndTotalReductions
       ,SUM(TotalBills) IndTotalBills
       ,Cast(SUM(TotalUnits) as Numeric(9,2)) IndTotalUnits
       ,SUM(TotalLines) IndTotalLines

FROM stg.IndustryComparison_DiagnosisCodeClient IC
INNER JOIN ' + @SourceDatabaseName + '.adm.Customer C
	ON IC.OdsCustomerId = C.CustomerId
	AND C.IncludeInIndustry = 1
GROUP BY CoverageType
       ,FormType 
       ,State
       ,County
       ,Year
       ,Quarter
	   ,DiagnosisCode
OPTION (HASH GROUP)'

EXEC (@SQL);

END

GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.IndustryComparisonReport_DiagnosisCodeOutput') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.IndustryComparisonReport_DiagnosisCodeOutput
GO

CREATE PROCEDURE  dbo.IndustryComparisonReport_DiagnosisCodeOutput (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@ReportID int,
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 0,
@TargetDatabaseName VARCHAR(50) = 'ReportDB')
AS
BEGIN
--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@ReportID int = 3,@if_Date AS DATETIME = NULL,@RunType INT = 0,@OdsCustomerId INT = 0
DECLARE @SQL VARCHAR(MAX);



SET @SQL = '
ALTER INDEX ALL ON '+@TargetDatabaseName+'.dbo.IndustryComparison_Output DISABLE;

/*Delete Previous data*/
DELETE FROM '+@TargetDatabaseName+'.dbo.IndustryComparison_Output
WHERE ReportName = ''Diagnosis''
'+CASE WHEN @OdsCustomerId <> 0 THEN ' AND  OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +'

/*Insert Results data into Table*/
INSERT INTO '+@TargetDatabaseName+'.dbo.IndustryComparison_Output( 
		 OdsCustomerId   
		,ReportName
		,DisplayName
		,CoverageType
		,CoverageTypeDesc
		,FormType
		,State
		,County
		,Year
		,Quarter
		,Code
		,[Desc]
		,MajorGroup
		,DateQuarter
		,ClaimCnt
		,IndClaimCnt
		,ClaimantCnt
		,IndClaimantCnt
		,TotalCharged
		,IndTotalCharged
		,TotalAllowed
		,IndTotalAllowed
		,TotalReduction
		,IndTotalReduction
		,TotalBills
		,IndTotalBills
		,TotalLines
		,IndTotalLines
		,TotalUnits
		,IndTotalUnits
		,RunDate )
SELECT  C.OdsCustomerId
		,C.ReportName
		,D.CustomerName DisplayName
		,C.CoverageType
		,CASE WHEN LTRIM(RTRIM(ISNULL(CV.LongName,''Uncategorized''))) = '''' THEN ''Uncategorized'' ELSE ISNULL(CV.LongName,''Uncategorized'') END CoverageTypeDesc
		,C.FormType
		,CASE WHEN LTRIM(RTRIM(ISNULL(C.State,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(C.State,''Unknown'') END State
		,CASE WHEN LTRIM(RTRIM(ISNULL(C.County,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(C.County,''Unknown'') END County
		,C.Year
		,C.Quarter
		,CASE WHEN LTRIM(RTRIM(ISNULL(C.DiagnosisCode ,''Uncategorized''))) = '''' THEN ''Uncategorized'' ELSE ISNULL(C.DiagnosisCode ,''Uncategorized'') END Code
		,CASE WHEN LTRIM(RTRIM(ISNULL(DX.DX_DESC,''Uncategorized''))) = '''' THEN ''Uncategorized'' ELSE ISNULL(DX.DX_DESC,''Uncategorized'') END [Desc]
		,CASE WHEN DX.ICDCodeFormat = 10 THEN ''ICD 10 group'' 
				WHEN DX.ICDCodeFormat <> 10 AND LTRIM(RTRIM(ISNULL(DXGP.MajorCategory,''Uncategorized''))) = '''' THEN ''Uncategorized'' 
				ELSE ISNULL(DXGP.MajorCategory,''Uncategorized'') END MajorGroup
		,CAST(C.Year as Varchar(4)) + ''-'' + CASE WHEN C.Quarter = 1 THEN ''01'' WHEN C.Quarter = 2 THEN ''04'' WHEN C.Quarter = 3 THEN ''07'' ELSE ''10'' END    + ''-01'' as DateQuarter
		,C.TotalClaims
		,I.IndTotalClaims - C.TotalClaims
		,C.TotalClaimants
		,I.IndTotalClaimants - C.TotalClaimants
		,C.TotalCharged
		,I.IndTotalCharged - C.TotalCharged
		,C.TotalAllowed
		,I.IndTotalAllowed - C.TotalAllowed
		,C.TotalReductions
		,I.IndTotalReductions - C.TotalReductions
		,C.TotalBills
		,I.IndTotalBills - C.TotalBills
		,C.TotalLines
		,I.IndTotalLines - C.TotalLines
		,C.TotalUnits
		,I.IndTotalUnits - C.TotalUnits
		,Getdate() as CreateDate
FROM stg.IndustryComparison_DiagnosisCodeClient C
LEFT JOIN stg.IndustryComparison_DiagnosisCodeIndustry I
	ON C.ReportName    = I.ReportName
	AND C.CoverageType = I.CoverageType
	AND C.FormType     = I.FormType
	AND C.State        = I.State
	AND C.County       = I.County
	AND C.Year         = I.Year
	AND C.Quarter        = I.Quarter
	AND C.DiagnosisCode = I.DiagnosisCode
LEFT JOIN  ( SELECT DISTINCT ICD9 as ICD,DX_DESC,9 as ICDCodeFormat                                                                    /*Getting the latest Description for Diagnosis Code*/
				FROM ( 
				SELECT ICD9,DX_DESC, ROW_NUMBER() OVER (PARTITION BY ICD9 ORDER BY EndDate DESC) Rnk
				FROM '+@SourceDatabaseName+'.dbo.cpt_DX_DICT
				)X WHERE Rnk = 1
				UNION
				SELECT DISTINCT DiagnosisCode as ICD,Description,10 as ICDCodeFormat
				FROM( 		  
				SELECT  DiagnosisCode,Description, ROW_NUMBER() OVER (PARTITION BY DiagnosisCode ORDER BY EndDate DESC) Rnk
				FROM '+@SourceDatabaseName+'.dbo.Icd10DiagnosisVersion
				)X WHERE Rnk = 1
			) DX
	ON C.DiagnosisCode = DX.ICD
LEFT JOIN ( SELECT DiagnosisCode,MajorCategory                                                                      /*Getting the latest Description for Diagnosis Code MajorGruoup*/
				FROM ( 
				SELECT DiagnosisCode,MajorCategory, ROW_NUMBER() OVER (PARTITION BY DiagnosisCode ORDER BY EndDate DESC) Rnk
				FROM '+@SourceDatabaseName+'.dbo.DiagnosisCodeGroup WITH (NOLOCK)
				)X WHERE Rnk = 1
			) DXGP
	ON C.DiagnosisCode = DXGP.DiagnosisCode
LEFT JOIN '+@SourceDatabaseName+'.adm.Customer D
	ON C.OdsCustomerID = D.CustomerId
LEFT JOIN '+@SourceDatabaseName+'.dbo.CoverageType CV
	ON  C.OdsCustomerID = CV.OdsCustomerId
	AND C.CoverageType = CV.ShortName
'+CASE WHEN @OdsCustomerId <> 0 THEN 'WHERE C.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +';

ALTER INDEX ALL ON '+@TargetDatabaseName+'.dbo.IndustryComparison_Output REBUILD;'
	
EXEC (@SQL);


END

GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.IndustryComparisonReport_GreenwichData') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.IndustryComparisonReport_GreenwichData
GO

CREATE PROCEDURE dbo.IndustryComparisonReport_GreenwichData (
@SourceDatabaseName VARCHAR(50) = 'AcsOds',
@TargetDatabaseName VARCHAR(50) = 'ReportDB')
AS
BEGIN
DECLARE @SQLQuery VARCHAR(MAX) = '

INSERT INTO '+@TargetDatabaseName+'.dbo.IndustryComparison_Output
SELECT 0 OdsCustomerId
	,ReportName
    ,''Greenwich'' DisplayName
    ,Code
    ,[Desc]
    ,MajorGroup
    ,CoverageType
    ,CoverageTypeDesc
    ,FormType
    ,[State]
    ,County
    ,ProviderSpecialty
    ,ProviderSpecialty_Desc
    ,ProviderType
    ,ProviderType_Desc
    ,[Year]
    ,[Quarter]
    ,DateQuarter
    ,TotalCharged*2
    ,IndTotalCharged*2
    ,TotalAllowed*2
    ,IndTotalAllowed*2
    ,ClaimCnt*2
    ,IndClaimCnt*2
    ,ClaimantCnt*2
    ,IndClaimantCnt*2
    ,TotalReduction*2
    ,IndTotalReduction*2
    ,TotalBills*2
    ,IndTotalBills*2
    ,TotalLines*2
    ,IndTotalLines*2
    ,TotalUnits*2
    ,IndTotalUnits*2
    ,Getdate() as Rundate
FROM '+@TargetDatabaseName+'.dbo.IndustryComparison_Output
Where DisplayName = ''Farmers Insurance Group'''

EXEC (@SQLQuery)
END

GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.IndustryComparisonReport_ProcedureCodeClient') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.IndustryComparisonReport_ProcedureCodeClient
GO

CREATE PROCEDURE  dbo.IndustryComparisonReport_ProcedureCodeClient (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@ReportID int,
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 0)
AS
BEGIN
--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@ReportID int = 3,@if_Date AS DATETIME = NULL,@RunType INT = 0,@OdsCustomerId INT = 0
DECLARE @SQL VARCHAR(MAX)

SET @SQL = CASE WHEN @OdsCustomerID <> 0 THEN 
'DELETE FROM stg.IndustryComparison_ProcedureCodeClient
WHERE OdsCustomerId = '+CAST(@OdsCustomerID as VARCHAR(5))+';' ELSE 

'TRUNCATE TABLE stg.IndustryComparison_ProcedureCodeClient;' END+
'
IF OBJECT_ID(''tempdb..#DPPerformaceInput'') IS NOT NULL DROP TABLE #DPPerformaceInput;
SELECT R.OdsCustomerId
	,R.BillIDNo
	,LINE_No
	,Coverage
	,Form_Type
	,Z.STATE
	,Z.County
	,R.CreateDate
	,ProcedureCode
	,ClaimIDNo
	,CmtIDNo
	,CHARGED
	,ISNULL(PreApportionedAmount,ALLOWED) AS ALLOWED
	,UNITS
INTO #DPPerformaceInput
FROM stg.DP_PerformanceReport_Input R 
LEFT OUTER JOIN '+@SourceDatabaseName+'.adm.Customer C
	ON R.OdsCustomerId = C.CustomerId
LEFT OUTER JOIN  '+@SourceDatabaseName+'.dbo.CustomerBillExclusion O
	ON C.CustomerDatabase = O.Customer 
	AND R.billIDNo = O.BillIdNo
	AND O.ReportID = ' + CAST (@ReportID as Varchar(2))  + '
LEFT JOIN '+@SourceDatabaseName+'.dbo.ZipCode  Z
		ON R.OdsCustomerId = Z.OdsCustomerId
		AND LEFT(R.ProviderZipOfService, 5) = Z.ZipCode
		AND PrimaryRecord = 1
WHERE ISNULL(PreApportionedAmount,ALLOWED) > 0
	AND O.BillIdNo IS NULL
'+CASE WHEN @OdsCustomerId <> 0 THEN '	AND  R.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +'

INSERT INTO stg.IndustryComparison_ProcedureCodeClient
SELECT ''ProcedureCode'' as ReportName
		,OdsCustomerId
		,CASE WHEN LTRIM(RTRIM(ISNULL(Coverage,''Uncategorized''))) = '''' THEN ''Uncategorized'' ELSE ISNULL(Coverage,''Uncategorized'') END CoverageType
		,Form_Type as FormType
		,CASE WHEN LTRIM(RTRIM(ISNULL(State,''UN''))) = '''' THEN ''UN'' ELSE ISNULL(State,''UN'') END State
		,CASE WHEN LTRIM(RTRIM(ISNULL(County,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(County,''Unknown'') END County
		,YEAR(R.CreateDate) Year
		,DATEPART(Quarter,R.CreateDate) Quarter
		,ProcedureCode
		,COUNT(DISTINCT ClaimIDNo) TotalClaims
		,COUNT(DISTINCT CmtIDNo) TotalClaimants
		,SUM(CHARGED) TotalCharged
		,SUM(ALLOWED) TotalAllowed
		,SUM(CHARGED) - SUM(ALLOWED) TotalReductions
		,COUNT(DISTINCT BillIDNo) TotalBills
		,Cast(SUM(UNITS) as Numeric(9,2)) TotalUnits
		,Count(LINE_NO) TotalLines
FROM #DPPerformaceInput R
GROUP BY R.OdsCustomerId
		,CASE WHEN LTRIM(RTRIM(ISNULL(Coverage,''Uncategorized''))) = '''' THEN ''Uncategorized'' ELSE ISNULL(Coverage,''Uncategorized'') END
		,Form_Type 
		,CASE WHEN LTRIM(RTRIM(ISNULL(State,''UN''))) = '''' THEN ''UN'' ELSE ISNULL(State,''UN'') END 
		,CASE WHEN LTRIM(RTRIM(ISNULL(County,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(County,''Unknown'') END 
		,YEAR(R.CreateDate) 
		,DATEPART(Quarter,R.CreateDate)  
		,ProcedureCode
OPTION (HASH GROUP)'

EXEC (@SQL);

END

GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.IndustryComparisonReport_ProcedureCodeIndustry') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.IndustryComparisonReport_ProcedureCodeIndustry
GO

CREATE PROCEDURE  dbo.IndustryComparisonReport_ProcedureCodeIndustry (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@ReportID int,
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 0)
AS
BEGIN
--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@ReportID int = 3,@if_Date AS DATETIME = NULL,@RunType INT = 0,@OdsCustomerId INT = 0
DECLARE @SQL VARCHAR(MAX)

SET @SQL ='
TRUNCATE TABLE  stg.IndustryComparison_ProcedureCodeIndustry;
INSERT INTO stg.IndustryComparison_ProcedureCodeIndustry
SELECT ''ProcedureCode'' as ReportName
   ,CoverageType
   ,FormType
   ,State
   ,County
   ,Year
   ,Quarter
   ,ProcedureCode
   ,SUM(TotalClaims) IndTotalClaims
   ,SUM(TotalClaimants) IndTotalClaimants
   ,SUM(TotalCharged) IndTotalCharged
   ,SUM(TotalAllowed) IndTotalAllowed
   ,SUM(TotalCharged) - SUM(TotalAllowed) IndTotalReductions
   ,SUM(TotalBills) IndTotalBills
   ,Cast(SUM(TotalUnits) as Numeric(9,2)) IndTotalUnits
   ,SUM(TotalLines) IndTotalLines

FROM stg.IndustryComparison_ProcedureCodeClient IC
INNER JOIN ' + @SourceDatabaseName + '.adm.Customer C
	ON IC.OdsCustomerId = C.CustomerId
	AND C.IncludeInIndustry = 1
GROUP BY CoverageType
   ,FormType 
   ,State
   ,County
   ,Year
   ,Quarter
   ,ProcedureCode
OPTION (HASH GROUP)'

EXEC (@SQL);

END

GO




IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.IndustryComparisonReport_ProcedureCodeOutput') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.IndustryComparisonReport_ProcedureCodeOutput
GO

CREATE PROCEDURE  dbo.IndustryComparisonReport_ProcedureCodeOutput (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@ReportID int,
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 0,
@TargetDatabaseName VARCHAR(50) = 'ReportDB')
AS
BEGIN
--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@ReportID int = 3,@if_Date AS DATETIME = NULL,@RunType INT = 0,@OdsCustomerId INT = 0
DECLARE @SQL VARCHAR(MAX);


SET @SQL = '
ALTER INDEX ALL ON '+@TargetDatabaseName+'.dbo.IndustryComparison_Output DISABLE;

/*Delete Previous data*/
DELETE FROM '+@TargetDatabaseName+'.dbo.IndustryComparison_Output
WHERE ReportName = ''ProcedureCode''
'+CASE WHEN @OdsCustomerId <> 0 THEN '	AND  OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +'

/*Insert Results data into Table*/
INSERT INTO '+@TargetDatabaseName+'.dbo.IndustryComparison_Output( 
		 OdsCustomerId   
		,ReportName
		,DisplayName
		,CoverageType
		,CoverageTypeDesc
		,FormType
		,State
		,County
		,Year
		,Quarter
		,Code
		,[Desc]
		,MajorGroup
		,DateQuarter
		,ClaimCnt
		,IndClaimCnt
		,ClaimantCnt
		,IndClaimantCnt
		,TotalCharged
		,IndTotalCharged
		,TotalAllowed
		,IndTotalAllowed
		,TotalReduction
		,IndTotalReduction
		,TotalBills
		,IndTotalBills
		,TotalLines
		,IndTotalLines
		,TotalUnits
		,IndTotalUnits
		,RunDate
)
SELECT   C.OdsCustomerId
		,C.ReportName
		,D.CustomerName DisplayName
		,C.CoverageType
		,CASE WHEN LTRIM(RTRIM(ISNULL(CV.LongName,''Uncategorized''))) = '''' THEN ''Uncategorized'' ELSE ISNULL(CV.LongName,''Uncategorized'') END CoverageTypeDesc
		,C.FormType
		,CASE WHEN LTRIM(RTRIM(ISNULL(C.State,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(C.State,''Unknown'') END State
		,CASE WHEN LTRIM(RTRIM(ISNULL(C.County,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(C.County,''Unknown'') END County
		,C.Year
		,C.Quarter
		,C.ProcedureCode as Code
		,CASE WHEN LTRIM(RTRIM(ISNULL(PRC.PRC_DESC,''Uncategorized''))) = '''' THEN ''Uncategorized'' ELSE ISNULL(PRC.PRC_DESC,''Uncategorized'') END [Desc]
		,CASE WHEN LEN(C.ProcedureCode) = 5 AND LTRIM(RTRIM(ISNULL(PRCGP.MajorCategory,''Uncategorized''))) = '''' THEN ''Uncategorized'' 
				WHEN LEN(C.ProcedureCode) = 13 AND CASE WHEN LTRIM(RTRIM(ISNULL(PRC.PRC_DESC,''Uncategorized''))) = '''' THEN ''Uncategorized'' ELSE ISNULL(PRC.PRC_DESC,''Uncategorized'') END <> ''Uncategorized'' THEN ''GENERIC PHARMACY''
				ELSE ISNULL(PRCGP.MajorCategory,''Uncategorized'') END MajorGroup
		,CAST(C.Year as Varchar(4)) + ''-'' + CASE WHEN C.Quarter = 1 THEN ''01'' WHEN C.Quarter = 2 THEN ''04'' WHEN C.Quarter = 3 THEN ''07'' ELSE ''10'' END    + ''-01'' as DateQuarter
		,C.TotalClaims
		,I.IndTotalClaims - C.TotalClaims
		,C.TotalClaimants
		,I.IndTotalClaimants - C.TotalClaimants
		,C.TotalCharged
		,I.IndTotalCharged - C.TotalCharged
		,C.TotalAllowed
		,I.IndTotalAllowed - C.TotalAllowed
		,C.TotalReductions
		,I.IndTotalReductions - C.TotalReductions
		,C.TotalBills
		,I.IndTotalBills - C.TotalBills
		,C.TotalLines
		,I.IndTotalLines - C.TotalLines
		,C.TotalUnits
		,I.IndTotalUnits - C.TotalUnits
		,GetDate() As Createdate
FROM stg.IndustryComparison_ProcedureCodeClient C
LEFT JOIN stg.IndustryComparison_ProcedureCodeIndustry I
	ON C.ReportName    = I.ReportName
	AND C.CoverageType = I.CoverageType
	AND C.FormType     = I.FormType
	AND C.State        = I.State
	AND C.County       = I.County
	AND C.Year         = I.Year
	AND C.Quarter        = I.Quarter
	AND C.ProcedureCode = I.ProcedureCode
LEFT JOIN  ( SELECT PRC_CD,PRC_DESC                                                                      /*Getting the latest Description for CPT and NDC Procedure Code*/
				FROM ( 
					SELECT PRC_CD,PRC_DESC, ROW_NUMBER() OVER (PARTITION BY PRC_CD ORDER BY EndDate DESC) Rnk
					FROM '+@SourceDatabaseName+'.dbo.cpt_PRC_DICT
					)X WHERE Rnk = 1
		UNION
				SELECT NDCCode,Description                                                                      
					FROM ( 
					SELECT NDCCode,Description, ROW_NUMBER() OVER (PARTITION BY NDCCode ORDER BY EndDate DESC) Rnk
					FROM '+@SourceDatabaseName+'.dbo.ny_Pharmacy
					)X WHERE Rnk = 1
			) PRC
	ON C.ProcedureCode = PRC.PRC_CD
LEFT JOIN '+@SourceDatabaseName+'.dbo.ProcedureCodeGroup PRCGP WITH (NOLOCK)
	ON  C.OdsCustomerID = PRCGP.ODSCustomerID
	AND C.ProcedureCode = PRCGP.ProcedureCode
LEFT JOIN '+@SourceDatabaseName+'.adm.Customer D
	ON C.OdsCustomerID = D.CustomerId
LEFT JOIN '+@SourceDatabaseName+'.dbo.CoverageType CV
	ON  C.OdsCustomerID = CV.OdsCustomerId
	AND C.CoverageType = CV.ShortName
WHERE ( LEN(C.ProcedureCode) = 5 OR ( LEN(C.ProcedureCode) = 13 AND (CHARINDEX(''-'',C.ProcedureCode,1)+ CHARINDEX(''-'',C.ProcedureCode,7)) = 17 )) /*CPT Codes has Len = 5 and NDC codes have Len = 13 with 2 ''-'' at position 6 and 11*/
'+CASE WHEN @OdsCustomerId <> 0 THEN '	AND  C.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +';

ALTER INDEX ALL ON '+@TargetDatabaseName+'.dbo.IndustryComparison_Output REBUILD;'

EXEC (@SQL);

END

GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.IndustryComparisonReport_ProviderSpecialtyClient') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.IndustryComparisonReport_ProviderSpecialtyClient
GO

CREATE PROCEDURE  dbo.IndustryComparisonReport_ProviderSpecialtyClient (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@ReportID int,
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 0)
AS
BEGIN
--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@ReportID int = 3,@if_Date AS DATETIME = NULL,@RunType INT = 0,@OdsCustomerId INT = 0
DECLARE @SQL VARCHAR(MAX)

SET @SQL = CASE WHEN @OdsCustomerID <> 0 THEN 
'DELETE FROM stg.IndustryComparison_ProviderSpecialtyClient
WHERE OdsCustomerId = '+CAST(@OdsCustomerID as VARCHAR(5))+';' ELSE 

'TRUNCATE TABLE stg.IndustryComparison_ProviderSpecialtyClient;' END+
'
IF OBJECT_ID(''tempdb..#DPPerformaceInput'') IS NOT NULL DROP TABLE #DPPerformaceInput;
SELECT R.OdsCustomerId
	,R.BillIDNo
	,LINE_No
	,Coverage
	,Form_Type
	,Z.STATE
	,Z.County
	,R.CreateDate
	,ProviderSpecialty
	,ClaimIDNo
	,CmtIDNo
	,CHARGED
	,ISNULL(PreApportionedAmount,ALLOWED) AS ALLOWED
	,UNITS
INTO #DPPerformaceInput
FROM stg.DP_PerformanceReport_Input R
LEFT OUTER JOIN '+@SourceDatabaseName+'.adm.Customer C
	ON R.OdsCustomerId = C.CustomerId
LEFT OUTER JOIN  '+@SourceDatabaseName+'.dbo.CustomerBillExclusion O
	ON C.CustomerDatabase = O.Customer 
	AND R.billIDNo = O.BillIdNo
	AND O.ReportID = ' + CAST (@ReportID as Varchar(2))  + '
LEFT JOIN AcsOds.dbo.ZipCode Z
	 ON R.OdsCustomerId = Z.OdsCustomerId
	 AND LEFT(R.ProviderZipOfService, 5) = Z.ZipCode
	 AND Z.PrimaryRecord = 1
WHERE ISNULL(PreApportionedAmount,ALLOWED) > 0
	AND O.BillIdNo IS NULL
	'+CASE WHEN @OdsCustomerId <> 0 THEN 'AND  R.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +'


INSERT INTO stg.IndustryComparison_ProviderSpecialtyClient
SELECT ''ProviderSpecialty'' as ReportName
       ,OdsCustomerId
       ,CASE WHEN LTRIM(RTRIM(ISNULL(Coverage,''Uncategorized''))) = '''' THEN ''Uncategorized'' ELSE ISNULL(Coverage,''Uncategorized'') END CoverageType
	   ,Form_Type as FormType
	   ,CASE WHEN LTRIM(RTRIM(ISNULL(State,''UN''))) = '''' THEN ''UN'' ELSE ISNULL(State,''UN'') END State
	   ,CASE WHEN LTRIM(RTRIM(ISNULL(County,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(County,''Unknown'') END County
	   ,YEAR(R.CreateDate) Year
	   ,DATEPART(Quarter,R.CreateDate) Quarter
	   ,CASE WHEN ProviderSpecialty = ''XX'' THEN ''OM'' ELSE ProviderSpecialty END as ProviderSpecialty
       ,COUNT(DISTINCT ClaimIDNo) TotalClaims
	   ,COUNT(DISTINCT CmtIDNo) TotalClaimants
	   ,SUM(CHARGED) TotalCharged
	   ,SUM(ALLOWED) TotalAllowed
	   ,SUM(CHARGED) - SUM(ALLOWED) TotalReductions
	   ,COUNT(DISTINCT BillIDNo) TotalBills
	   ,Cast(SUM(UNITS) as Numeric(9,2)) TotalUnits
	   ,Count(LINE_NO) TotalLines
FROM #DPPerformaceInput R
GROUP BY R.OdsCustomerId
      ,CASE WHEN LTRIM(RTRIM(ISNULL(Coverage,''Uncategorized''))) = '''' THEN ''Uncategorized'' ELSE ISNULL(Coverage,''Uncategorized'') END
	   ,Form_Type 
	   ,CASE WHEN LTRIM(RTRIM(ISNULL(State,''UN''))) = '''' THEN ''UN'' ELSE ISNULL(State,''UN'') END 
	   ,CASE WHEN LTRIM(RTRIM(ISNULL(County,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(County,''Unknown'') END 
	   ,YEAR(R.CreateDate) 
	   ,DATEPART(Quarter,R.CreateDate)  
       ,CASE WHEN ProviderSpecialty = ''XX'' THEN ''OM'' ELSE ProviderSpecialty END 

OPTION (HASH GROUP)
'

EXEC (@SQL);	
	
END

GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.IndustryComparisonReport_ProviderSpecialtyIndustry') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.IndustryComparisonReport_ProviderSpecialtyIndustry
GO

CREATE PROCEDURE  dbo.IndustryComparisonReport_ProviderSpecialtyIndustry (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@ReportID int,
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 0)
AS
BEGIN
--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@ReportID int = 3,@if_Date AS DATETIME = NULL,@RunType INT = 0,@OdsCustomerId INT = 0
DECLARE @SQL VARCHAR(MAX)

SET @SQL = '
TRUNCATE TABLE stg.IndustryComparison_ProviderSpecialtyIndustry;
INSERT INTO stg.IndustryComparison_ProviderSpecialtyIndustry
 SELECT ''ProviderSpecialty'' as ReportName
       ,CoverageType
       ,FormType
       ,State
       ,County
       ,Year
       ,Quarter
	   ,ProviderSpecialty
       ,SUM(TotalClaims) IndTotalClaims
       ,SUM(TotalClaimants) IndTotalClaimants
       ,SUM(TotalCharged) IndTotalCharged
       ,SUM(TotalAllowed) IndTotalAllowed
       ,SUM(TotalCharged) - SUM(TotalAllowed) IndTotalReductions
       ,SUM(TotalBills) IndTotalBills
       ,Cast(SUM(TotalUnits) as Numeric(9,2)) IndTotalUnits
       ,SUM(TotalLines) IndTotalLines

FROM stg.IndustryComparison_ProviderSpecialtyClient IC
INNER JOIN ' + @SourceDatabaseName + '.adm.Customer C
	ON IC.OdsCustomerId = C.CustomerId
	AND C.IncludeInIndustry = 1
GROUP BY CoverageType
       ,FormType 
       ,State
       ,County
       ,Year
       ,Quarter
	   ,ProviderSpecialty
OPTION (HASH GROUP)'


EXEC (@SQL);	
	
END

GO



IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.IndustryComparisonReport_ProviderSpecialtyOutput') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.IndustryComparisonReport_ProviderSpecialtyOutput
GO

CREATE PROCEDURE  dbo.IndustryComparisonReport_ProviderSpecialtyOutput (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@ReportID int,
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 0,
@TargetDatabaseName VARCHAR(50) = 'ReportDB')
AS
BEGIN
--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@ReportID int = 3,@if_Date AS DATETIME = NULL,@RunType INT = 0,@OdsCustomerId INT = 0
DECLARE @SQL VARCHAR(MAX);


SET @SQL ='
ALTER INDEX ALL ON '+@TargetDatabaseName+'.dbo.IndustryComparison_Output DISABLE;

/*Delete Previous data*/
DELETE FROM '+@TargetDatabaseName+'.dbo.IndustryComparison_Output
WHERE ReportName = ''ProviderSpecialty''
	'+CASE WHEN @OdsCustomerId <> 0 THEN 'AND  OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +'

/*Insert Results data into Table*/
INSERT INTO '+@TargetDatabaseName+'.dbo.IndustryComparison_Output( 		 
		 OdsCustomerId   
		,ReportName		
		,DisplayName
		,CoverageType
		,CoverageTypeDesc
		,FormType
		,State
		,County
		,Year
		,Quarter
		,ProviderSpecialty
		,ProviderSpecialty_Desc
		,DateQuarter
		,ClaimCnt
		,IndClaimCnt
		,ClaimantCnt
		,IndClaimantCnt
		,TotalCharged
		,IndTotalCharged
		,TotalAllowed
		,IndTotalAllowed
		,TotalReduction
		,IndTotalReduction
		,TotalBills
		,IndTotalBills
		,TotalLines
		,IndTotalLines
		,TotalUnits
		,IndTotalUnits
		,RunDate
)
SELECT   C.OdsCustomerId
		,C.ReportName
		,D.CustomerName DisplayName
		,C.CoverageType
		,CASE WHEN LTRIM(RTRIM(ISNULL(CV.LongName,''Uncategorized''))) = '''' THEN ''Uncategorized'' ELSE ISNULL(CV.LongName,''Uncategorized'') END CoverageTypeDesc
		,C.FormType
		,CASE WHEN LTRIM(RTRIM(ISNULL(C.State,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(C.State,''Unknown'') END State
		,CASE WHEN LTRIM(RTRIM(ISNULL(C.County,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(C.County,''Unknown'') END County
		,C.Year
		,C.Quarter
		,C.ProviderSpecialty 
		,CASE WHEN C.ProviderSpecialty = ''XX'' THEN ''OTHER MEDICAL PROVIDER'' ELSE R.Specialty_Desc END as ProviderSpecialty_Desc
		,CAST(C.Year as Varchar(4)) + ''-'' + CASE WHEN C.Quarter = 1 THEN ''01'' WHEN C.Quarter = 2 THEN ''04'' WHEN C.Quarter = 3 THEN ''07'' ELSE ''10'' END    + ''-01'' as DateQuarter
		,C.TotalClaims
		,I.IndTotalClaims - C.TotalClaims
		,C.TotalClaimants
		,I.IndTotalClaimants - C.TotalClaimants
		,C.TotalCharged
		,I.IndTotalCharged - C.TotalCharged
		,C.TotalAllowed
		,I.IndTotalAllowed - C.TotalAllowed
		,C.TotalReductions
		,I.IndTotalReductions - C.TotalReductions
		,C.TotalBills
		,I.IndTotalBills - C.TotalBills
		,C.TotalLines
		,I.IndTotalLines - C.TotalLines
		,C.TotalUnits
		,I.IndTotalUnits - C.TotalUnits
		,Getdate() as CreateDate
FROM stg.IndustryComparison_ProviderSpecialtyClient C
LEFT JOIN stg.IndustryComparison_ProviderSpecialtyIndustry I
	ON C.ReportName    = I.ReportName
	AND C.CoverageType = I.CoverageType
	AND C.FormType     = I.FormType
	AND C.State        = I.State
	AND C.County       = I.County
	AND C.Year         = I.Year
	AND C.Quarter        = I.Quarter
	AND C.ProviderSpecialty = I.ProviderSpecialty
LEFT JOIN  (  SELECT DISTINCT Specialty,Specialty_Desc
				FROM '+@SourceDatabaseName+'.dbo.ProviderSpecialtyToProvType) R
	ON C.ProviderSpecialty = R.Specialty
LEFT JOIN '+@SourceDatabaseName+'.adm.Customer D
	ON C.OdsCustomerID = D.CustomerId
LEFT JOIN '+@SourceDatabaseName+'.dbo.CoverageType CV
	ON  C.OdsCustomerID = CV.OdsCustomerId
	AND C.CoverageType = CV.ShortName
	'+CASE WHEN @OdsCustomerId <> 0 THEN 'WHERE C.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +';
	
ALTER INDEX ALL ON '+@TargetDatabaseName+'.dbo.IndustryComparison_Output REBUILD;'

EXEC (@SQL);


END

GO



IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.IndustryComparisonReport_ProviderTypeClient') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.IndustryComparisonReport_ProviderTypeClient
GO

CREATE PROCEDURE  dbo.IndustryComparisonReport_ProviderTypeClient  (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@ReportID int,
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 0)
AS
BEGIN
--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@ReportID int = 3,@if_Date AS DATETIME = NULL,@RunType INT = 0,@OdsCustomerId INT = 0
DECLARE @SQL VARCHAR(MAX)

SET @SQL =CASE WHEN @OdsCustomerID <> 0 THEN 
'DELETE FROM stg.IndustryComparison_ProviderTypeClient
WHERE OdsCustomerId = '+CAST(@OdsCustomerID as VARCHAR(5))+';' ELSE 

'TRUNCATE TABLE stg.IndustryComparison_ProviderTypeClient;' END+
' 
IF OBJECT_ID(''tempdb..#DPPerformaceInput'') IS NOT NULL DROP TABLE #DPPerformaceInput;
SELECT R.OdsCustomerId
	,R.BillIDNo
	,LINE_No
	,Coverage
	,Form_Type
	,Z.STATE
	,Z.County
	,R.CreateDate
	,ProviderType
	,ClaimIDNo
	,CmtIDNo
	,CHARGED
	,ISNULL(PreApportionedAmount,ALLOWED) AS ALLOWED
	,UNITS
INTO #DPPerformaceInput
FROM stg.DP_PerformanceReport_Input R 
LEFT OUTER JOIN '+@SourceDatabaseName+'.adm.Customer C
	ON R.OdsCustomerId = C.CustomerId
LEFT OUTER JOIN  '+@SourceDatabaseName+'.dbo.CustomerBillExclusion O
	ON C.CustomerDatabase = O.Customer 
	AND R.billIDNo = O.BillIdNo
	AND O.ReportID = ' + CAST (@ReportID as Varchar(2))  + '
LEFT JOIN '+@SourceDatabaseName+'.dbo.ZipCode Z
	 ON R.OdsCustomerId = Z.OdsCustomerId
	 AND LEFT(R.ProviderZipOfService, 5) = Z.ZipCode
	 AND Z.PrimaryRecord = 1
WHERE ISNULL(PreApportionedAmount,ALLOWED) > 0
	AND O.BillIdNo IS NULL
	'+CASE WHEN @OdsCustomerId <> 0 THEN 'AND  R.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +'


INSERT INTO stg.IndustryComparison_ProviderTypeClient
SELECT ''ProviderType'' as ReportName
		,OdsCustomerId
		,CASE WHEN LTRIM(RTRIM(ISNULL(Coverage,''Uncategorized''))) = '''' THEN ''Uncategorized'' ELSE ISNULL(Coverage,''Uncategorized'') END CoverageType
		,Form_Type as FormType
		,CASE WHEN LTRIM(RTRIM(ISNULL(State,''UN''))) = '''' THEN ''UN'' ELSE ISNULL(State,''UN'') END State
		,CASE WHEN LTRIM(RTRIM(ISNULL(County,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(County,''Unknown'') END County
		,YEAR(R.CreateDate) Year
		,DATEPART(Quarter,R.CreateDate) Quarter
		,CASE WHEN LTRIM(RTRIM(ISNULL(ProviderType,''OM''))) = '''' THEN ''OM'' ELSE ISNULL(ProviderType,''OM'') END ProviderType
		,COUNT(DISTINCT ClaimIDNo) TotalClaims
		,COUNT(DISTINCT CmtIDNo) TotalClaimants
		,SUM(CHARGED) TotalCharged
		,SUM(ALLOWED) TotalAllowed
		,SUM(CHARGED) - SUM(ALLOWED) TotalReductions
		,COUNT(DISTINCT BillIDNo) TotalBills
		,Cast(SUM(UNITS) as Numeric(9,2)) TotalUnits
		,Count(LINE_NO) TotalLines
FROM #DPPerformaceInput R
GROUP BY R.OdsCustomerId
		,CASE WHEN LTRIM(RTRIM(ISNULL(Coverage,''Uncategorized''))) = '''' THEN ''Uncategorized'' ELSE ISNULL(Coverage,''Uncategorized'') END
		,Form_Type 
		,CASE WHEN LTRIM(RTRIM(ISNULL(State,''UN''))) = '''' THEN ''UN'' ELSE ISNULL(State,''UN'') END 
		,CASE WHEN LTRIM(RTRIM(ISNULL(County,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(County,''Unknown'') END 
		,YEAR(R.CreateDate) 
		,DATEPART(Quarter,R.CreateDate)  
        ,CASE WHEN LTRIM(RTRIM(ISNULL(ProviderType,''OM''))) = '''' THEN ''OM'' ELSE ISNULL(ProviderType,''OM'') END 	

OPTION (HASH GROUP)'	
EXEC (@SQL);

END

GO



IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.IndustryComparisonReport_ProviderTypeIndustry') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.IndustryComparisonReport_ProviderTypeIndustry
GO

CREATE PROCEDURE  dbo.IndustryComparisonReport_ProviderTypeIndustry  (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@ReportID int,
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 0)
AS
BEGIN
--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@ReportID int = 3,@if_Date AS DATETIME = NULL,@RunType INT = 0,@OdsCustomerId INT = 0
DECLARE @SQL VARCHAR(MAX)

SET @SQL = '
TRUNCATE TABLE stg.IndustryComparison_ProviderTypeIndustry;
INSERT INTO  stg.IndustryComparison_ProviderTypeIndustry
SELECT ''ProviderType'' as ReportName
       ,CoverageType
       ,FormType
       ,State
       ,County
       ,Year
       ,Quarter
	   ,ProviderType
       ,SUM(TotalClaims) IndTotalClaims
       ,SUM(TotalClaimants) IndTotalClaimants
       ,SUM(TotalCharged) IndTotalCharged
       ,SUM(TotalAllowed) IndTotalAllowed
       ,SUM(TotalCharged) - SUM(TotalAllowed) IndTotalReductions
       ,SUM(TotalBills) IndTotalBills
       ,Cast(SUM(TotalUnits) as Numeric(9,2)) IndTotalUnits
       ,SUM(TotalLines) IndTotalLines

FROM stg.IndustryComparison_ProviderTypeClient IC
INNER JOIN ' + @SourceDatabaseName + '.adm.Customer C
	ON IC.OdsCustomerId = C.CustomerId
	AND C.IncludeInIndustry = 1
GROUP BY CoverageType
       ,FormType 
       ,State
       ,County
       ,Year
       ,Quarter
	   ,ProviderType
OPTION (HASH GROUP)'
	
EXEC (@SQL);

END

GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.IndustryComparisonReport_ProviderTypeOutput') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.IndustryComparisonReport_ProviderTypeOutput
GO

CREATE PROCEDURE  dbo.IndustryComparisonReport_ProviderTypeOutput  (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@ReportID int,
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 0,
@TargetDatabaseName VARCHAR(50) = 'ReportDB')
AS
BEGIN
--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@ReportID int = 3,@if_Date AS DATETIME = NULL,@RunType INT = 0,@OdsCustomerId INT = 0
DECLARE @SQL VARCHAR(MAX);

SET @SQL = '
ALTER INDEX ALL ON '+@TargetDatabaseName+'.dbo.IndustryComparison_Output DISABLE;

/*Delete Previous data*/
DELETE FROM '+@TargetDatabaseName+'.dbo.IndustryComparison_Output
WHERE ReportName = ''ProviderType''
	'+CASE WHEN @OdsCustomerId <> 0 THEN 'AND  OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +'

    
/*Insert Results data into Table*/
INSERT INTO '+@TargetDatabaseName+'.dbo.IndustryComparison_Output(
		 OdsCustomerId   
		,ReportName
		,DisplayName
		,CoverageType
		,CoverageTypeDesc
		,FormType
		,State
		,County
		,Year
		,Quarter
		,ProviderType
		,ProviderType_Desc
		,DateQuarter
		,ClaimCnt
		,IndClaimCnt
		,ClaimantCnt
		,IndClaimantCnt
		,TotalCharged
		,IndTotalCharged
		,TotalAllowed
		,IndTotalAllowed
		,TotalReduction
		,IndTotalReduction
		,TotalBills
		,IndTotalBills
		,TotalLines
		,IndTotalLines
		,TotalUnits
		,IndTotalUnits
		,RunDate
)
SELECT   
		 C.OdsCustomerId
		,C.ReportName
		,D.CustomerName DisplayName
		,C.CoverageType
		,CASE WHEN LTRIM(RTRIM(ISNULL(CV.LongName,''Uncategorized''))) = '''' THEN ''Uncategorized'' ELSE ISNULL(CV.LongName,''Uncategorized'') END CoverageTypeDesc
		,C.FormType
		,CASE WHEN LTRIM(RTRIM(ISNULL(C.State,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(C.State,''Unknown'') END State
		,CASE WHEN LTRIM(RTRIM(ISNULL(C.County,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(C.County,''Unknown'') END County
		,C.Year
		,C.Quarter
		,C.ProviderType 
		,CASE WHEN ISNULL(R.ProviderType_Desc,''OTHER MEDICAL PROVIDER'') = '''' THEN ''OTHER MEDICAL PROVIDER'' ELSE ISNULL(R.ProviderType_Desc,''OTHER MEDICAL PROVIDER'') END  ProviderType_Desc
		,CAST(C.Year as Varchar(4)) + ''-'' + CASE WHEN C.Quarter = 1 THEN ''01'' WHEN C.Quarter = 2 THEN ''04'' WHEN C.Quarter = 3 THEN ''07'' ELSE ''10'' END    + ''-01'' as DateQuarter
		,C.TotalClaims
		,I.IndTotalClaims - C.TotalClaims
		,C.TotalClaimants
		,I.IndTotalClaimants - C.TotalClaimants
		,C.TotalCharged
		,I.IndTotalCharged - C.TotalCharged
		,C.TotalAllowed
		,I.IndTotalAllowed - C.TotalAllowed
		,C.TotalReductions
		,I.IndTotalReductions - C.TotalReductions
		,C.TotalBills
		,I.IndTotalBills - C.TotalBills
		,C.TotalLines
		,I.IndTotalLines - C.TotalLines
		,C.TotalUnits
		,I.IndTotalUnits - C.TotalUnits
		,Getdate()
FROM stg.IndustryComparison_ProviderTypeClient C
LEFT JOIN stg.IndustryComparison_ProviderTypeIndustry I
	ON C.ReportName    = I.ReportName
	AND C.CoverageType = I.CoverageType
	AND C.FormType     = I.FormType
	AND C.State        = I.State
	AND C.County       = I.County
	AND C.Year         = I.Year
	AND C.Quarter        = I.Quarter
	AND C.ProviderType = I.ProviderType
LEFT JOIN  (  SELECT DISTINCT ProviderType,ProviderType_Desc
				FROM '+@SourceDatabaseName+'.dbo.ProviderSpecialtyToProvType) R
	ON C.ProviderType = R.ProviderType
LEFT JOIN '+@SourceDatabaseName+'.adm.Customer D
	ON C.OdsCustomerID = D.CustomerId
LEFT JOIN '+@SourceDatabaseName+'.dbo.CoverageType CV
	ON  C.OdsCustomerID = CV.OdsCustomerId
	AND C.CoverageType = CV.ShortName
'+CASE WHEN @OdsCustomerId <> 0 THEN ' WHERE  C.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +';

ALTER INDEX ALL ON '+@TargetDatabaseName+'.dbo.IndustryComparison_Output REBUILD;'
	
EXEC (@SQL);

END

GO







IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.LossYearReport_Client') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.LossYearReport_Client
GO

CREATE PROCEDURE  dbo.LossYearReport_Client (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 0,
@IsZeroAllowedFiltered INT  = 0)
AS
BEGIN
--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@RunType INT = 0,	@if_Date AS DATETIME = NULL,@ReportType INT = 5,@OdsCustomerId INT = 44,@IsAllowedFilter INT = 0;

DECLARE @SQLScript VARCHAR(MAX);

ALTER INDEX ALL ON  stg.LossYearReport_Client DISABLE;

SET @SQLScript = CAST ('' AS VARCHAR(MAX)) + '

IF OBJECT_ID(''tempdb..#LossYearReport_Filtered'') IS NOT NULL DROP TABLE #LossYearReport_Filtered;
SELECT  OdsCustomerId,  
		CompanyName,  
		SOJ, 
		AgeGroup, 
		DateQuarter, 
		FormType,
		CoverageType,
		EncounterTypePriority,
		ServiceGroup,
		RevenueCodeCategoryId,
		Gender, 
		Outlier_cat, 
		ClaimantState,
		ClaimantCounty, 
		ProviderSpecialty, 
		ProviderState, 
		InjuryNatureId,
		CmtIdNo, 
		DT_SVC,
		Period,
		CASE WHEN  '+CAST(@IsZeroAllowedFiltered AS CHAR(1))+' = 0 THEN 0 ELSE 1 END IsAllowedGreaterThanZero,
		Allowed, 
		Charged, 
		Units 
INTO #LossYearReport_Filtered
FROM  stg.LossYearReport_Filtered
WHERE IsAllowedGreaterThanZero = CASE WHEN '+CAST(@IsZeroAllowedFiltered AS CHAR(1))+' = 0 THEN IsAllowedGreaterThanZero ELSE 1 END
'+

--National Map
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState,
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt
)
SELECT 11 as ReportID,
		''nationalmap'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		CoverageType,
		Outlier_cat, 
		ClaimantState,
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			Outlier_cat, 
			ClaimantState,
			IsAllowedGreaterThanZero,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			Outlier_cat, 
			ClaimantState,
			IsAllowedGreaterThanZero
		) X
GROUP BY 
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState,
	IsAllowedGreaterThanZero
OPTION (HASH GROUP);
'+ 

--state_state_outlier_pvdstate_no_formtype
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState,
	IsAllowedGreaterThanZero,
	ProviderState, 
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt
	)
SELECT 1 ReportID,
		''state_state_outlier_pvdstate_no_formtype'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		CoverageType,
		Outlier_cat, 
		ClaimantState,
		IsAllowedGreaterThanZero,
		ProviderState, 
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			Outlier_cat, 
			ClaimantState,
			IsAllowedGreaterThanZero,
			ProviderState,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			Outlier_cat, 
			ClaimantState,
			IsAllowedGreaterThanZero,
			ProviderState
		)X
GROUP BY OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState,
	IsAllowedGreaterThanZero,
	ProviderState
OPTION (HASH GROUP);
'+ 

--age_state_outlier_pvdstate_no_formtype_rvgrp
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	AgeGroup, 
	DateQuarter, 
	CoverageType,
	RevenueCodeCategoryId,
	Outlier_cat, 
	ClaimantState, 
	ProviderState,
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt
)
SELECT 3 ReportID,
		''age_state_outlier_pvdstate_no_formtype_rvgrp'' ReportName,
		OdsCustomerId, 
		SOJ, 
		AgeGroup, 
		DateQuarter, 
		CoverageType,
		RevenueCodeCategoryId,
		Outlier_cat, 
		ClaimantState, 
		ProviderState,
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			AgeGroup,
			DateQuarter, 
			CoverageType,
			RevenueCodeCategoryId,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo, 
			SOJ, 
			AgeGroup,
			DateQuarter, 
			CoverageType,
			RevenueCodeCategoryId,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero
		)X
GROUP BY  OdsCustomerId,
	SOJ, 
	AgeGroup,
	DateQuarter, 
	CoverageType,
	RevenueCodeCategoryId,
	Outlier_cat, 
	ClaimantState,
	ProviderState,
	IsAllowedGreaterThanZero
OPTION (HASH GROUP);
'+

--specialty_state_outlier_pvdstate_no_formtype
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState, 
	ProviderSpecialty, 
	ProviderState,
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt
)
SELECT 7 ReportID,
		''specialty_state_outlier_pvdstate_no_formtype'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		CoverageType,
		Outlier_cat, 
		ClaimantState, 
		ProviderSpecialty, 
		ProviderState,
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter,
			CoverageType, 
			Outlier_cat, 
			ClaimantState,
			ProviderSpecialty,
			ProviderState,
			IsAllowedGreaterThanZero,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter,
			CoverageType, 
			Outlier_cat, 
			ClaimantState,
			ProviderSpecialty,
			ProviderState,
			IsAllowedGreaterThanZero
		)X    
GROUP BY OdsCustomerId, 
	SOJ, 
	DateQuarter,
	CoverageType, 
	Outlier_cat, 
	ClaimantState,
	ProviderSpecialty,
	ProviderState,
	IsAllowedGreaterThanZero
OPTION (HASH GROUP);
'+
		
--gender_state_outlier_pvdstate_no_formtype
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Gender, 
	Outlier_cat, 
	ClaimantState, 
	ProviderState,
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt)
SELECT 9 ReportID,
		''gender_state_outlier_pvdstate_no_formtype'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		CoverageType,
		Gender, 
		Outlier_cat, 
		ClaimantState, 
		ProviderState,
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			Gender,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY  
			I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			Gender,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero
		)X    
GROUP BY OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Gender,
	Outlier_cat, 
	ClaimantState,
	ProviderState,
	IsAllowedGreaterThanZero
OPTION (HASH GROUP);
'+

--county_severity_map
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState, 
	ClaimantCounty,
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt)
SELECT 14 ReportID,
		''county_severity_map'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		CoverageType,
		Outlier_cat, 
		ClaimantState, 
		ClaimantCounty,
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			Outlier_cat, 
			ClaimantState,
			ClaimantCounty,
			IsAllowedGreaterThanZero,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			Outlier_cat, 
			ClaimantState,
			ClaimantCounty,
			IsAllowedGreaterThanZero
		)X    
GROUP BY OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState,
	ClaimantCounty,
	IsAllowedGreaterThanZero
OPTION (HASH GROUP);
'+

--national_pip_map
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState,
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt)
SELECT 12 ReportID,
		''national_pip_map'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		CoverageType,
		Outlier_cat, 
		ClaimantState,
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			Outlier_cat, 
			ClaimantState,
			IsAllowedGreaterThanZero,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units, 
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo, 
			SOJ, 
			DateQuarter, 
			CoverageType,
			Outlier_cat, 
			ClaimantState,
			IsAllowedGreaterThanZero
		) X   
GROUP BY OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState,
	IsAllowedGreaterThanZero
OPTION (HASH GROUP);
'+

--state_state_outlier_pvdstate_srvcgrp_rvgrp
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	FormType,
	CoverageType,
	ServiceGroup,
	RevenueCodeCategoryId,
	Outlier_cat, 
	ClaimantState, 
	ProviderState,
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt)
SELECT 2 ReportID,
		''state_state_outlier_pvdstate_srvcgrp_rvgrp'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		FormType,
		CoverageType,
		ServiceGroup,
		RevenueCodeCategoryId,
		Outlier_cat, 
		ClaimantState, 
		ProviderState,
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			FormType,
			CoverageType,
			ServiceGroup,
			RevenueCodeCategoryId,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			FormType,
			CoverageType,
			ServiceGroup,
			RevenueCodeCategoryId,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero
		)X    
GROUP BY OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	FormType,
	CoverageType,
	ServiceGroup,
	RevenueCodeCategoryId,
	Outlier_cat, 
	ClaimantState,
	ProviderState,
	IsAllowedGreaterThanZero
OPTION (HASH GROUP);
'+  

--age_state_outlier_pvdstate_srvcgrp_rvgrp
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	AgeGroup, 
	DateQuarter, 
	FormType,
	CoverageType,
	ServiceGroup,
	RevenueCodeCategoryId,
	Outlier_cat, 
	ClaimantState, 
	ProviderState, 
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt)
SELECT 4 ReportID,
		''age_state_outlier_pvdstate_srvcgrp_rvgrp'' ReportName,
		OdsCustomerId, 
		SOJ, 
		AgeGroup, 
		DateQuarter, 
		FormType,
		CoverageType,
		ServiceGroup,
		RevenueCodeCategoryId,
		Outlier_cat, 
		ClaimantState, 
		ProviderState, 
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			AgeGroup,
			DateQuarter, 
			FormType,
			CoverageType,
			ServiceGroup,
			RevenueCodeCategoryId,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo, 
			SOJ, 
			AgeGroup,
			DateQuarter, 
			FormType,
			CoverageType,
			ServiceGroup,
			RevenueCodeCategoryId,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero
		) X   
GROUP BY OdsCustomerId, 
	SOJ, 
	AgeGroup,
	DateQuarter, 
	FormType,
	CoverageType,
	ServiceGroup,
	RevenueCodeCategoryId,
	Outlier_cat, 
	ClaimantState,
	ProviderState,
	IsAllowedGreaterThanZero
OPTION (HASH GROUP);
'+

--specialty_state_outlier_pvdstate_srvcgrp
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	FormType,
	CoverageType,
	ServiceGroup,
	Outlier_cat, 
	ClaimantState, 
	ProviderSpecialty, 
	ProviderState, 
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt)
SELECT 8 ReportID,
		''specialty_state_outlier_pvdstate_srvcgrp'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		FormType,
		CoverageType,
		ServiceGroup,
		Outlier_cat, 
		ClaimantState, 
		ProviderSpecialty, 
		ProviderState, 
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo, 
			SOJ, 
			DateQuarter, 
			FormType,
			CoverageType,
			ServiceGroup,
			Outlier_cat, 
			ClaimantState,
			ProviderSpecialty,
			ProviderState,
			IsAllowedGreaterThanZero,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			FormType,
			CoverageType,
			ServiceGroup,
			Outlier_cat, 
			ClaimantState,
			ProviderSpecialty,
			ProviderState,
			IsAllowedGreaterThanZero
		) X   
GROUP BY  OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		FormType,
		CoverageType,
		ServiceGroup,
		Outlier_cat, 
		ClaimantState,
		ProviderSpecialty,
		ProviderState,
		IsAllowedGreaterThanZero
OPTION (HASH GROUP);
'+

--gender_state_outlier_pvdstate_srvcgrp_rvgrp*/
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	FormType,
	CoverageType,
	ServiceGroup,
	RevenueCodeCategoryId,
	Gender, 
	Outlier_cat, 
	ClaimantState, 
	ProviderState, 
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt)
SELECT 10 ReportID,
		''gender_state_outlier_pvdstate_srvcgrp_rvgrp'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		FormType,
		CoverageType,
		ServiceGroup,
		RevenueCodeCategoryId,
		Gender, 
		Outlier_cat, 
		ClaimantState, 
		ProviderState, 
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			FormType,
			CoverageType,
			ServiceGroup,
			RevenueCodeCategoryId,
			Gender,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			FormType,
			CoverageType,
			ServiceGroup,
			RevenueCodeCategoryId,
			Gender,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero
			) X  
GROUP BY OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	FormType,
	CoverageType,
	ServiceGroup,
	RevenueCodeCategoryId,
	Gender,
	Outlier_cat, 
	ClaimantState,
	ProviderState,
	IsAllowedGreaterThanZero
OPTION (HASH GROUP);
'+

--injury_state_outlier_pvdstate_no_formtype
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState, 
	ProviderState, 
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt,
	InjuryNatureId)
SELECT 5 ReportID,
		''injury_state_outlier_pvdstate_no_formtype'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		CoverageType,
		Outlier_cat, 
		ClaimantState, 
		ProviderState, 
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt,
		InjuryNatureId
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero,
			InjuryNatureId,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero,
			InjuryNatureId
		) X 
GROUP BY OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		CoverageType,
		Outlier_cat, 
		ClaimantState,
		ProviderState,
		IsAllowedGreaterThanZero,
		InjuryNatureId
OPTION (HASH GROUP);
'+

--injury_state_outlier_pvdstate_srvcgrp
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	FormType,
	CoverageType,
	ServiceGroup,
	Outlier_cat, 
	ClaimantState, 
	ProviderState,
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt,
	InjuryNatureId)
SELECT 6 ReportID,
		''injury_state_outlier_pvdstate_srvcgrp'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		FormType,
		CoverageType,
		ServiceGroup,
		Outlier_cat, 
		ClaimantState, 
		ProviderState,
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt,
		InjuryNatureId
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter,
			FormType, 
			CoverageType,
			ServiceGroup,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero,
			InjuryNatureId,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter,
			FormType, 
			CoverageType,
			ServiceGroup,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero,
			InjuryNatureId
		) X 
GROUP BY OdsCustomerId, 
		SOJ, 
		DateQuarter,
		FormType, 
		CoverageType,
		ServiceGroup,
		Outlier_cat, 
		ClaimantState,
		ProviderState,
		IsAllowedGreaterThanZero,
		InjuryNatureId
OPTION (HASH GROUP);
'+	
		
--National_Injury_Map
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState, 
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt,
	InjuryNatureId)
SELECT 13 ReportID,
		''National_Injury_Map'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		CoverageType,
		Outlier_cat, 
		ClaimantState, 
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt,
		InjuryNatureId
FROM (
SELECT I.OdsCustomerId, 
		I.CmtIDNo,
		SOJ, 
		DateQuarter, 
		CoverageType,
		Outlier_cat, 
		ClaimantState,
		IsAllowedGreaterThanZero,
		InjuryNatureId,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT DT_SVC) DT_SVC
FROM #LossYearReport_Filtered I
GROUP BY 
		I.OdsCustomerId, 
		I.CmtIDNo,
		SOJ, 
		DateQuarter, 
		CoverageType,
		Outlier_cat, 
		ClaimantState,
		IsAllowedGreaterThanZero,
		InjuryNatureId
    )X    
GROUP BY OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState,
	IsAllowedGreaterThanZero,
	InjuryNatureId
OPTION (HASH GROUP);
'+	
		
--county_injury_map
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState, 
	ClaimantCounty,
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt,
	InjuryNatureId)
SELECT 15 ReportID,
		''county_injury_map'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		CoverageType,
		Outlier_cat, 
		ClaimantState, 
		ClaimantCounty,
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt,
		InjuryNatureId
FROM (	
	SELECT I.OdsCustomerId, 
			I.CmtIDNo, 
			SOJ, 
			DateQuarter, 
			CoverageType,
			Outlier_cat, 
			ClaimantState,
			ClaimantCounty,
			IsAllowedGreaterThanZero,
			InjuryNatureId,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			Outlier_cat, 
			ClaimantState,
			ClaimantCounty,
			IsAllowedGreaterThanZero,
			InjuryNatureId
		) X  
GROUP BY OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState,
	ClaimantCounty,
	IsAllowedGreaterThanZero,
	InjuryNatureId
OPTION (HASH GROUP);
'+
		
--state_state_outlier_pvdstate_no_formtype_period
'
SELECT I.OdsCustomerId, 
		I.CmtIDNo,
		SOJ, 
		DateQuarter, 
		CoverageType,
		Outlier_cat, 
		ClaimantState,
		ProviderState,
		Period,
		CASE                                        /*Prepping for cummulative sum By Period*/
	 		WHEN Period =   ''b4 dol'' THEN 0
	 		WHEN Period =   ''1st Quarter'' THEN 1
			WHEN Period =   ''2nd Quarter'' THEN 2
			WHEN Period =   ''3rd Quarter'' THEN 3
			WHEN Period =   ''4th Quarter'' THEN 4
			WHEN Period =   ''5th Quarter'' THEN 5
			WHEN Period =   ''6th Quarter'' THEN 6
			WHEN Period =   ''7th Quarter'' THEN 7
			WHEN Period =   ''8th Quarter'' THEN 8
			WHEN Period =   ''ultimate'' THEN 9 END PeriodId,
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units,
		COUNT(DISTINCT DT_SVC) DT_SVC	
INTO #ForCummulativeSum	   
FROM #LossYearReport_Filtered I
GROUP BY 
		I.OdsCustomerId, 
		I.CmtIDNo,
		SOJ, 
		DateQuarter, 
		CoverageType,
		Outlier_cat, 
		ClaimantState,
		ProviderState,
		Period,
		CASE 
	 		WHEN Period =   ''b4 dol'' THEN 0
	 		WHEN Period =   ''1st Quarter'' THEN 1
			WHEN Period =   ''2nd Quarter'' THEN 2
			WHEN Period =   ''3rd Quarter'' THEN 3
			WHEN Period =   ''4th Quarter'' THEN 4
			WHEN Period =   ''5th Quarter'' THEN 5
			WHEN Period =   ''6th Quarter'' THEN 6
			WHEN Period =   ''7th Quarter'' THEN 7
			WHEN Period =   ''8th Quarter'' THEN 8
			WHEN Period =   ''ultimate'' THEN 9 END,
		IsAllowedGreaterThanZero

INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState, 
	ProviderState, 
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt,
	Period)
SELECT 16 ReportID,
		''state_state_outlier_pvdstate_no_formtype_period'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		CoverageType,
		Outlier_cat, 
		ClaimantState, 
		ProviderState, 
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt,
		Period 
FROM (
	SELECT  t1.OdsCustomerId, 
			t1.CmtIDNo,		   
			t1.SOJ, 			
			t1.DateQuarter, 			
			t1.CoverageType,			
			t1.Outlier_cat, 
			t1.ClaimantState, 			
			t1.ProviderState, 
			t1.IsAllowedGreaterThanZero,
			t1.Period,
			SUM(t2.Allowed) Allowed, 
			SUM(t2.Charged) Charged, 
			SUM(t2.UNITS) Units, 
			SUM(t2.DT_SVC) DT_SVC			
	FROM #ForCummulativeSum t1            /*Sum cummulative By Period*/
	INNER JOIN #ForCummulativeSum t2 
		ON t1.OdsCustomerId = t2.OdsCustomerId
		AND t1.Cmtidno = t2.Cmtidno
		AND t1.SOJ	=	 t2.SOJ
		AND t1.DateQuarter	=	t2.DateQuarter	
		AND t1.CoverageType	=	t2.CoverageType	
		AND t1.Outlier_cat = t2.Outlier_cat
		AND t1.ClaimantState =	 t2.ClaimantState		
		AND t1.ProviderState  = t2.ProviderState
		AND t1.IsAllowedGreaterThanZero = t2.IsAllowedGreaterThanZero
		AND t1.PeriodId >= t2.PeriodId  /*Sum cummulative By Period*/
	GROUP BY t1.OdsCustomerId, 
			t1.CmtIDNo,		   
			t1.SOJ, 			
			t1.DateQuarter, 			
			t1.CoverageType,			
			t1.Outlier_cat, 
			t1.ClaimantState, 			
			t1.ProviderState, 
			t1.IsAllowedGreaterThanZero,
			t1.Period
	)X
GROUP BY OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState,
	ProviderState,
	IsAllowedGreaterThanZero,
	Period
OPTION (HASH GROUP);
'+
		
--EncounterTYpe_state_state_outlier_pvdstate_no_formtype
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	EncounterTypePriority,
	Outlier_cat, 
	ClaimantState, 
	ProviderState,
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt)
SELECT 17 ReportID,
		''encountertype_state_state_outlier_pvdstate_no_formtype'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		CoverageType,
		EncounterTypePriority,
		Outlier_cat, 
		ClaimantState, 
		ProviderState, 
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			EncounterTypePriority,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			EncounterTypePriority,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero
		)X
GROUP BY OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	EncounterTypePriority,
	Outlier_cat, 
	ClaimantState,
	ProviderState,
	IsAllowedGreaterThanZero
OPTION (HASH GROUP);
'+

--encountertype_state_state_outlier_pvdstate_formtype_srvcgrp
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	FormType,
	CoverageType,
	EncounterTypePriority,
	ServiceGroup,
	Outlier_cat, 
	ClaimantState, 
	ProviderState, 
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt)
SELECT 18 ReportID,
		''encountertype_state_state_outlier_pvdstate_formtype_srvcgrp'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		FormType,
		CoverageType,
		EncounterTypePriority,
		ServiceGroup,
		Outlier_cat, 
		ClaimantState, 
		ProviderState, 
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			FormType,
			CoverageType,
			EncounterTypePriority,
			ServiceGroup,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			FormType,
			CoverageType,
			EncounterTypePriority,
			ServiceGroup,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero
		)X    
GROUP BY OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	FormType,
	CoverageType,
	EncounterTypePriority,
	ServiceGroup,
	Outlier_cat, 
	ClaimantState,
	ProviderState,
	IsAllowedGreaterThanZero
OPTION (HASH GROUP);
'+

--EncounterType_injury_state_outlier_pvdstate_no_formtype
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	EncounterTypePriority,
	Outlier_cat, 
	ClaimantState, 
	ProviderState,
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt,
	InjuryNatureId)
SELECT 19 ReportID,
		''encountertype_injury_state_outlier_pvdstate_no_formtype'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		CoverageType,
		EncounterTypePriority,
		Outlier_cat, 
		ClaimantState, 
		ProviderState, 
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt,
		InjuryNatureId
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			EncounterTypePriority,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero,
			InjuryNatureId,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			EncounterTypePriority,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero,
			InjuryNatureId
		) X 
GROUP BY OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		CoverageType,
		EncounterTypePriority,
		Outlier_cat, 
		ClaimantState,
		ProviderState,
		IsAllowedGreaterThanZero,
		InjuryNatureId
OPTION (HASH GROUP);'

    
EXEC(@SQLScript);

ALTER INDEX ALL ON  stg.LossYearReport_Client REBUILD;
		
END


GO


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


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.LossYearReport_GreenwichData') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.LossYearReport_GreenwichData
GO

CREATE PROCEDURE dbo.LossYearReport_GreenwichData 
AS
BEGIN
INSERT INTO dbo.LossYearReport(
	ReportName,
	CustomerName,
	CompanyName,
	SOJ,
	AgeGroup,
	YOL,
	Year,
	Quarter,
	DateQuarter,
	FormType,
	CoverageType,
	CoverageTypeDesc,
	InjuryNatureId,
	InjuryNatureDesc,
	EncounterTypeId,
	EncounterTypeDesc,
	ServiceGroup,
	RevenueGroup,
	Gender,
	OutlierCat,
	ClaimantState,
	ClaimantCounty,
	ProviderSpecialty,
	ProviderState,
	Allowed,
	IndAllowed,
	Charged,
	IndCharged,
	UnitsCnt,
	IndUnitsCnt,
	ClaimantCnt,
	IndClaimantCnt,
	DOSCnt,
	IndDOSCnt,
	IsAllowedGreaterThanZero,
	RunDate
)
SELECT ReportName,
	'Greenwich' CustomerName,
	CompanyName,
	SOJ,
	AgeGroup,
	YOL,
	Year,
	Quarter,
	DateQuarter,
	FormType,
	CoverageType,
	CoverageTypeDesc,
	InjuryNatureId,
	InjuryNatureDesc,
	EncounterTypeId,
	EncounterTypeDesc,
	ServiceGroup,
	RevenueGroup,
	Gender,
	OutlierCat,
	ClaimantState,
	ClaimantCounty,
	ProviderSpecialty,
	ProviderState,
	SUM(Allowed*1.37),
	SUM(IndAllowed*1.46),
	SUM(Charged*1.54),
	SUM(IndCharged*1.64),
	SUM(UnitsCnt*2),
	SUM(IndUnitsCnt*3),
	SUM(ClaimantCnt*2),
	SUM(IndClaimantCnt*4),
	SUM(DOSCnt*2),
	SUM(IndDOSCnt*3),
	IsAllowedGreaterThanZero,
	GETDATE()
FROM [dbo].[LossYearReport]
WHERE CustomerName in ('Farmers Insurance Group','AAA Michigan','CSAA Insurance Group')
GROUP BY ReportName,
	CompanyName,
	SOJ,
	AgeGroup,
	YOL,
	Year,
	Quarter,
	DateQuarter,
	FormType,
	CoverageType,
	CoverageTypeDesc,
	InjuryNatureId,
	InjuryNatureDesc,
	EncounterTypeId,
	EncounterTypeDesc,
	ServiceGroup,
	RevenueGroup,
	Gender,
	OutlierCat,
	ClaimantState,
	ClaimantCounty,
	ProviderSpecialty,
	ProviderState,
	IsAllowedGreaterThanZero;
END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.LossYearReport_Industry') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.LossYearReport_Industry
GO

CREATE PROCEDURE  dbo.LossYearReport_Industry(
@SourceDatabaseName VARCHAR(50)='AcsOds') 
AS
BEGIN
DECLARE @SQL VARCHAR(MAX);

ALTER INDEX ALL ON  stg.LossYearReport_Industry DISABLE;

SET @SQL = CAST ('' AS VARCHAR(MAX)) +'
TRUNCATE TABLE stg.LossYearReport_Industry;

INSERT INTO stg.LossYearReport_Industry
SELECT  ReportID,
		ReportName,
		SOJ, 
		AgeGroup, 
		DateQuarter, 
		FormType,
		CoverageType,
		EncounterTypePriority,
		ServiceGroup,
		RevenueCodeCategoryId,
		Gender, 
		Outlier_cat, 
		ClaimantState, 
		ClaimantCounty,
		ProviderSpecialty, 
		ProviderState, 
		IsAllowedGreaterThanZero,
		SUM(Allowed) IndAllowed, 
		SUM(Charged) IndCharged, 
		SUM(UNITS) IndUnits, 
		SUM(ClaimantCnt) IndClaimantCnt, 
		SUM(DOSCnt) IndDOSCnt,
		InjuryNatureId,
		Period
FROM stg.LossYearReport_Client
GROUP BY
		ReportID, 
		ReportName,
		SOJ, 
		AgeGroup, 
		DateQuarter, 
		FormType,
		CoverageType,
		EncounterTypePriority,
		ServiceGroup,
		RevenueCodeCategoryId,
		Gender, 
		Outlier_cat, 
		ClaimantState,
		ClaimantCounty, 
		ProviderSpecialty, 
		ProviderState,
		IsAllowedGreaterThanZero,
		InjuryNatureId,
		Period;'

EXEC(@SQL);

ALTER INDEX ALL ON  stg.LossYearReport_Industry REBUILD;
		
END

GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.LossYearReport_Input') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.LossYearReport_Input
GO


CREATE PROCEDURE dbo.LossYearReport_Input (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@StartDate AS DATETIME,
@EndDate AS DATETIME,
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 0,
@ReportId INT=5,
@ProcessId INT=1)
AS
BEGIN
--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',	@StartDate AS DATETIME = '2012-01-01',@EndDate AS DATETIME = '2016-12-31',@RunType INT = 0,	@if_Date AS DATETIME = NULL,@ProcessId INT = 5,@OdsCustomerId INT = 44;

DECLARE @SQLScript VARCHAR(MAX),
		@returnstatus INT; 

EXEC adm.Rpt_CreateUnpartitionedTableSchema @OdsCustomerId,@ProcessId,0,@returnstatus;

SET @SQLScript = CAST ('' AS VARCHAR(MAX)) + '
DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;

'+CASE WHEN @OdsCustomerID <> 0 THEN 
'DELETE FROM stg.LossYearReport_Input
WHERE OdsCustomerId = '+CAST(@OdsCustomerID as VARCHAR(5))+';' ELSE 

'TRUNCATE TABLE stg.LossYearReport_Input;' END+'

-- Filter CLAIMS data

IF OBJECT_ID(''tempdb..#CLAIMS'') IS NOT NULL DROP TABLE #CLAIMS;
SELECT CL.OdsCustomerId,
       CL.ClaimIDNo,
       CL.ClaimNo,
	   CL.DateLoss,
	   CL.CV_Code,
	   CL.LossState,
	   CL.Status,
	   CL.CompanyID
INTO #CLAIMS
FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CLAIMS' ELSE 'if_CLAIMS(@RunPostingGroupAuditId)' END + '  CL 
WHERE CL.CV_Code IN (''MP'',''PI'')'+
	CASE WHEN @OdsCustomerId <> 0 THEN 'AND CL.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +' 
	AND CL.DateLoss >= ''' + CAST(@StartDate AS VARCHAR(40)) + ''' AND  CL.DateLoss <= ''' + CAST(@EndDate AS VARCHAR(40))+ '''

CREATE CLUSTERED INDEX cidx_Cust_ClaimID 
ON #CLAIMS(OdsCustomerId, ClaimIDNo)

CREATE NONCLUSTERED INDEX nidx_Cust_ClaimID 
ON #CLAIMS(OdsCustomerId, ClaimIDNo,Status)
INCLUDE(ClaimNo, DateLoss,CV_Code, LossState, CompanyID)
'+

-- Filter BILL_HDR Data
'

IF OBJECT_ID(''tempdb..#Bill_HDR_Detail'') IS NOT NULL DROP TABLE #Bill_HDR_Detail;
SELECT BH.OdsCustomerId
	,BH.BillIDNo
	,BH.CMT_HDR_IDNo
	,CH.CmtIDNo
	,CH.PvdIDNo
	,BH.CreateDate
	,BH.OfficeId
	,LEFT(BH.PvdZOS, 5) PvdZOS
	,BH.TypeOfBill
	,CASE WHEN BH.Flags & 4096 > 0	THEN '' UB - 04 ''	ELSE '' CMS - 1500 ''	END AS Form_Type
	,BH.AdmissionDate
	,BH.DischargeDate
	,BH.ClaimDateLoss
	,BH.Flags & 16 AS Migrated
	,B.LINE_NO
	,B.LineType
	,B.PRC_CD
	,B.CHARGED
	,B.ALLOWED
	,B.ANALYZED
	,B.UNITS
	,B.DT_SVC
	,B.POS_RevCode
	,CASE WHEN (EX.Customer IS NOT NULL
		OR B.CHARGED > (B.UNITS*ISNULL(MCC.MaxChargedPerUnit,999999999999))
		OR B.UNITS > ISNULL(MCC.MaxUnitsPerEncounter,999999999999)
		OR B.CHARGED < 0
		OR B.UNITS < 0) THEN 1	ELSE 0 	END Outlier

INTO #Bill_HDR_Detail
FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'BILL_HDR' ELSE 'if_BILL_HDR(@RunPostingGroupAuditId)' END + ' BH
INNER JOIN (SELECT
				 OdsCustomerId 
				,BillIDNo
				,LINE_NO
				,1 AS LineType
				,PRC_CD
				,ISNULL(CHARGED, 0) CHARGED
				,ISNULL(ALLOWED, 0) ALLOWED
				,ISNULL(ANALYZED, 0) ANALYZED
				,ISNULL(UNITS, 0) UNITS
				,DT_SVC
				,POS_RevCode 
			FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'BILLS' ELSE 'if_BILLS(@RunPostingGroupAuditId)' END + 
			CASE WHEN @OdsCustomerId <> 0 THEN ' WHERE OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3))  ELSE '' END + '
									
			UNION ALL
			
			SELECT 
				 OdsCustomerId
				,BillIDNo
				,LINE_NO
				,2 AS LineType
				,NDC
				,ISNULL(CHARGED, 0) CHARGED
				,ISNULL(ALLOWED, 0) ALLOWED
				,ISNULL(ANALYZED, 0) ANALYZED
				,ISNULL(UNITS, 0) UNITS
				,DateOfService
				,POS_RevCode
			FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'BILLS_Pharm' ELSE 'if_BILLS_Pharm(@RunPostingGroupAuditId)' END + 
			CASE WHEN @OdsCustomerId <> 0 THEN ' WHERE OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3))  ELSE '' END + '
			) AS B
	ON BH.OdsCustomerId = B.OdsCustomerId
	AND BH.BillIDNo = B.BillIDNo
INNER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CMT_HDR' ELSE 'if_CMT_HDR(@RunPostingGroupAuditId)' END + ' CH 
	ON BH.OdsCustomerId = CH.OdsCustomerId
	AND BH.CMT_HDR_IDNo = CH.CMT_HDR_IDNo
LEFT OUTER JOIN '+@SourceDatabaseName+'.adm.Customer C
	ON BH.OdsCustomerId = C.CustomerId
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CustomerBillExclusion' ELSE 'if_CustomerBillExclusion(@RunPostingGroupAuditId)' END + ' EX 
	ON C.CustomerDatabase = EX.Customer
	AND BH.BillIDNo = EX.BillIdNo
	AND EX.ReportID = 4
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'MedicalCodeCutOffs' ELSE 'if_MedicalCodeCutOffs(@RunPostingGroupAuditId)' END + ' MCC
	ON CASE WHEN ISNULL(B.PRC_CD,'''') = '''' THEN B.POS_RevCode ELSE B.PRC_CD END = MCC.Code
	AND CASE WHEN BH.Flags & 4096 > 0 THEN ''UB-04''	ELSE ''CMS-1500''	END = MCC.FormType 
WHERE  BH.CreateDate >= ''' + CAST(@StartDate AS VARCHAR(40))+''''+
	CASE WHEN @OdsCustomerId <> 0 THEN ' AND BH.OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +'
	
CREATE CLUSTERED INDEX cidx_Cust_Bill_CMT 
ON #Bill_HDR_Detail(OdsCustomerId,BillIDNo)

CREATE NONCLUSTERED INDEX nidx_Cust_Bill_CMT 
ON #Bill_HDR_Detail(OdsCustomerId,BillIDNo,CMT_HDR_IDNo, Migrated, TypeOfBill,PvdZOS ) 
INCLUDE (CreateDate,OfficeId,ALLOWED,Form_Type,AdmissionDate,DischargeDate,ClaimDateLoss)'+

-- Get Allowed at Claimant level
'
IF OBJECT_ID('' tempdb..#Cmt_Allowed '') IS NOT NULL	DROP TABLE #Cmt_Allowed;
SELECT BH.OdsCustomerId
	,BH.CmtIDNo
	,SUM(BH.ALLOWED) Cmt_Allowed
INTO #Cmt_Allowed
FROM #Bill_HDR_Detail BH
WHERE Outlier = 0
	AND Migrated = 0
GROUP BY BH.OdsCustomerId
	,BH.CmtIDNo

CREATE NONCLUSTERED INDEX nidx_Cust_cmtIdNo 
ON #Cmt_Allowed(OdsCustomerId,CmtIDNo)
INCLUDE (Cmt_Allowed)
'
+

-- Get InjuryType Info By Claimant
'

IF OBJECT_ID(''tempdb..#InjuryNature'') IS NOT NULL DROP TABLE #InjuryNature;    
;WITH 
cte_IcdDiagnosisCodeDictionary AS(
SELECT dict.OdsCustomerID 
    ,dict.DiagnosisCode
    ,dict.IcdVersion
	,dict.InjuryNatureId
	,ROW_NUMBER() OVER (PARTITION BY OdsCustomerId, DiagnosisCode, IcdVersion ORDER BY StartDate DESC) rnk
FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'IcdDiagnosisCodeDictionary' ELSE 'if_IcdDiagnosisCodeDictionary(@RunPostingGroupAuditId)' END + ' dict
'+CASE WHEN @OdsCustomerId <> 0 THEN 'WHERE OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3))  ELSE '' END+'),

cte_InjuryNature AS(
SELECT cdx.OdsCustomerId
	,BH.CmtIDNo
	,cdx.BillIDNo
	,cdx.dx DiagnosisCode
	,cdx.IcdVersion
	,dict.InjuryNatureId 
	,ISNULL(I.[Description],''UNKNOWN'') InjuryNatureDesc
	,ROW_NUMBER() OVER (PARTITION BY cdx.OdsCustomerId,BH.CmtIDNo ORDER BY I.InjuryNaturePriority) rnk 
FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CMT_DX' ELSE 'if_CMT_DX(@RunPostingGroupAuditId)' END + ' cdx
INNER JOIN #Bill_HDR_Detail BH
     ON  BH.OdsCustomerID = cdx.OdsCustomerID
	 AND BH.BillIDNo = cdx.BillIDNo
INNER JOIN cte_IcdDiagnosisCodeDictionary dict
	ON  dict.OdsCustomerID = cdx.ODSCustomerID
    AND dict.DiagnosisCode = cdx.dx
    AND dict.IcdVersion = cdx.IcdVersion 
	AND dict.rnk = 1
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'InjuryNature' ELSE 'if_InjuryNature(@RunPostingGroupAuditId)' END + ' I 
	ON dict.OdsCustomerId = I.OdsCustomerId
	AND dict.InjuryNatureId = I.InjuryNatureId)

SELECT DISTINCT
	 OdsCustomerId
	,CmtIDNo
	,DiagnosisCode
	,IcdVersion
	,InjuryNatureId
	,InjuryNatureDesc
INTO #InjuryNature
FROM cte_InjuryNature Dx
WHERE Dx.rnk = 1


CREATE NONCLUSTERED INDEX nidx_CustIdCmtIDNo 
ON #InjuryNature(OdsCustomerId,CmtIDNo) 
INCLUDE (InjuryNatureId,InjuryNatureDesc)

IF OBJECT_ID(''tempdb..#ICD'') IS NOT NULL DROP TABLE #ICD;
SELECT OdsCustomerId,BILLIDNo,ICD9,IcdVersion,SeqNo
INTO #ICD
  FROM (
		  SELECT OdsCustomerId
			  ,BILLIDNo
			  ,ICD9
			  ,IcdVersion
			  ,SeqNo
			  ,ROW_NUMBER() OVER (Partition BY OdsCustomerId,BILLIDNo ORDER BY SeqNo) Rnk 
		  FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CMT_ICD9' ELSE 'if_CMT_ICD9(@RunPostingGroupAuditId)' END + 
		  CASE WHEN @OdsCustomerId <> 0 THEN ' WHERE OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3))  ELSE '' END + '
        ) X
  WHERE Rnk = 1

CREATE NONCLUSTERED INDEX indx_Cust_BillIDNO ON #ICD
(OdsCustomerId,BillIDNo) INCLUDE (ICD9,IcdVersion,SeqNo)'+

-- Populate Raw Data Table for Lost Year Report
'

INSERT INTO stg.LossYearReport_Input_Unpartitioned
SELECT BH.OdsCustomerId,
	   BH.BillIDNo,
	   BH.LINE_NO,
	   BH.LineType,
	   BH.CMT_HDR_IDNo,
	   CL.ClaimIDNo,
	   BH.CmtIDNo,
	   CL.DateLoss,
	   BH.CreateDate,
	   CL.DateLoss as AnchorDate, 
	   CAST((CAST(YEAR(CL.DateLoss) AS VARCHAR(4)) +''-''+ (CASE  WHEN CAST(DATEPART(QUARTER,CL.DateLoss) AS VARCHAR(1)) = ''1'' THEN ''01''
															   WHEN CAST(DATEPART(QUARTER,CL.DateLoss) AS VARCHAR(1)) = ''2'' THEN ''04''
															   WHEN CAST(DATEPART(QUARTER,CL.DateLoss) AS VARCHAR(1)) = ''3'' THEN ''07''
															   WHEN CAST(DATEPART(QUARTER,CL.DateLoss) AS VARCHAR(1)) = ''4'' THEN ''10'' END)+ ''-01'') AS DATETIME) AS AnchorDateQuarter, 
	   BH.OfficeId,
	   LEFT(BH.PvdZOS,5) PvdZOS, 
	   CASE WHEN LTRIM(RTRIM(ISNULL(Z.State,''UN''))) = '''' THEN ''UN'' ELSE ISNULL(Z.State,''UN'') END State,
       CASE WHEN LTRIM(RTRIM(ISNULL(Z.County,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(Z.County,''Unknown'') END County,
	   BH.TypeOfBill, 
	   BT.[Description] BillTypeDesc,
	   CL.CV_Code,
	   BH.Form_Type, 
	   BH.Migrated, 
	   BH.AdmissionDate,
	   BH.DischargeDate,
	   CM.CmtDOB,
	   CASE WHEN CM.CmtSEX NOT IN (''M'',''F'') THEN ''UN'' ELSE CM.CmtSEX END CmtSEX,
	   CASE WHEN LTRIM(RTRIM(ISNULL(CM.CmtStateOfJurisdiction,''UN''))) = '''' THEN ''UN'' ELSE ISNULL(CM.CmtStateOfJurisdiction,''UN'') END CmtStateOfJurisdiction,
	   CASE WHEN LTRIM(RTRIM(ISNULL(CM.CmtState,''UN''))) = '''' THEN ''UN'' ELSE ISNULL(CM.CmtState,''UN'') END CmtState,
	   CASE WHEN LTRIM(RTRIM(ISNULL(Zip.County,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(Zip.County,''Unknown'') END CmtCounty,
	   CM.CmtZip,
	   ISNULL(CO.CompanyName,''Unknown'') CompanyName,
	   BH.PRC_CD,
	   BH.POS_RevCode,
	   '''' POSDesc, /*POS.[Description] After brining the placeofservice table to ODS*/
	   BH.DT_SVC,
	   P.PvdIDNo,
	   LEFT(P.PvdZip,5) PvdZip,
	   CASE WHEN ISNULL(LTRIM(RTRIM(P.PvdSPC_List)),'''') = '''' THEN ''Uncategorized'' ELSE P.PvdSPC_List END AS PvdSPC_List,
	   P.PvdTitle,
	   CA.Cmt_Allowed,
	   BH.CHARGED,
	   BH.ALLOWED,
	   BH.UNITS,
	   DX.DiagnosisCode,
	   1 DX_SeqNum,
	   DX.IcdVersion DX_IcdVersion,
	   ICD9.ICD9 AS ICD,
	   ICD9.SeqNo AS ICD_SeqNum,
	   ICD9.IcdVersion AS ICD_IcdVersion, /*Do we have Icd10 version ?*/
	   DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) AS Period_Days, 
	   CASE 
	 	WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) < 0	THEN ''b4 dol''
	 	WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 0 AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 91 THEN ''1st Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 92 AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 182 THEN ''2nd Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 183 AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 273	THEN ''3rd Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 274 AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 365	THEN ''4th Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 366	AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 456 THEN ''5th Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 457	AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 547 THEN ''6th Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 548	AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 638 THEN ''7th Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 639	AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 730	THEN ''8th Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 731	THEN ''ultimate'' END Period,
	   DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) AS Age,
	   CASE 
		WHEN DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) >= 0 AND DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) <= 17	THEN ''minor''
		WHEN DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) >= 18	AND DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) <= 35	THEN ''young adult''
		WHEN DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) >= 36	AND DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) <= 49	THEN ''mature adult''
		WHEN DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) >= 50	THEN ''senior'' ELSE ''unknown''
		END AgeGroup,
	   CASE 
		WHEN  CA.Cmt_Allowed < 2500.01	THEN ''< 2500''
		WHEN  CA.Cmt_Allowed >= 2500.01	AND  CA.Cmt_Allowed < 5000.01	THEN ''between 2500_5000''
		WHEN  CA.Cmt_Allowed >= 5000.01	AND  CA.Cmt_Allowed < 10000.01	THEN ''between 5000_10000''
		WHEN  CA.Cmt_Allowed >= 10000.01	AND  CA.Cmt_Allowed < 15000.01	THEN ''between 10000_15000''
		WHEN  CA.Cmt_Allowed >= 15000.01	AND  CA.Cmt_Allowed < 25000.01	THEN ''between 15000_25000''
		WHEN  CA.Cmt_Allowed >= 25000.01	AND  CA.Cmt_Allowed < 50000.01	THEN ''between 25000_50000''
		WHEN  CA.Cmt_Allowed >= 50000.01	THEN ''> 50000''
		END  Outlier_cat, '
		+ CAST ('' AS VARCHAR(MAX)) + '
	   '''' Bill_Type, /*Get the rules from HIM team for InPatient, Outpatient, ER and Asc*/ 
	   '''' DX_Score, /*Dependent on HIM team and probably out of scope for this PSI*/
	   '''' er_bill_flag, /*Flag if a Bill is ER type or not*/
	   RCSC.RevenueCodeCategoryId,
	   YEAR(CL.DateLoss) AS YOL,
	   CASE WHEN ISNULL(LTRIM(RTRIM(PCG.MinorCategory)),'''') = '''' THEN ''Uncategorized'' ELSE PCG.MinorCategory END AS ServiceGroup,
	   BH.Outlier,
	   CASE WHEN DX.InjuryNatureId IS NULL THEN 24 ELSE DX.InjuryNatureId END AS InjuryNatureId,
	   CASE WHEN (BH.Form_Type = ''CMS-1500'' and BH.POS_RevCode IN (''0'', ''23'')) or (BH.Form_Type = ''UB-04''  and BH.TypeOfBill = ''0131'' and BH.POS_RevCode = ''0450'') THEN 2 /*Emergency Room*/
	        WHEN ((BH.Form_Type = ''CMS-1500''  and BH.POS_RevCode = ''21'') or (BH.Form_Type = ''UB-04'' and BH.TypeOfBill LIKE ''011%'')) THEN 1 /*Inpatient*/
		   WHEN ((BH.Form_Type = ''CMS-1500''   and BH.POS_RevCode = ''24'') or (BH.Form_Type = ''UB-04'' and BH.TypeOfBill LIKE ''083%'')) THEN 3 /*Ambulatory Surgical Center*/
		   WHEN (BH.Form_Type = ''CMS-1500'' and BH.POS_RevCode = ''11'')  THEN 4 /*Professional Office Visit*/
		   WHEN ((BH.Form_Type = ''UB-04'' and ((BH.TypeOfBill LIKE ''013%'') or (BH.TypeOfBill LIKE ''014%'') or (BH.TypeOfBill LIKE ''074%'') or (BH.TypeOfBill LIKE ''075%''))) and BH.POS_RevCode NOT like ''045%'') or (BH.Form_Type = ''CMS-1500'' and BH.POS_RevCode IN (''19'',''22'',''61'')) THEN 5 /*Outpatient*/
		   WHEN (BH.Form_Type = ''UB-04'' and ((BH.TypeOfBill like ''02%'') or (BH.TypeOfBill like ''03%''))) OR (BH.Form_Type = ''CMS-1500'' and BH.POS_RevCode in (''12'',''31'',''32'',''33'')) THEN 6 /*Skilled Nursing/Home Health*/
        ELSE 7 /*Other*/ END EncounterTypeId,
	  GETDATE() AS Rundate
FROM  #Bill_HDR_Detail BH
INNER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CLAIMANT' ELSE 'if_CLAIMANT(@RunPostingGroupAuditId)' END + ' CM 
	ON BH.OdsCustomerId = CM.OdsCustomerId
	AND BH.CmtIDNo = CM.CmtIDNo 
INNER JOIN #Cmt_Allowed CA 
	ON CM.OdsCustomerId = CA.OdsCustomerId
	AND CM.CmtIDNo = CA.CmtIDNo
INNER JOIN #CLAIMS CL 
	ON  CM.OdsCustomerId = CL.OdsCustomerId
	AND CM.ClaimIDNo  = CL.ClaimIDNo
	AND CL.ClaimNo NOT LIKE ''%TEST%''
	AND(CL.OdsCustomerId NOT IN (70,71) OR CL.Status <> ''C'')
INNER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'prf_COMPANY' ELSE 'if_prf_COMPANY(@RunPostingGroupAuditId)' END + ' CO 
	ON CO.OdsCustomerId = CL.OdsCustomerId
	AND CO.CompanyID = CL.CompanyID
	AND CO.CompanyName NOT LIKE ''%TEST%''
	AND CO.CompanyName NOT LIKE ''%TRAIN%''	
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'PROVIDER' ELSE 'if_PROVIDER(@RunPostingGroupAuditId)' END + ' P 
	ON  P.OdsCustomerId = BH.OdsCustomerId
	AND P.PvdIDNo = BH.PvdIDNo
LEFT OUTER JOIN #ICD ICD9
	ON  BH.OdsCustomerId = ICD9.OdsCustomerId
	AND BH.BillIDNo = ICD9.BillIDNo
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'UB_BillType' ELSE 'if_UB_BillType(@RunPostingGroupAuditId)' END + ' BT 
	ON BH.OdsCustomerId = BT.OdsCustomerId
	AND BH.TypeOfBill = BT.TOB
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'ProcedureCodeGroup' ELSE 'if_ProcedureCodeGroup(@RunPostingGroupAuditId)' END + ' PCG 
	ON BH.OdsCustomerId = PCG.OdsCustomerId
	AND BH.PRC_CD = PCG.ProcedureCode
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'UB_RevenueCodes' ELSE 'if_UB_RevenueCodes(@RunPostingGroupAuditId)' END + ' RC 
	ON BH.OdsCustomerId = RC.OdsCustomerId
	AND BH.POS_RevCode = RC.RevenueCode
	AND BH.CreateDate BETWEEN RC.StartDate AND RC.EndDate
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'RevenueCodeSubcategory' ELSE 'if_RevenueCodeSubcategory(@RunPostingGroupAuditId)' END + ' RCSC 
	ON RC.OdsCustomerId = RCSC.OdsCustomerId
	AND RC.RevenueCodeSubCategoryId = RCSC.RevenueCodeSubCategoryId
LEFT OUTER JOIN (SELECT * FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'ZipCode' ELSE 'if_ZipCode(@RunPostingGroupAuditId)' END + ' WHERE PrimaryRecord = 1) Z
	ON BH.OdsCustomerId = Z.OdsCustomerId
	AND LEFT(BH.PvdZOS,5) = Z.ZipCode
LEFT OUTER JOIN (SELECT * FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'ZipCode' ELSE 'if_ZipCode(@RunPostingGroupAuditId)' END + ' WHERE PrimaryRecord = 1) Zip
	ON CM.OdsCustomerId = Zip.OdsCustomerId
	AND LEFT(CM.CmtZip,5) = Zip.ZipCode	
LEFT OUTER JOIN #InjuryNature DX
    ON  DX.OdsCustomerID = BH.ODSCustomerID
    AND DX.CmtIDNo = BH.CmtIDNo
WHERE BH.Migrated = 0
OPTION (MERGE JOIN, HASH JOIN) '


+ CAST ('' AS VARCHAR(MAX)) + '


/*****************3rd Party*************/

/****Get Claimants with Min(Bill Date Created) "DemandCreateDate" in last rolling 5 years****/
IF OBJECT_ID(''tempdb..#DemandCreateDate'') IS NOT NULL DROP TABLE #DemandCreateDate;
SELECT CH.OdsCustomerId
      ,CM.ClaimIdNo
      ,CH.CmtIdNo
      ,MIN(BH.CreateDate) DemandCreateDate
INTO #DemandCreateDate
FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'BILL_HDR' ELSE 'if_BILL_HDR(@RunPostingGroupAuditId)' END + '  BH  
INNER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CMT_HDR' ELSE 'if_CMT_HDR(@RunPostingGroupAuditId)' END + '  CH  
	ON BH.OdsCustomerId = CH.OdsCustomerId
	AND BH.CMT_HDR_IDNo = CH.CMT_HDR_IDNo
INNER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CLAIMANT' ELSE 'if_CLAIMANT(@RunPostingGroupAuditId)' END + '  CM
	ON CH.OdsCustomerId = CM.OdsCustomerId
	AND CH.CmtIDNo = CM.CmtIDNo 
INNER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CLAIMS' ELSE 'if_CLAIMS(@RunPostingGroupAuditId)' END + '  CL  
	ON  CM.OdsCustomerId = CL.OdsCustomerId
	AND CM.ClaimIDNo  = CL.ClaimIDNo
	AND CL.CV_Code IN (''AL'',''GL'',''UM'',''UN'') /*3rd party Claims Only*/ ' +
CASE WHEN @OdsCustomerId <> 0 THEN ' WHERE BH.OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3))  ELSE '' END + '
GROUP BY CH.OdsCustomerId
        ,CM.ClaimIdNo
        ,CH.CmtIdNo
HAVING MIN(BH.CreateDate) >= ''' + CAST(@StartDate AS VARCHAR(40))  + ''' AND MIN(BH.CreateDate) <= ''' + CAST(@EndDate AS VARCHAR(40))  + ''' 
OPTION (MERGE JOIN, HASH JOIN)

CREATE NONCLUSTERED INDEX cidx_Cust_ClaimId_CmtId ON #DemandCreateDate
(OdsCustomerId, ClaimIdNo, CmtIdNo) INCLUDE (DemandCreateDate);



INSERT INTO stg.LossYearReport_Input_Unpartitioned
SELECT BH.OdsCustomerId,
	   BH.BillIDNo,
	   BH.LINE_NO,
	   BH.LineType,
	   BH.CMT_HDR_IDNo,
	   CL.ClaimIDNo,
	   BH.CmtIDNo,
	   CL.DateLoss,
	   BH.CreateDate,
	   DMD.DemandCreateDate AS AnchorDate,/*Demand Create Date is the anchor date for 3rd party*/
	   CAST((CAST(YEAR(DMD.DemandCreateDate) AS VARCHAR(4)) +''-''+ (CASE  WHEN CAST(DATEPART(QUARTER,DMD.DemandCreateDate) AS VARCHAR(1)) = ''1'' THEN ''01''
															   WHEN CAST(DATEPART(QUARTER,DMD.DemandCreateDate) AS VARCHAR(1)) = ''2'' THEN ''04''
															   WHEN CAST(DATEPART(QUARTER,DMD.DemandCreateDate) AS VARCHAR(1)) = ''3'' THEN ''07''
															   WHEN CAST(DATEPART(QUARTER,DMD.DemandCreateDate) AS VARCHAR(1)) = ''4'' THEN ''10'' END)+ ''-01'') AS DATETIME) AS AnchorDateQuarter,
	   BH.OfficeId,
	   LEFT(BH.PvdZOS,5) PvdZOS, 
	   CASE WHEN LTRIM(RTRIM(ISNULL(Z.State,''UN''))) = '''' THEN ''UN'' ELSE ISNULL(Z.State,''UN'') END State,
       CASE WHEN LTRIM(RTRIM(ISNULL(Z.County,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(Z.County,''Unknown'') END County,
	   BH.TypeOfBill, 
	   BT.[Description] BillTypeDesc,
	   CL.CV_Code,
	   BH.Form_Type,
	   BH.Migrated, 
	   BH.AdmissionDate,
	   BH.DischargeDate,
	   CM.CmtDOB,
	   CASE WHEN CM.CmtSEX NOT IN (''M'',''F'') THEN ''UN'' ELSE CM.CmtSEX END CmtSEX,
	   CASE WHEN LTRIM(RTRIM(ISNULL(CM.CmtStateOfJurisdiction,''UN''))) = '''' THEN ''UN'' ELSE ISNULL(CM.CmtStateOfJurisdiction,''UN'') END CmtStateOfJurisdiction,
	   CASE WHEN LTRIM(RTRIM(ISNULL(CM.CmtState,''UN''))) = '''' THEN ''UN'' ELSE ISNULL(CM.CmtState,''UN'') END CmtState,
	   CASE WHEN LTRIM(RTRIM(ISNULL(Zip.County,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(Zip.County,''Unknown'') END CmtCounty,
	   CM.CmtZip,
	   ISNULL(CO.CompanyName,''Unknown'') CompanyName,
	   BH.PRC_CD,
	   BH.POS_RevCode,
	   '''' POSDesc, /*POS.[Description] After brining the placeofservice table to ODS*/
	   BH.DT_SVC,
	   P.PvdIDNo,
	   LEFT(P.PvdZip,5) PvdZip,
	   CASE WHEN ISNULL(LTRIM(RTRIM(P.PvdSPC_List)),'''') = '''' THEN ''Uncategorized'' ELSE P.PvdSPC_List END AS PvdSPC_List,
	   P.PvdTitle,
	   CA.Cmt_Allowed,
	   BH.CHARGED,
	   BH.ALLOWED,
	   BH.UNITS,
	   DX.DiagnosisCode,
	   1 DX_SeqNum,
	   DX.IcdVersion DX_IcdVersion,
	   ICD9.ICD9 AS ICD,
	   ICD9.SeqNo AS ICD_SeqNum,
	   ICD9.IcdVersion AS ICD_IcdVersion, /*Do we have Icd10 version ?*/
	   DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) AS Period_Days, /*Ed has used BH.CreateDate but He mentioned ideally we should be using DateOfService*/  
	   CASE 
	 	WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) < 0	THEN ''b4 dol''
	 	WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 0 AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 91 THEN ''1st Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 92 AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 182 THEN ''2nd Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 183 AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 273	THEN ''3rd Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 274 AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 365	THEN ''4th Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 366	AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 456 THEN ''5th Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 457	AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 547 THEN ''6th Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 548	AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 638 THEN ''7th Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 639	AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 730	THEN ''8th Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 731	THEN ''ultimate'' END Period,
	   DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) AS Age,
	   CASE 
		WHEN DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) >= 0 AND DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) <= 17	THEN ''minor''
		WHEN DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) >= 18	AND DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) <= 35	THEN ''young adult''
		WHEN DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) >= 36	AND DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) <= 49	THEN ''mature adult''
		WHEN DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) >= 50	THEN ''senior'' ELSE ''unknown''
		END AgeGroup,
	   CASE 
		WHEN  CA.Cmt_Allowed < 2500.01	THEN ''< 2500''
		WHEN  CA.Cmt_Allowed >= 2500.01	AND  CA.Cmt_Allowed < 5000.01	THEN ''between 2500_5000''
		WHEN  CA.Cmt_Allowed >= 5000.01	AND  CA.Cmt_Allowed < 10000.01	THEN ''between 5000_10000''
		WHEN  CA.Cmt_Allowed >= 10000.01 AND  CA.Cmt_Allowed < 15000.01	THEN ''between 10000_15000''
		WHEN  CA.Cmt_Allowed >= 15000.01 AND  CA.Cmt_Allowed < 25000.01	THEN ''between 15000_25000''
		WHEN  CA.Cmt_Allowed >= 25000.01 AND  CA.Cmt_Allowed < 50000.01	THEN ''between 25000_50000''
		WHEN  CA.Cmt_Allowed >= 50000.01 THEN ''> 50000''
		END  Outlier_cat, '
		+ CAST ('' AS VARCHAR(MAX)) + '
	   '''' Bill_Type, /*Get the rules from HIM team for InPatient, Outpatient, ER and Asc*/ 
	   '''' DX_Score, /*Dependent on HIM team and probably out of scope for this PSI*/
	   '''' er_bill_flag, /*Flag if a Bill is ER type or not*/
	   RCSC.RevenueCodeCategoryId,
	   YEAR(CL.DateLoss) AS YOL,
	   CASE WHEN ISNULL(LTRIM(RTRIM(PCG.MinorCategory)),'''') = '''' THEN ''Uncategorized'' ELSE PCG.MinorCategory END AS ServiceGroup,
	   BH.Outlier,
	   DX.InjuryNatureId,
	    CASE WHEN (BH.Form_Type = ''CMS-1500'' and BH.POS_RevCode IN (''0'', ''23'')) or (BH.Form_Type = ''UB-04''  and BH.TypeOfBill = ''0131'' and BH.POS_RevCode = ''0450'') THEN 2 /*Emergency Room*/
	        WHEN ((BH.Form_Type = ''CMS-1500''  and BH.POS_RevCode = ''21'') or (BH.Form_Type = ''UB-04'' and BH.TypeOfBill LIKE ''011%'')) THEN 1 /*Inpatient*/
		   WHEN ((BH.Form_Type = ''CMS-1500''   and BH.POS_RevCode = ''24'') or (BH.Form_Type = ''UB-04'' and BH.TypeOfBill LIKE ''083%'')) THEN 3 /*Ambulatory Surgical Center*/
		   WHEN (BH.Form_Type = ''CMS-1500'' and BH.POS_RevCode = ''11'')  THEN 4 /*Professional Office Visit*/
		   WHEN ((BH.Form_Type = ''UB-04'' and ((BH.TypeOfBill LIKE ''013%'') or (BH.TypeOfBill LIKE ''014%'') or (BH.TypeOfBill LIKE ''074%'') or (BH.TypeOfBill LIKE ''075%''))) and BH.POS_RevCode NOT like ''045%'') or (BH.Form_Type = ''CMS-1500'' and BH.POS_RevCode IN (''19'',''22'',''61'')) THEN 5 /*Outpatient*/
		   WHEN (BH.Form_Type = ''UB-04'' and ((BH.TypeOfBill like ''02%'') or (BH.TypeOfBill like ''03%''))) OR (BH.Form_Type = ''CMS-1500'' and BH.POS_RevCode in (''12'',''31'',''32'',''33'')) THEN 6 /*Skilled Nursing/Home Health*/
        ELSE 7 /*Other*/ END EncounterTypeId,
		GETDATE() AS Rundate
FROM  #Bill_HDR_Detail BH
INNER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CLAIMANT' ELSE 'if_CLAIMANT(@RunPostingGroupAuditId)' END + ' CM 
	ON BH.OdsCustomerId = CM.OdsCustomerId
	AND BH.CmtIDNo = CM.CmtIDNo 
INNER JOIN #Cmt_Allowed CA 
	ON CM.OdsCustomerId = CA.OdsCustomerId
	AND CM.CmtIDNo = CA.CmtIDNo
INNER JOIN #DemandCreateDate DMD
	ON CM.OdsCustomerId = DMD.OdsCustomerId
	AND CM.CmtIDNo = DMD.CmtIDNo
INNER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CLAIMS' ELSE 'if_CLAIMS(@RunPostingGroupAuditId)' END + ' CL  
	ON  CM.OdsCustomerId = CL.OdsCustomerId
	AND CM.ClaimIDNo  = CL.ClaimIDNo
	AND CL.ClaimNo NOT LIKE ''%TEST%''
	AND(CL.OdsCustomerId NOT IN (70,71) OR CL.Status <> ''C'')
INNER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'prf_COMPANY' ELSE 'if_prf_COMPANY(@RunPostingGroupAuditId)' END + ' CO 
	ON CO.OdsCustomerId = CL.OdsCustomerId
	AND CO.CompanyID = CL.CompanyID
	AND CO.CompanyName NOT LIKE ''%TEST%''
	AND CO.CompanyName NOT LIKE ''%TRAIN%''	
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'PROVIDER' ELSE 'if_PROVIDER(@RunPostingGroupAuditId)' END + ' P 
	ON  P.OdsCustomerId = BH.OdsCustomerId
	AND P.PvdIDNo = BH.PvdIDNo
LEFT OUTER JOIN #ICD ICD9
	ON  BH.OdsCustomerId = ICD9.OdsCustomerId
	AND BH.BillIDNo = ICD9.BillIDNo
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'UB_BillType' ELSE 'if_UB_BillType(@RunPostingGroupAuditId)' END + ' BT 
	ON BH.OdsCustomerId = BT.OdsCustomerId
	AND BH.TypeOfBill = BT.TOB
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'ProcedureCodeGroup' ELSE 'if_ProcedureCodeGroup(@RunPostingGroupAuditId)' END + ' PCG 
	ON BH.OdsCustomerId = PCG.OdsCustomerId
	AND BH.PRC_CD = PCG.ProcedureCode
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'UB_RevenueCodes' ELSE 'if_UB_RevenueCodes(@RunPostingGroupAuditId)' END + ' RC 
	ON BH.OdsCustomerId = RC.OdsCustomerId
	AND BH.POS_RevCode = RC.RevenueCode
	AND BH.CreateDate BETWEEN RC.StartDate AND RC.EndDate
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'RevenueCodeSubcategory' ELSE 'if_RevenueCodeSubcategory(@RunPostingGroupAuditId)' END + ' RCSC 
	ON RC.OdsCustomerId = RCSC.OdsCustomerId
	AND RC.RevenueCodeSubCategoryId = RCSC.RevenueCodeSubCategoryId
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'ZipCode' ELSE 'if_ZipCode(@RunPostingGroupAuditId)' END + ' Z
	ON BH.OdsCustomerId = Z.OdsCustomerId
	AND LEFT(BH.PvdZOS,5) = Z.ZipCode
	AND Z.PrimaryRecord = 1
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'ZipCode' ELSE 'if_ZipCode(@RunPostingGroupAuditId)' END + ' Zip
	ON CM.OdsCustomerId = Zip.OdsCustomerId
	AND LEFT(CM.CmtZip,5) = Zip.ZipCode	
	AND Zip.PrimaryRecord = 1
LEFT OUTER JOIN #InjuryNature DX
     ON  DX.OdsCustomerID = BH.ODSCustomerID
     AND DX.CmtIDNo = BH.CmtIDNo
WHERE BH.Migrated = 0  

OPTION (MERGE JOIN, HASH JOIN);'

EXEC (@SQLScript);

EXEC adm.Rpt_CreateUnpartitionedTableIndexes @OdsCustomerId,@ProcessId,@returnstatus;
EXEC adm.Rpt_SwitchUnpartitionedTable @OdsCustomerId,@ProcessId,'',0,@returnstatus;

END

GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.LossYearReport_Output') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.LossYearReport_Output
GO

CREATE PROCEDURE  dbo.LossYearReport_Output  (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@RunType INT = 0, 
@OdsCustomerID INT,
@ReportId INT=5,
@ProcessId INT=3)
AS
BEGIN
-- DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@RunType INT = 0, @OdsCustomerID INT = 44, @ReportId INT=5, @ProcessId INT=3
DECLARE @SQLScript VARCHAR(MAX),
		@returnstatus INT; 

EXEC adm.Rpt_CreateUnpartitionedTableSchema @OdsCustomerId,@ProcessId,0,@returnstatus;

SET @SQLScript = CAST('' AS VARCHAR(MAX)) +
CASE WHEN @OdsCustomerID <> 0 THEN 
'DELETE FROM dbo.LossYearReport
WHERE OdsCustomerId = '+CAST(@OdsCustomerID as VARCHAR(5))+';' ELSE 

'TRUNCATE TABLE dbo.LossYearReport;' END+'

INSERT INTO stg.LossYearReport_Unpartitioned
    (ReportName,
	 OdsCustomerId,
     CustomerName,
     SOJ,
     AgeGroup,
     YOL,
     Year,
     Quarter,
     DateQuarter,
     FormType,
     CoverageType,
     CoverageTypeDesc,
     InjuryNatureId,
	 InjuryNatureDesc,
	 EncounterTypeId,
	 EncounterTypeDesc,
	 Period,
     ServiceGroup,
	 RevenueGroup,
     Gender,
     OutlierCat,
     ClaimantState,
     ClaimantCounty,
     ProviderSpecialty,
     ProviderState,
     Allowed,
     IndAllowed,
     Charged,
     IndCharged,
     UnitsCnt,
     IndUnitsCnt,
     ClaimantCnt,
     IndClaimantCnt,
     DOSCnt,
     IndDOSCnt,
     IsAllowedGreaterThanZero,
	 RunDate
     )
SELECT I.ReportName
		  ,ISNULL(D.CustomerId,0)
	      ,ISNULL(D.CustomerName,'''') DisplayName
	      ,I.SOJ 
	      ,I.AgeGroup
	      ,YEAR(I.DateQuarter) YOL
	      ,YEAR(I.DateQuarter) [Year]
	      ,DATEPART(QQ,I.DateQuarter) Quarter
	      ,I.DateQuarter
	      ,I.FormType
	      ,I.CoverageType
	      ,CASE WHEN LTRIM(RTRIM(ISNULL(CV.LongName,''Uncategorized''))) = '''' THEN ''Uncategorized'' ELSE ISNULL(CV.LongName,''Uncategorized'') END CoverageTypeDesc
	      ,ISNULL(I.InjuryNatureId,0) InjuryNatureId 
	      ,CASE WHEN I.ReportName like ''%Injury%'' THEN 
										 CASE WHEN  I.InjuryNatureId = 24 THEN INJ.NarrativeInformation ELSE ISNULL(INJ.Description,''Unknown'') END 
			  ELSE '''' END AS InjuryNatureDesc 
		  ,EN.EncounterTypeId
		  ,EN.Description
		  ,I.Period
	      ,I.ServiceGroup
		  ,RCC.Description AS RevenueGroup
	      ,I.Gender
	      ,I.Outlier_cat
	      ,I.ClaimantState
	      ,I.ClaimantCounty
	      ,I.ProviderSpecialty
	      ,I.ProviderState
	      ,ISNULL(C.Allowed,0) 
	      ,I.IndAllowed - ISNULL(C.Allowed,0) AS IndAllowed
	      ,ISNULL(C.Charged,0)
	      ,I.IndCharged - ISNULL(C.Charged,0) AS IndCharged
	      ,ISNULL(C.Units,0)
	      ,I.IndUnits - ISNULL(C.Units,0) AS IndUnits
	      ,ISNULL(C.ClaimantCnt,0)
	      ,I.IndClaimantCnt - ISNULL(C.ClaimantCnt,0) AS IndClaimantCnt
	      ,ISNULL(C.DOSCnt,0)
	      ,I.IndDOSCnt - ISNULL(C.DOSCnt,0) AS IndDOSCnt
	      ,I.IsAllowedGreaterThanZero
		  ,GETDATE()
    FROM stg.LossYearReport_Industry I
	LEFT JOIN '+@SourceDatabaseName+'.adm.Customer D
		ON D.CustomerId = '+CASE WHEN @OdsCustomerID <> 0 THEN CAST(@OdsCustomerId AS VARCHAR(3)) ELSE 'D.CustomerId ' END+'
    LEFT JOIN  stg.LossYearReport_Client C
			ON  C.OdsCustomerId = D.CustomerId
			AND C.ReportID = I.ReportID
			AND C.SOJ = I.SOJ
			AND C.IsAllowedGreaterThanZero = I.IsAllowedGreaterThanZero
			AND ISNULL(C.AgeGroup,''-1'') = ISNULL(I.AgeGroup,''-1'')
			AND C.DateQuarter = I.DateQuarter
			AND ISNULL(C.FormType,''-1'') = ISNULL(I.FormType,''-1'')
			AND ISNULL(C.CoverageType,''-1'') = ISNULL(I.CoverageType,''-1'')
			AND ISNULL(C.EncounterTypePriority,-1) = ISNULL(I.EncounterTypePriority,-1)
			AND ISNULL(C.ServiceGroup,'''') = ISNULL(I.ServiceGroup,'''')
			AND ISNULL(C.RevenueCodeCategoryId,-1) = ISNULL(I.RevenueCodeCategoryId,-1)
			AND ISNULL(C.Gender,'''') = ISNULL(I.Gender,'''')
			AND ISNULL(C.Outlier_cat,'''') = ISNULL(I.Outlier_cat,'''')
			AND ISNULL(C.ClaimantState,'''') = ISNULL(I.ClaimantState,'''')
			AND ISNULL(C.ClaimantCounty,'''') = ISNULL(I.ClaimantCounty,'''')
			AND ISNULL(C.ProviderSpecialty,'''') = ISNULL(I.ProviderSpecialty,'''')
			AND ISNULL(C.ProviderState,'''') = ISNULL(I.ProviderState,'''')
			AND ISNULL(C.InjuryNatureId,-1) = ISNULL(I.InjuryNatureId,-1)
			AND ISNULL(C.Period,''-1'') = ISNULL(I.Period,''-1'')
    LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'InjuryNature' ELSE 'if_InjuryNature(@RunPostingGroupAuditId)' END + ' INJ
			ON D.CustomerID = INJ.OdsCustomerId
			AND I.InjuryNatureID = INJ.InjuryNatureID
	LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'EncounterType' ELSE 'if_EncounterType(@RunPostingGroupAuditId)' END + ' EN
			ON D.CustomerID = EN.OdsCustomerId
			AND I.EncounterTypePriority = EN.EncounterTypeId
	LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CoverageType' ELSE 'if_CoverageType(@RunPostingGroupAuditId)' END + ' CV
			ON  D.CustomerID = CV.OdsCustomerId
			AND I.CoverageType = CV.ShortName 
	LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'RevenueCodeCategory' ELSE 'if_RevenueCodeCategory(@RunPostingGroupAuditId)' END + ' RCC 
			ON D.CustomerId = RCC.OdsCustomerId
			AND I.RevenueCodeCategoryId = RCC.RevenueCodeCategoryId;'

EXEC(@SQLScript);

EXEC adm.Rpt_CreateUnpartitionedTableIndexes @OdsCustomerId,@ProcessId,@returnstatus;
EXEC adm.Rpt_SwitchUnpartitionedTable @OdsCustomerId,@ProcessId,'',0,@returnstatus;

END

GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.PPO_ActivityReport_MasterCoverage_BenefitsExhausted') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PPO_ActivityReport_MasterCoverage_BenefitsExhausted
GO

CREATE PROCEDURE dbo.PPO_ActivityReport_MasterCoverage_BenefitsExhausted (
@SourceDatabaseName VARCHAR(50) = 'AcsOds',
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 1)
AS
BEGIN

-- Setup Run parameters
-- DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@RunDate AS DATETIME = GETDATE(),@RunType INT = 1,@if_Date AS DATETIME = GETDATE(),@OdsCustomerId INT = 1;

DECLARE @SQLScript VARCHAR(MAX) = '
DECLARE @start_dt DATETIME, @end_dt DATETIME;
DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;
										
TRUNCATE TABLE stg.DP_PerformanceReport_BenefitsExhaustedReductions;
INSERT INTO stg.DP_PerformanceReport_BenefitsExhaustedReductions(
	 OdsCustomerId
	,billIDNo
	,line_no
	,line_type
	,EndNote
	,Charged
	,allowed
	,BenefitsExhaustedReductions
	,BenefitsExhaustedReductionsFlag)
SELECT DISTINCT
	 b.OdsCustomerId
	,b.billIDNo
	,b.line_no
	,b.linetype
	,CASE WHEN linetype = 1 THEN boen.OverrideEndNote
		  WHEN linetype = 2 THEN bpoen.OverrideEndNote END ''EndNote''
	,b.charged
	,b.allowed
	,CASE WHEN linetype = 1 THEN b.analyzed - b.allowed
		  WHEN linetype = 2 THEN CASE WHEN b.analyzed > b.charged	THEN ( b.charged - b.allowed )
									   ELSE ( b.analyzed - b.allowed ) END END ''reduction''
	,1 AS BenefitsExhaustedReductionsFlag
FROM    stg.PPO_ActivityReport_MasterCoverage_Input b
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Bills_OverrideEndNotes' ELSE 'if_Bills_OverrideEndNotes(@RunPostingGroupAuditId)' END+' boen 
	ON b.OdsCustomerId = boen.OdsCustomerId 
	AND b.billIDNo = boen.billIDNo
	AND b.line_no = boen.line_no
	AND boen.OverrideEndNote = 202
	AND b.linetype = 1
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Bills_Pharm_OverrideEndNotes' ELSE 'if_Bills_Pharm_OverrideEndNotes(@RunPostingGroupAuditId)' END+' bpoen 
	ON b.OdsCustomerId = bpoen.OdsCustomerId 
	AND b.billIDNo = bpoen.billIDNo
	AND b.line_no = bpoen.line_no
	AND bpoen.OverrideEndNote = 202
	AND b.linetype = 2

WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN ' b.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ' ELSE '' END +'b.over_ride != 0
	AND (boen.billIDNo IS NOT NULL OR bpoen.billIDNo IS NOT NULL);'
	
EXEC(@SQLScript)

END 

GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.PPO_ActivityReport_MasterCoverage_Data') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PPO_ActivityReport_MasterCoverage_Data
GO


CREATE PROCEDURE dbo.PPO_ActivityReport_MasterCoverage_Data (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@StartDate AS DATETIME,
@EndDate AS DATETIME,
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@ReportId INT = 1,
@ReportType INT = 1,
@OdsCustomerId INT = 0)
AS
BEGIN

-- Setup Run parameters
-- DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@StartDate AS DATETIME = '20140901',@EndDate AS DATETIME = '20140930',@RunType INT = 1,@if_Date AS DATETIME = GETDATE(),@ReportId INT = 1,@ReportType INT = 1,@OdsCustomerId INT = 1;

DECLARE  @SQLScript VARCHAR(MAX)
		,@WhereClause VARCHAR(MAX);

-- Build Where clause 
SET @WhereClause = CASE WHEN @ReportType IN(1,3) THEN 
CHAR(13)+CHAR(10)+'WHERE '
	+CASE WHEN @OdsCustomerId <> 0 THEN ' BH.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))ELSE '' END
	+CASE WHEN @ReportType = 1 THEN CASE WHEN @OdsCustomerId <> 0 THEN CHAR(13)+CHAR(10)+CHAR(9)+' AND ' ELSE '' END + ' CONVERT(VARCHAR(10),BH.CreateDate,112) BETWEEN '''+CONVERT(VARCHAR(10),@StartDate,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+'''' ELSE '' END
	+CASE WHEN @OdsCustomerId <> 0 OR @ReportType = 1 THEN CHAR(13)+CHAR(10)+CHAR(9)+' AND ' ELSE '' END +' BH.Flags & 16 = 0;'  ELSE '' END


SET @SQLScript = '
DECLARE  @returnstatus INT
DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;

TRUNCATE TABLE stg.PPO_ActivityReport_MasterCoverage_Input;

--Test: SELECT @start_dt,@end_dt
-- Get Bills of interest
IF OBJECT_ID(''tempdb..#BILL_HDR'') IS NOT NULL DROP TABLE #BILL_HDR
SELECT DISTINCT
	 BH.OdsCustomerId
	,BH.BillIDNo
	,BH.CMT_HDR_IDNo
	,CONVERT(VARCHAR(8),BH.CreateDate,112) AS CreateDateformated
	,BH.CreateDate
	,CASE WHEN BH.Flags & 4096 > 0 THEN ''UB-04''  ELSE ''CMS-1500''  END AS Form_Type
	,BH.TypeOfBill
	,BH.CV_Type
	,LEFT(BH.PvdZOS,5) as ProviderZipOfService
INTO #BILL_HDR
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BILL_HDR' ELSE 'if_BILL_HDR(@RunPostingGroupAuditId)' END+' BH'
+@WhereClause+'

	
--Add Lines, Claim and Claimant level InfO.
INSERT INTO stg.PPO_ActivityReport_MasterCoverage_Input( 
		 OdsCustomerId
		,BillIDNo
		,CreateDate
		,Form_Type
		,TypeOfBill
		,CompanyID
		,Company
		,OfficeID
		,Office
		,Coverage
		,SOJ
		,LINE_NO_DISP
		,LINE_NO
		,REF_LINE_NO
		,LineType
		,OVER_RIDE
		,CHARGED
		,ALLOWED
		,PreApportionedAmount
		,ANALYZED
		,UNITS
		,ReportTypeId)
SELECT   BH.OdsCustomerId
		,BH.BillIDNo
		,BH.CreateDate
		,BH.Form_Type
		,BH.TypeOfBill
		,CL.CompanyID
		,ISNULL(CO.CompanyName, ''NA'') AS Company
		,CL.OfficeIndex
		,ISNULL(O.OfcName, ''NA'') AS Office
		,COALESCE(BH.CV_type,CM.CoverageType,CL.CV_Code,'''') AS Coverage
		,CM.CmtStateOfJurisdiction AS SOJ
		,B.LINE_NO_DISP
		,B.LINE_NO
		,B.REF_LINE_NO
		,B.LineType
		,B.OVER_RIDE
		,B.CHARGED
		,B.ALLOWED
		,B.PreApportionedAmount
		,B.ANALYZED
		,B.UNITS
		,'+CAST(@ReportType AS VARCHAR(1))+' AS ReportTypeId

FROM #BILL_HDR BH
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CMT_HDR' ELSE'if_CMT_HDR(@RunPostingGroupAuditId)' END+' CH 
	ON BH.OdsCustomerId = CH.OdsCustomerId
	AND BH.CMT_HDR_IDNo = CH.CMT_HDR_IDNo
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CLAIMANT' ELSE'if_CLAIMANT(@RunPostingGroupAuditId)' END+' CM 
	ON CH.OdsCustomerId = CM.OdsCustomerId
	AND CH.CmtIDNo = CM.CmtIDNo 
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CLAIMS' ELSE'if_CLAIMS(@RunPostingGroupAuditId)' END+' CL 
	ON  CM.OdsCustomerId = CL.OdsCustomerId
	AND CM.ClaimIDNo  = CL.ClaimIDNo
	AND CL.ClaimNo NOT LIKE ''%TEST%''
	AND(CL.OdsCustomerId NOT IN (70,71) OR CL.Status <> ''C'')
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'prf_COMPANY' ELSE'if_prf_COMPANY(@RunPostingGroupAuditId)' END+' CO 
	ON CO.OdsCustomerId = CL.OdsCustomerId
	AND CO.CompanyID = CL.CompanyID
	AND CO.CompanyName NOT LIKE ''%TEST%''
	AND CO.CompanyName NOT LIKE ''%TRAIN%''	
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'prf_Office' ELSE'if_prf_Office(@RunPostingGroupAuditId)' END+' O 
	ON O.OdsCustomerId = CL.OdsCustomerId
	AND O.OfficeID = CL.OfficeIndex
	AND O.OfcName NOT LIKE ''%TEST%''
	AND O.OfcName NOT LIKE ''%TRAIN%''
INNER JOIN (SELECT
				 OdsCustomerId 
				,BillIDNo
				,LINE_NO_DISP
				,LINE_NO
				,REF_LINE_NO
				,1 AS LineType
				,PRC_CD
				,OVER_RIDE
				,ISNULL(CHARGED, 0) CHARGED
				,ISNULL(ALLOWED, 0) ALLOWED
				,PreApportionedAmount
				,ISNULL(ANALYZED, 0) ANALYZED
				,ISNULL(UNITS, 0) UNITS
			FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BILLS' ELSE'if_BILLS(@RunPostingGroupAuditId)' END+' 
			WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN 'OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ' ELSE '' END +'CHARGED IS NOT NULL
			
			UNION 
			
			SELECT 
				 OdsCustomerId
				,BillIDNo
				,LINE_NO_DISP
				,LINE_NO
				,0
				,2 AS LineType
				,NDC
				,Override
				,ISNULL(CHARGED, 0) CHARGED
				,ISNULL(ALLOWED, 0) ALLOWED
				,PreApportionedAmount
				,ISNULL(ANALYZED, 0) ANALYZED
				,ISNULL(UNITS, 0) UNITS
			FROM  '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BILLS_Pharm' ELSE'if_BILLS_Pharm(@RunPostingGroupAuditId)' END+'
			WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN 'OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ' ELSE '' END +'CHARGED IS NOT NULL
			) AS B
	ON BH.OdsCustomerId = B.OdsCustomerId
	AND BH.BillIDNo = B.BillIDNo'
				
EXEC (@SQLScript);

END 

GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.PPO_ActivityReport_MasterCoverage_Reductions_PostVPN') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PPO_ActivityReport_MasterCoverage_Reductions_PostVPN
GO

CREATE PROCEDURE dbo.PPO_ActivityReport_MasterCoverage_Reductions_PostVPN (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 1)
AS
BEGIN

-- Setup Run parameters
-- DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@RunDate AS DATETIME = GETDATE(),@RunType INT = 1,@if_Date AS DATETIME = GETDATE(),@OdsCustomerId INT = 1;

DECLARE @SQLScript VARCHAR(MAX) = '
DECLARE @start_dt DATETIME, @end_dt DATETIME;
DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;

-- Get Bill Line EndNotes	
IF OBJECT_ID(''tempdb..#IntermPostVPNReductions'') IS NOT NULL DROP TABLE #IntermPostVPNReductions	
SELECT DISTINCT
	 m.OdsCustomerId
	,m.billIDNo
	,m.line_no
	,m.linetype
	,m.charged
	,m.allowed
	,ISNULL(r.CategoryIdNo,r2.CategoryIdNo) AS CategoryIdNo
	,m.OVER_RIDE
	,m.analyzed
-- Set Reductions
	,CASE WHEN m.over_ride = 0 AND (((r.CategoryIdNo = 1 AND be2.billIDNo IS NULL) 
									OR (m.linetype = 1 AND be.billIDNo IS NULL))
							  OR ((r2.CategoryIdNo = 1 AND bpe2.billIDNo IS NULL) 
									OR (m.linetype = 2 AND bpe.billIDNo IS NULL AND ctg.billIDNo IS NULL AND (m.charged - ISNULL(m.PreApportionedAmount,m.allowed)) > 0))) THEN (m.charged - ISNULL(m.PreApportionedAmount,m.allowed)) 
		 ELSE 0 END AS ''AnalystReductions''
	,CASE WHEN m.over_ride != 0 AND m.linetype = 1 THEN m.charged - m.analyzed 
		 WHEN m.over_ride != 0 AND m.linetype = 2 THEN CASE WHEN m.analyzed > m.charged THEN 0 ELSE m.charged - m.analyzed  END
		 ELSE 0 END AS ''AnalystORReductions''
	,CASE WHEN (m.over_ride = 0 AND be2.billIDNo IS NOT NULL) OR (m.over_ride = 0 AND bpe2.billIDNo IS NOT NULL AND r2.CategoryIdNo = 1) THEN m.charged - ISNULL(m.PreApportionedAmount,m.allowed) 
		 ELSE 0 END AS ''DuplicateReductions''
	,CASE WHEN m.over_ride = 0 AND (r.CategoryIdNo = 2 OR r2.CategoryIdNo = 2) THEN m.charged - ISNULL(m.PreApportionedAmount,m.allowed) 
		 ELSE 0 END AS ''BenchmarkReductions''
	,CASE WHEN m.over_ride = 0 
			AND (r.CategoryIdNo = 3 OR r2.CategoryIdNo = 3) 
			AND (r.ShortDesc NOT LIKE ''%reviewed%'' OR r2.ShortDesc NOT LIKE ''%reviewed%'') 
			AND p.billIDNo IS NOT NULL THEN p.ALLOWED - ISNULL(m.PreApportionedAmount,m.allowed)
		 ELSE 0 END AS ''VPNReductions''
	,CASE WHEN m.over_ride = 0 AND (r.CategoryIdNo = 4 OR r2.CategoryIdNo = 4) THEN  m.charged - ISNULL(m.PreApportionedAmount,m.allowed) 
		 ELSE 0 END AS ''FeeScheduleReductions'' 
	,CASE WHEN m.over_ride = 0 AND (((r.CategoryIdNo = 5 AND bctg.billIDNo IS NULL) OR (r.CategoryIdNo <> 5 AND bctg.billIDNo IS NOT NULL)) 
			  OR ((r2.CategoryIdNo = 5 AND ctg.billIDNo IS NULL) OR (r2.CategoryIdNo <> 5 AND ctg.billIDNo IS NOT NULL))) THEN  m.charged - ISNULL(m.PreApportionedAmount,m.allowed) 
		 ELSE 0 END AS ''CTGReductions''
	,CASE WHEN m.over_ride != 0 AND m.linetype = 1 THEN m.analyzed - ISNULL(m.PreApportionedAmount,m.allowed)
		 WHEN m.over_ride != 0 AND m.linetype = 2 THEN CASE WHEN m.analyzed > m.charged  THEN (m.charged - ISNULL(m.PreApportionedAmount,m.allowed)) ELSE ( m.analyzed - ISNULL(m.PreApportionedAmount,m.allowed) ) END
		 ELSE 0 END	 ''Overrides''
	,CASE WHEN m.over_ride = 0 
			AND (r.CategoryIdNo = 3 OR r2.CategoryIdNo = 3) 
			AND (r.ShortDesc NOT LIKE ''%reviewed%'' OR r2.ShortDesc NOT LIKE ''%reviewed%'') 
			AND p.billIDNo IS NOT NULL THEN 1
		 ELSE 0 END ''VPNReductionsFlag''
	,CASE WHEN (m.over_ride = 0 AND be2.billIDNo IS NOT NULL) OR (m.over_ride = 0 AND bpe2.billIDNo IS NOT NULL AND r2.CategoryIdNo = 1) THEN 1 
		 ELSE 0 END AS ''DuplicateReductionsFlag''

INTO #IntermPostVPNReductions			 
FROM stg.PPO_ActivityReport_MasterCoverage_Input m
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BILLS_Endnotes' ELSE 'if_BILLS_Endnotes(@RunPostingGroupAuditId)' END+' be 
	ON be.OdsCustomerId = m.OdsCustomerId
	AND be.billIDNo = m.billIDNo
    AND be.line_no = m.line_no
    AND m.linetype = 1
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'rsn_REASONS' ELSE 'if_rsn_REASONS(@RunPostingGroupAuditId)' END+' r 
	ON r.OdsCustomerId = be.OdsCustomerId
	AND r.ReasonNumber = be.EndNote
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BILLS_Endnotes' ELSE 'if_BILLS_Endnotes(@RunPostingGroupAuditId)' END+' be2
	ON be2.OdsCustomerId = m.OdsCustomerId
	AND be2.billIDNo = m.billIDNo
	AND be2.line_no = m.line_no
	AND m.linetype = 1
    AND be2.EndNote = 4
	AND m.allowed = 0
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Bills_CTG_Endnotes' ELSE 'if_Bills_CTG_Endnotes(@RunPostingGroupAuditId)' END+' bctg
    ON bctg.OdsCustomerId = m.OdsCustomerId
    AND bctg.billIDNo = m.billIDNo
    AND bctg.line_no = m.line_no 
    AND m.linetype = 1
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Bills_Pharm_Endnotes' ELSE 'if_Bills_Pharm_Endnotes(@RunPostingGroupAuditId)' END+' bpe 
	ON bpe.OdsCustomerId = m.OdsCustomerId
	AND bpe.billIDNo = m.billIDNo
    AND bpe.line_no = m.line_no
    AND m.linetype = 2
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'rsn_REASONS' ELSE 'if_rsn_REASONS(@RunPostingGroupAuditId)' END+' r2 
	ON r2.OdsCustomerId = bpe.OdsCustomerId
	AND r2.ReasonNumber = bpe.EndNote
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Bills_Pharm_Endnotes' ELSE 'if_Bills_Pharm_Endnotes(@RunPostingGroupAuditId)' END+' bpe2 
	ON bpe2.OdsCustomerId = m.OdsCustomerId
	AND bpe2.billIDNo = m.billIDNo
    AND bpe2.line_no = m.line_no
    AND m.linetype = 2
    AND bpe2.EndNote = 4
    AND m.allowed = 0 
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Bills_Pharm_CTG_Endnotes' ELSE 'if_Bills_Pharm_CTG_Endnotes(@RunPostingGroupAuditId)' END+' ctg
    ON ctg.OdsCustomerId = m.OdsCustomerId
    AND ctg.billIDNo = m.billIDNo
    AND ctg.line_no = m.line_no 
    AND m.linetype = 2
LEFT OUTER JOIN rpt.PrePPOBillInfo_Endnotes p
	ON p.OdsCustomerId = m.OdsCustomerId
	AND p.billIDNo = m.billIDNo
    AND p.line_no = m.line_no
    AND p.linetype = m.linetype
'+CASE WHEN @OdsCustomerId <> 0 THEN 'WHERE m.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +';

-- When Inserting the data into the table, rank by category so can use to zero-out repeated values.
TRUNCATE TABLE stg.DP_PerformanceReport_PostVPNReductions;
INSERT INTO stg.DP_PerformanceReport_PostVPNReductions(
	 OdsCustomerId
	,billIDNo
	,line_no
	,line_type
	,charged
	,allowed
	,categoryIDNo
	,OVER_RIDE
	,analyzed
	,AnalystReductions
	,AnalystORReductions
	,DuplicateReductions
	,BenchmarkReductions
	,VPNReductions
	,FeeScheduleReductions
	,CTGReductions
	,Overrides
	,VPNReductionsFlag
	,DuplicateReductionsFlag
	,LLevel )
SELECT OdsCustomerId
	,billIDNo
	,line_no
	,linetype
	,charged
	,allowed
	,categoryIDNo
	,OVER_RIDE
	,analyzed
	,AnalystReductions
	,AnalystORReductions
	,DuplicateReductions
	,BenchmarkReductions
	,VPNReductions
	,FeeScheduleReductions
	,CTGReductions
	,Overrides
	,VPNReductionsFlag
	,DuplicateReductionsFlag
	,Row_Number() OVER (PARTITION BY OdsCustomerId,billIDNo,line_no,linetype ORDER BY categoryIDNo) LLevel 
FROM #IntermPostVPNReductions   

-- Update these so they are only at the line level, else will result in duplicates when summed later.    
UPDATE stg.DP_PerformanceReport_PostVPNReductions
SET  AnalystORReductions = 0
	,Overrides = 0
	,DuplicateReductions  = 0
WHERE LLevel <> 1;'

EXEC(@SQLScript)

END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.PPO_ActivityReport_MasterCoverage_Reductions_PreVPN') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PPO_ActivityReport_MasterCoverage_Reductions_PreVPN
GO

CREATE PROCEDURE dbo.PPO_ActivityReport_MasterCoverage_Reductions_PreVPN (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 1)
AS
BEGIN

-- Setup Run parameters
-- DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@RunDate AS DATETIME = GETDATE(),@RunType INT = 1,@if_Date AS DATETIME = GETDATE(),@OdsCustomerId INT = 1;

DECLARE @SQLScript VARCHAR(MAX) = '
DECLARE @start_dt DATETIME, @end_dt DATETIME;
DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;
										
-- Get Bill Line EndNotes	
IF OBJECT_ID(''tempdb..#IntermPreVPNReductions'') IS NOT NULL DROP TABLE #IntermPreVPNReductions	
SELECT DISTINCT  
	 b.OdsCustomerId
	,b.billIDNo
	,b.line_no
	,b.linetype
	,b.charged
	,pb.ALLOWED
	,r3.CategoryIdNo
	,pb.OVER_RIDE
--	,e.StringText AS OriginalEndnote 
	,CASE WHEN pb.Endnotes = ''4'' THEN 1
		  ELSE 0 END AS IsZeroAllowedDuplicateLine
	,pb.ANALYZED
-- Set Reductions
	,CASE WHEN pb.OVER_RIDE = 0 AND r3.CategoryIdNo = 1 THEN b.charged - pb.ALLOWED
		  WHEN pb.OVER_RIDE = 0 AND r3.CategoryIdNo IS NULL THEN b.charged - pb.ALLOWED 
		  WHEN pb.OVER_RIDE = 0 AND r3.CategoryIdNo NOT IN (1,2,3,4,5) THEN b.charged - pb.ALLOWED 
		  ELSE 0.0 END AS ''AnalystReductions'' 
	,CASE WHEN pb.OVER_RIDE <> 0 AND b.linetype = 1 THEN b.charged - pb.ANALYZED
		  WHEN pb.OVER_RIDE <> 0 AND b.linetype = 2 THEN ( CASE WHEN pb.ANALYZED > b.charged THEN 0 ELSE (b.charged - pb.ANALYZED)END ) 
          ELSE 0 END AS ''AnalystORReductions''
-- Mirroring the Duplicate reduction logic here
    ,CASE WHEN pb.OVER_RIDE = 0 AND b.linetype = 1 AND pb.Endnotes = ''4'' THEN b.charged - pb.allowed
	      WHEN pb.OVER_RIDE = 0 AND b.linetype = 2 AND pb.Endnotes = ''4'' AND pb.allowed = 0 AND r3.categoryIDNo = 1 THEN b.charged - pb.allowed
		  ELSE 0 END AS ''DuplicateReductions''
	,CASE WHEN r3.CategoryIdNo = 2  AND pb.OVER_RIDE = 0 THEN b.charged - pb.allowed 
		  ELSE 0 END AS ''BenchmarkReductions''
	,CASE WHEN r3.CategoryIdNo = 3  AND pb.OVER_RIDE = 0 THEN b.charged - pb.allowed 
		  ELSE 0 END AS ''VPNReductions''
	,CASE WHEN r3.CategoryIdNo = 4  AND pb.OVER_RIDE = 0 THEN b.charged - pb.allowed 
		  ELSE 0 END AS ''FeeScheduleReductions''
	,CASE WHEN r3.CategoryIdNo = 5  AND pb.OVER_RIDE = 0 THEN b.charged - pb.allowed 
		  ELSE 0 END AS ''CTGReductions''
	,CASE WHEN pb.OVER_RIDE <> 0 THEN CASE WHEN b.linetype = 1 THEN (pb.analyzed - pb.allowed)
										   WHEN b.linetype = 2 THEN (CASE WHEN pb.analyzed > b.charged THEN (b.charged - pb.allowed) ELSE (pb.analyzed - pb.allowed)END)
										   ELSE 0 END   
		  ELSE 0 END AS ''Overrides''
	,0 AS ''VPNReductionsFlag''
	,0 AS ''DuplicateReductionsFlag''
	,COALESCE(r1.ReasonNumber,r2.ReasonNumber,0) ReasonNumber
INTO #IntermPreVPNReductions
FROM stg.PPO_ActivityReport_MasterCoverage_Input b
INNER JOIN rpt.PrePPOBillInfo_Endnotes pb
	ON b.OdsCustomerId = pb.OdsCustomerId
	AND b.billIDNo = pb.billIDNo
	AND b.line_no = pb.line_no
	AND b.linetype = pb.linetype
	AND b.over_ride = 0
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BILLS_Endnotes' ELSE 'if_BILLS_Endnotes(@RunPostingGroupAuditId)' END+' be 
	ON be.OdsCustomerId = b.OdsCustomerId
	AND be.billIDNo = b.billIDNo
	AND be.line_no = b.line_no
	AND b.linetype = 1
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Bills_Pharm_Endnotes' ELSE 'if_Bills_Pharm_Endnotes(@RunPostingGroupAuditId)' END+' bpe 
	ON bpe.OdsCustomerId = b.OdsCustomerId
	AND bpe.billIDNo = b.billIDNo
    AND bpe.line_no = b.line_no
    AND b.linetype = 2
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'rsn_REASONS' ELSE 'if_rsn_REASONS(@RunPostingGroupAuditId)' END+' r1 
	ON r1.OdsCustomerId = bpe.OdsCustomerId
	AND r1.ReasonNumber = bpe.EndNote
	AND r1.CategoryIdNo = 3
	AND r1.ShortDesc NOT LIKE ''%reviewed%''
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'rsn_REASONS' ELSE 'if_rsn_REASONS(@RunPostingGroupAuditId)' END+' r2 
	ON r2.OdsCustomerId = be.OdsCustomerId
	AND r2.ReasonNumber = be.EndNote
	AND r2.CategoryIdNo = 3
	AND r2.ShortDesc NOT LIKE ''%reviewed%''
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'rsn_REASONS' ELSE 'if_rsn_REASONS(@RunPostingGroupAuditId)' END+' r3 
	ON pb.OdsCustomerId = r3.OdsCustomerId
	AND pb.Endnotes = r3.ReasonNumber
'+CASE WHEN @OdsCustomerId <> 0 THEN 'WHERE b.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +';

	  
TRUNCATE TABLE stg.DP_PerformanceReport_PreVPNReductions;
INSERT INTO stg.DP_PerformanceReport_PreVPNReductions(
	 OdsCustomerId
	,billIDNo
	,line_no
	,line_type
	,charged
	,allowed
	,categoryIDNo
	,OVER_RIDE
	,IsZeroAllowedDuplicateLine
	,analyzed
	,AnalystReductions
	,AnalystORReductions
	,DuplicateReductions
	,BenchmarkReductions
	,VPNReductions
	,FeeScheduleReductions
	,CTGReductions
	,Overrides
	,VPNReductionsFlag
	,DuplicateReductionsFlag
	,LLevel)
SELECT
	 OdsCustomerId
	,billIDNo
	,line_no
	,linetype
	,charged
	,allowed
	,categoryIDNo
	,OVER_RIDE
	,IsZeroAllowedDuplicateLine
	,analyzed
	,AnalystReductions
	,AnalystORReductions
	,DuplicateReductions
	,BenchmarkReductions
	,VPNReductions
	,FeeScheduleReductions
	,CTGReductions
	,Overrides
	,VPNReductionsFlag
	,DuplicateReductionsFlag
	,Row_Number() OVER (PARTITION BY OdsCustomerId,billIDNo,line_no,linetype ORDER BY CategoryIdNo) LLevel
FROM #IntermPreVPNReductions
WHERE ReasonNumber <> 0;
	  
-- Update these so they are only at the line level, else will result in duplicates when summed later.    
UPDATE stg.DP_PerformanceReport_PreVPNReductions
SET  AnalystORReductions = 0
	,Overrides = 0
WHERE LLevel <> 1;'

EXEC(@SQLScript);

END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.PPO_ActivityReport_MasterCoverage_Rollup') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PPO_ActivityReport_MasterCoverage_Rollup
GO

CREATE PROCEDURE dbo.PPO_ActivityReport_MasterCoverage_Rollup(
@SourceDatabaseName VARCHAR(50)='AcsOds',
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@ReportType INT = 1,
@OdsCustomerID INT = 0,
@TargetDatabaseName VARCHAR(50) = 'ReportDB')
AS
BEGIN
	--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@TargetDatabaseName VARCHAR(50) = 'ReportDB',@ReportType INT = 1,@RunType INT = 0,@if_Date AS DATETIME = GETDATE(),@OdsCustomerID INT = 0
	DECLARE @SQLScript VARCHAR(MAX);
	
	SET @SQLScript = '
	DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;
	DECLARE @StartOfMonth DATETIME = DATEADD(MONTH, DATEDIFF(MONTH, 0, '''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+'''), 0);

	DELETE FROM '+@TargetDatabaseName+'.dbo.PPO_ActivityReport_MasterCoverage_Output
	WHERE ((ReportTypeID = 2 AND StartOfMonth < @StartOfMonth)
	OR ReportTypeID  = '+CAST(@ReportType AS VARCHAR(2))+')'+CASE WHEN @OdsCustomerID <> 0 THEN ' AND OdsCustomerId = '+CAST(@OdsCustomerID as VARCHAR(5)) ELSE '' END +';

	IF OBJECT_ID(''tempdb..#BillsWithDuplicateLineCount'') IS NOT NULL	DROP TABLE #BillsWithDuplicateLineCount;
	SELECT OdsCustomerId
		,billIDNo
		,COUNT(1) LineCount
		,SUM(CASE WHEN DuplicateReductionsFlag <> 0 THEN 1 ELSE 0 END) DuplicateLineCount
	INTO #BillsWithDuplicateLineCount
	FROM stg.DP_PerformanceReport_linelevelprioritized
	GROUP BY OdsCustomerId,billIDNo
	HAVING SUM(CASE WHEN DuplicateReductionsFlag <> 0 THEN 1 ELSE 0 END) = COUNT(1); 
	
	IF OBJECT_ID(''tempdb..#tempConsolidatedReductions'') IS NOT NULL	DROP TABLE #tempConsolidatedReductions
	SELECT P.OdsCustomerId
		,P.billIDNo
		,B.billIDNo AS DuplicateBillidNo
		,P.line_no
		,P.line_type
		,P.BenefitsExhaustedReductions
		,CASE WHEN  (ISNULL(P.AnalystReductions,0) + ISNULL(P.AnalystORReductions,0)) = 0 
				AND P.FeeScheduleReductions = 0 
				AND P.BenchmarkReductions = 0
				AND P.VPNReductions = 0 
				AND P.CTGReductions = 0 
				AND P.DuplicateReductions = 0 
				AND P.BenefitsExhaustedReductions = 0
				AND P.Overrides = 0 THEN 1 ELSE 0 END AS RecompAnalystReductions
		,ISNULL(P.AnalystReductions,0) + ISNULL(P.AnalystORReductions,0) AnalystReductions
		,P.AnalystORReductions
		,P.DuplicateReductions
		,P.BenchmarkReductions
		,P.VPNReductions
		,P.FeeScheduleReductions
		,P.CTGReductions
		,P.Overrides
		,P.VPNReductionsFlag
		,P.DuplicateReductionsFlag
		,P.BenefitsExhaustedReductionsFlag
		
	INTO #tempConsolidatedReductions	
	FROM stg.DP_PerformanceReport_linelevelprioritized P
	LEFT OUTER JOIN #BillsWithDuplicateLineCount B
		ON P.OdsCustomerId = B.OdsCustomerId
		AND P.billIDNo = B.billIDNo;
		
	-- Indexes On Filtered Data
	CREATE CLUSTERED INDEX Idx_CustomerIdBillIdNoLineNoLineType 
	ON #tempConsolidatedReductions(OdsCustomerId,BillIdNo,Line_no,Line_type)
	WITH (DATA_COMPRESSION = PAGE);
	
	IF OBJECT_ID(''tempdb..#PPO_ActivityReport_MasterCoverage_rollup'') IS NOT NULL	DROP TABLE #PPO_ActivityReport_MasterCoverage_rollup
	SELECT m.OdsCustomerId
		,DATEADD(MONTH, DATEDIFF(MONTH, 0, m.CreateDate), 0) AS StartOfMonth
		,C.CustomerName AS Customer
		,YEAR(m.CreateDate) AS Year
		,MONTH(m.CreateDate) AS Month
		,ISNULL(m.Company, ''NA'') AS Company
		,ISNULL(m.Office, ''NA'') AS Office
		,ISNULL(m.SOJ, ''NA'') AS SOJ
		,ISNULL(m.Coverage, ''NA'') AS Coverage
		,ISNULL(m.Form_Type, ''NA'') AS Form_Type
		,m.billIDNo
		,m.line_no
		,m.units
		,m.charged
		,m.allowed
		,r.DuplicateReductions 
		,CASE WHEN r.RecompAnalystReductions  = 1 AND (m.charged - m.allowed > 0) THEN (m.charged - m.allowed) ELSE r.AnalystReductions END RecompAnalystReductions 
		,r.FeeScheduleReductions 
		,r.BenchmarkReductions 
		,r.CTGReductions
		,CASE WHEN r.DuplicateReductions <> 0 THEN m.BillIDNo END AS BillsWithOneOrMoreDuplicateLines
		,CASE WHEN r.DuplicateReductions <> 0 THEN m.BillIDNo END AS PartialDuplicateBills
		,r.DuplicateBillidNo
		,CASE WHEN r.DuplicateReductionsFlag <> 0 THEN 1 ELSE 0 END Dup_Lines
		,CASE WHEN r.BenefitsExhaustedReductionsFlag <> 0 THEN m.BillIDNo END BenefitsExhausted_Bills
		,CASE WHEN r.BenefitsExhaustedReductionsFlag <> 0 THEN 1 ELSE 0 END BenefitsExhausted_Lines
		,r.BenefitsExhaustedReductions
		,CASE WHEN r.RecompAnalystReductions  = 1 AND (m.charged - m.allowed > 0) THEN (m.charged - m.allowed) ELSE r.AnalystReductions END AnalystReductions
		,r.VPNReductions
		,r.Overrides

	INTO #PPO_ActivityReport_MasterCoverage_rollup
	FROM stg.PPO_ActivityReport_MasterCoverage_Input m
	INNER JOIN #tempConsolidatedReductions r ON m.OdsCustomerId = r.OdsCustomerId
		AND m.billIDNo = r.billIDNo
		AND m.line_no = r.line_no
		AND m.linetype = r.line_type
	INNER JOIN '+@SourceDatabaseName+'.adm.Customer C
		ON m.OdsCustomerId = c.CustomerId
	LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CustomerBillExclusion' ELSE'if_CustomerBillExclusion(@RunPostingGroupAuditId)' END+' ex 
		ON C.CustomerDatabase = ex.Customer
		AND m.billIDNo = ex.billIDNo
		AND ex.ReportID = 11
	
	WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN ' m.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ' ELSE '' END +'ex.billIDNo IS NULL;
		
	CREATE CLUSTERED INDEX Idx_CustomerIdBillIdNoLineNoLineType 
	ON #PPO_ActivityReport_MasterCoverage_rollup(OdsCustomerId,StartOfMonth,Customer,Year,Month,Company,Office,SOJ,Coverage,Form_Type)
	WITH (DATA_COMPRESSION = PAGE);
		
	
	INSERT INTO '+@TargetDatabaseName+'.dbo.PPO_ActivityReport_MasterCoverage_Output(
		 OdsCustomerId
		,StartOfMonth
		,Customer
		,Year
		,Month
		,Company
		,Office
		,SOJ
		,Coverage
		,Form_Type
		,Total_Bills
		,Total_Provider_Charges
		,Total_Bill_Review_Reductions
		,ReportTypeID
		,RunDate)	
	SELECT
		 OdsCustomerId
		,StartOfMonth
		,Customer
		,Year
		,Month
		,Company
		,Office
		,SOJ
		,Coverage
		,Form_Type
		,COUNT(DISTINCT billIDNo) Total_Bills
		,SUM(charged) Total_Provider_Charges
		,SUM(DuplicateReductions) 
			+ SUM(RecompAnalystReductions)
			+ SUM(FeeScheduleReductions) 
			+ SUM(BenchmarkReductions) 
			+ SUM(CTGReductions) Total_Bill_Review_Reductions
		,'+CAST(@ReportType AS VARCHAR(2))+' AS ReportTypeID
		,GETDATE()
	FROM #PPO_ActivityReport_MasterCoverage_rollup R1
	GROUP BY OdsCustomerId
		,StartOfMonth
		,Customer
		,Year
		,Month
		,Company
		,Office
		,SOJ
		,Coverage
		,Form_Type
	OPTION (HASH GROUP);'
		
	EXEC (@SQLScript);	
	
END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.PPO_ActivityReport_MasterCoverage_Rollup_Prediction') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PPO_ActivityReport_MasterCoverage_Rollup_Prediction
GO

CREATE PROCEDURE dbo.PPO_ActivityReport_MasterCoverage_Rollup_Prediction(
@SourceDatabaseName VARCHAR(50)='AcsOds',
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@ReportType INT = 2,
@OdsCustomerID INT = 0,
@TargetDatabaseName VARCHAR(50) = 'ReportDB')
AS
BEGIN
	--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@TargetDatabaseName VARCHAR(50) = 'ReportDB',@ReportType INT = 2,@RunType INT = 0,@if_Date AS DATETIME = GETDATE(),@OdsCustomerID INT = 0
	DECLARE @SQLScript VARCHAR(MAX);
		
	SET @SQLScript = CAST('' AS VARCHAR(MAX)) + '

	DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;
	DECLARE @StartOfMonth DATETIME = DATEADD(MONTH, DATEDIFF(MONTH, 0, '''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+'''), 0);
	
	-- Get Copy of previous prediction
	INSERT INTO '+@TargetDatabaseName+'.dbo.PPO_ActivityReport_MasterCoverage_Flashback
	SELECT * 
	FROM '+@TargetDatabaseName+'.dbo.PPO_ActivityReport_MasterCoverage_Output
	WHERE StartOfMonth >= @StartOfMonth
	AND ReportTypeID  = '+CAST(@ReportType AS VARCHAR(2))+CASE WHEN @OdsCustomerID <> 0 THEN ' AND OdsCustomerId = '+CAST(@OdsCustomerID as VARCHAR(5)) ELSE '' END +';

	-- Cleanup Previous Prediction
	DELETE FROM '+@TargetDatabaseName+'.dbo.PPO_ActivityReport_MasterCoverage_Output
	WHERE StartOfMonth >= @StartOfMonth
	AND ReportTypeID  = '+CAST(@ReportType AS VARCHAR(2))+CASE WHEN @OdsCustomerID <> 0 THEN ' AND OdsCustomerId = '+CAST(@OdsCustomerID as VARCHAR(5)) ELSE '' END +';

	
	DECLARE  @CurrentStartOfMonth DATETIME
			,@CutOffRunDate DATETIME  = (SELECT MAX(RunDate) FROM '+@TargetDatabaseName+'.dbo.PPO_ActivityReport_MasterCoverage_Output);
			
	SET @CutOffRunDate = @CutOffRunDate - DATEPART(dw, @CutOffRunDate) 
	SET @CurrentStartOfMonth = DATEADD(MONTH, DATEDIFF(MONTH, 0, @CutOffRunDate), 0)
  
	DECLARE  @TotalWeekDaysToDate INT 
			,@WeekEndDaysToDate INT
			,@WeekEndDaysInMonth INT
			,@WeekDaysRemaining INT
			,@WeekendDaysRemaining INT
			,@WeekEndDaysLastMonth INT
			,@WeekDaysLastMonth INT
			,@HolidaysInMonth INT
			,@HolidaysToDate INT;

	IF OBJECT_ID(''tempdb..#WeekEndsAndHolidays'') IS NOT NULL	DROP TABLE #WeekEndsAndHolidays
	SELECT DISTINCT 
			 DayOfWeekDate
			,DayName
	INTO #WeekEndsAndHolidays
	FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'WeekEndsAndHolidays' ELSE'if_WeekEndsAndHolidays(@RunPostingGroupAuditId)' END+'

	SELECT @WeekEndDaysToDate = SUM(CASE WHEN DayOfWeekDate <= @CutOffRunDate AND DayName IN (''SAT'',''SUN'') AND (MONTH(DayOfWeekDate) = MONTH(@CurrentStartOfMonth) AND YEAR(DayOfWeekDate) = YEAR(@CurrentStartOfMonth)) THEN 1 ELSE 0 END)
		  ,@WeekEndDaysInMonth = SUM(CASE WHEN DayName IN (''SAT'',''SUN'',''HOL'') AND (MONTH(DayOfWeekDate) = MONTH(@CurrentStartOfMonth) AND YEAR(DayOfWeekDate) = YEAR(@CurrentStartOfMonth)) THEN 1 ELSE 0 END)
		  ,@HolidaysInMonth = SUM(CASE WHEN DayName = ''HOL'' AND (MONTH(DayOfWeekDate) = MONTH(@CurrentStartOfMonth) AND YEAR(DayOfWeekDate) = YEAR(@CurrentStartOfMonth)) THEN 1 ELSE 0 END)
		  ,@HolidaysToDate = SUM(CASE WHEN DayOfWeekDate <= @CutOffRunDate AND DayName IN (''HOL'') AND (MONTH(DayOfWeekDate) = MONTH(@CurrentStartOfMonth) AND YEAR(DayOfWeekDate) = YEAR(@CurrentStartOfMonth)) THEN 1 ELSE 0 END)
		  ,@WeekEndDaysLastMonth = SUM(CASE WHEN DayName IN (''SAT'',''SUN'',''HOL'') AND (MONTH(DayOfWeekDate) = MONTH(DATEADD(mm,-1,@CurrentStartOfMonth)) AND YEAR(DayOfWeekDate) = YEAR(DATEADD(mm,-1,@CurrentStartOfMonth))) THEN 1 ELSE 0 END)
		  ,@WeekDaysLastMonth = DAY(EOMONTH(DATEADD(MONTH,-1,@CurrentStartOfMonth)))
			-SUM(CASE WHEN DayName IN (''SAT'',''SUN'',''HOL'') AND (MONTH(DayOfWeekDate) = MONTH(DATEADD(mm,-1,@CurrentStartOfMonth)) AND YEAR(DayOfWeekDate) = YEAR(DATEADD(mm,-1,@CurrentStartOfMonth))) THEN 1 ELSE 0 END)
			
	FROM #WeekEndsAndHolidays

	SELECT @TotalWeekDaysToDate = DATEDIFF(DAY,@CurrentStartOfMonth,@CutOffRunDate) + 1 - @WeekEndDaysToDate - @HolidaysToDate
	
	SELECT @WeekEndDaysToDate =  @WeekEndDaysToDate + @HolidaysToDate
		  ,@WeekendDaysRemaining  = @WeekEndDaysInMonth - @WeekEndDaysToDate + (@HolidaysInMonth-@HolidaysToDate)

	SELECT @WeekDaysRemaining = DATEDIFF(DAY,@CurrentStartOfMonth,EOMONTH(@CurrentStartOfMonth)) + 1 - @TotalWeekDaysToDate - @WeekEndDaysToDate - @WeekendDaysRemaining

--	SELECT @WeekEndDaysToDate		  ,@TotalWeekDaysToDate		  ,@WeekendDaysRemaining		  ,@WeekDaysRemaining

	IF OBJECT_ID(''tempdb..#BillsWithDuplicateLineCount'') IS NOT NULL	DROP TABLE #BillsWithDuplicateLineCount;
	SELECT OdsCustomerId
		,billIDNo
		,COUNT(1) LineCount
		,SUM(CASE WHEN DuplicateReductionsFlag <> 0 THEN 1 ELSE 0 END) DuplicateLineCount
	INTO #BillsWithDuplicateLineCount
	FROM stg.DP_PerformanceReport_linelevelprioritized
	GROUP BY OdsCustomerId,billIDNo
	HAVING SUM(CASE WHEN DuplicateReductionsFlag <> 0 THEN 1 ELSE 0 END) = COUNT(1); 
	
	IF OBJECT_ID(''tempdb..#tempConsolidatedReductions'') IS NOT NULL	DROP TABLE #tempConsolidatedReductions
	SELECT P.OdsCustomerId
		,P.billIDNo
		,B.billIDNo AS DuplicateBillidNo
		,P.line_no
		,P.line_type
		,P.BenefitsExhaustedReductions
		,CASE WHEN  (ISNULL(P.AnalystReductions,0) + ISNULL(P.AnalystORReductions,0)) = 0 
				AND P.FeeScheduleReductions = 0 
				AND P.BenchmarkReductions = 0
				AND P.VPNReductions = 0 
				AND P.CTGReductions = 0 
				AND P.DuplicateReductions = 0 
				AND P.BenefitsExhaustedReductions = 0
				AND P.Overrides = 0 THEN 1 ELSE 0 END AS RecompAnalystReductions
		,ISNULL(P.AnalystReductions,0) + ISNULL(P.AnalystORReductions,0) AnalystReductions
		,P.AnalystORReductions
		,P.DuplicateReductions
		,P.BenchmarkReductions
		,P.VPNReductions
		,P.FeeScheduleReductions
		,P.CTGReductions
		,P.Overrides
		,P.VPNReductionsFlag
		,P.DuplicateReductionsFlag
		,P.BenefitsExhaustedReductionsFlag
		
	INTO #tempConsolidatedReductions	
	FROM stg.DP_PerformanceReport_linelevelprioritized P
	LEFT OUTER JOIN #BillsWithDuplicateLineCount B
		ON P.OdsCustomerId = B.OdsCustomerId
		AND P.billIDNo = B.billIDNo;
		
	-- Indexes On Filtered Data
	CREATE CLUSTERED INDEX Idx_CustomerIdBillIdNoLineNoLineType 
	ON #tempConsolidatedReductions(OdsCustomerId,BillIdNo,Line_no,Line_type)
	WITH (DATA_COMPRESSION = PAGE);

	
	IF OBJECT_ID(''tempdb..#PPO_ActivityReport_MasterCoverage_rollup'') IS NOT NULL	DROP TABLE #PPO_ActivityReport_MasterCoverage_rollup									
	SELECT m.OdsCustomerId
		,DATEADD(MONTH, DATEDIFF(MONTH, 0, m.CreateDate), 0) AS StartOfMonth
		,m.CreateDate
		,C.CustomerName AS Customer
		,YEAR(m.CreateDate) AS Year
		,MONTH(m.CreateDate) AS Month
		,ISNULL(m.Company, ''NA'') AS Company
		,ISNULL(m.Office, ''NA'') AS Office
		,ISNULL(m.SOJ, ''NA'') AS SOJ
		,ISNULL(m.Coverage, ''NA'') AS Coverage
		,ISNULL(m.Form_Type, ''NA'') AS Form_Type
		,m.billIDNo
		,m.line_no
		,m.units
		,m.charged
		,m.allowed
		,r.DuplicateReductions 
		,CASE WHEN r.RecompAnalystReductions  = 1 AND (m.charged - m.allowed > 0) THEN (m.charged - m.allowed) ELSE r.AnalystReductions END RecompAnalystReductions 
		,r.FeeScheduleReductions 
		,r.BenchmarkReductions 
		,r.CTGReductions
		,CASE WHEN r.DuplicateReductions <> 0 THEN m.BillIDNo END AS BillsWithOneOrMoreDuplicateLines
		,CASE WHEN r.DuplicateReductions <> 0 THEN m.BillIDNo END AS PartialDuplicateBills
		,r.DuplicateBillidNo
		,CASE WHEN r.DuplicateReductionsFlag <> 0 THEN 1 ELSE 0 END Dup_Lines
		,CASE WHEN r.BenefitsExhaustedReductionsFlag <> 0 THEN m.BillIDNo END BenefitsExhausted_Bills
		,CASE WHEN r.BenefitsExhaustedReductionsFlag <> 0 THEN 1 ELSE 0 END BenefitsExhausted_Lines
		,r.BenefitsExhaustedReductions
		,CASE WHEN r.RecompAnalystReductions  = 1 AND (m.charged - m.allowed > 0) THEN (m.charged - m.allowed) ELSE r.AnalystReductions END AnalystReductions
		,r.VPNReductions
		,r.Overrides

	INTO #PPO_ActivityReport_MasterCoverage_rollup
	FROM stg.PPO_ActivityReport_MasterCoverage_Input m
	INNER JOIN #tempConsolidatedReductions r ON m.OdsCustomerId = r.OdsCustomerId
		AND m.billIDNo = r.billIDNo
		AND m.line_no = r.line_no
		AND m.linetype = r.line_type
	INNER JOIN '+@SourceDatabaseName+'.adm.Customer C
		ON m.OdsCustomerId = c.CustomerId
	LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CustomerBillExclusion' ELSE'if_CustomerBillExclusion(@RunPostingGroupAuditId)' END+' ex 
		ON C.CustomerDatabase = ex.Customer
		AND m.billIDNo = ex.billIDNo
		AND ex.ReportID = 1
	
	WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN ' m.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ' ELSE '' END +'ex.billIDNo IS NULL

-- Get Records with create date in current month only
		AND DATEDIFF(MONTH,EOMONTH(m.CreateDate),EOMONTH(@CurrentStartOfMonth)) <= 1 ;
		
	CREATE CLUSTERED INDEX Idx_CustomerIdBillIdNoLineNoLineType 
	ON #PPO_ActivityReport_MasterCoverage_rollup(OdsCustomerId,StartOfMonth,Customer,Year,Month,Company,Office,SOJ,Coverage,Form_Type)
	WITH (DATA_COMPRESSION = PAGE);

-- Get Rollup broken donw by weekday and weekends for last two months		
	
	;WITH cte_PPO_ActivityReport_MasterCoverage_Output_WeekDayType	AS(
	SELECT
		 R1.OdsCustomerId
		,StartOfMonth
		,Customer
		,Year
		,Month
		,Company
		,Office
		,SOJ
		,Coverage
		,Form_Type
		,COUNT(DISTINCT (CASE WHEN WeekEndsAndHolidayId IS NOT NULL THEN billIDNo END)) + 0.0 Total_Bills_WeekEnd
		,COUNT(DISTINCT (CASE WHEN WeekEndsAndHolidayId IS NULL THEN  billIDNo END)) + 0.0 Total_Bills_WeekDay
		,SUM(CASE WHEN WeekEndsAndHolidayId IS NOT NULL THEN charged ELSE 0 END) Total_Provider_Charges_WeekEnd
		,SUM(CASE WHEN WeekEndsAndHolidayId IS NULL THEN charged ELSE 0 END) Total_Provider_Charges_WeekDay
		,SUM(CASE WHEN WeekEndsAndHolidayId IS NOT NULL THEN DuplicateReductions ELSE 0 END) 
			+ SUM(CASE WHEN WeekEndsAndHolidayId IS NOT NULL THEN RecompAnalystReductions ELSE 0 END)
			+ SUM(CASE WHEN WeekEndsAndHolidayId IS NOT NULL THEN FeeScheduleReductions ELSE 0 END) 
			+ SUM(CASE WHEN WeekEndsAndHolidayId IS NOT NULL THEN BenchmarkReductions ELSE 0 END) 
			+ SUM(CASE WHEN WeekEndsAndHolidayId IS NOT NULL THEN CTGReductions ELSE 0 END) Total_Bill_Review_Reductions_WeekEnd
		,SUM(CASE WHEN WeekEndsAndHolidayId IS NULL THEN DuplicateReductions ELSE 0 END) 
			+ SUM(CASE WHEN WeekEndsAndHolidayId IS NULL THEN RecompAnalystReductions ELSE 0 END)
			+ SUM(CASE WHEN WeekEndsAndHolidayId IS NULL THEN FeeScheduleReductions ELSE 0 END) 
			+ SUM(CASE WHEN WeekEndsAndHolidayId IS NULL THEN BenchmarkReductions ELSE 0 END) 
			+ SUM(CASE WHEN WeekEndsAndHolidayId IS NULL THEN CTGReductions ELSE 0 END) Total_Bill_Review_Reductions_WeekDay
		,'+CAST(@ReportType AS VARCHAR(2))+' AS ReportTypeID

	FROM #PPO_ActivityReport_MasterCoverage_rollup R1
	LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'WeekEndsAndHolidays' ELSE'if_WeekEndsAndHolidays(@RunPostingGroupAuditId)' END+' WEAH
		ON R1.OdsCustomerId = WEAH.OdsCustomerId
		AND CAST(R1.CreateDate AS DATE) = CAST(WEAH.DayOfWeekDate AS DATE)
	GROUP BY R1.OdsCustomerId
		,StartOfMonth
		,Customer
		,Year
		,Month
		,Company
		,Office
		,SOJ
		,Coverage
		,Form_Type),

-- Rollup To month level
	cte_PPO_ActivityReport_MasterCoverage_Output_WeekDayType_MonthLevel AS(
	SELECT OdsCustomerId
		,StartOfMonth
		,SUM(Total_Bills_WeekEnd)/@WeekEndDaysLastMonth Bills_WeekEnd_Rate
		,SUM(Total_Bills_WeekDay) /@WeekDaysLastMonth Bills_WeekDay_Rate
		,SUM(Total_Provider_Charges_WeekEnd)/@WeekEndDaysLastMonth Provider_Charges_WeekEnd_Rate
		,SUM(Total_Provider_Charges_WeekDay)/@WeekDaysLastMonth Provider_Charges_WeekDay_Rate
		,SUM(Total_Bill_Review_Reductions_WeekEnd)/@WeekEndDaysLastMonth Bill_Review_Reductions_WeekEnd_Rate
		,SUM(Total_Bill_Review_Reductions_WeekDay)/@WeekDaysLastMonth Bill_Review_Reductions_WeekDay_Rate

	
	FROM cte_PPO_ActivityReport_MasterCoverage_Output_WeekDayType
	WHERE DATEDIFF(MONTH,@CurrentStartOfMonth,StartOfMonth) = -1
	GROUP BY OdsCustomerId
		,StartOfMonth)


-- Use month level ratios to Predict rest of month
	INSERT INTO '+@TargetDatabaseName+'.dbo.PPO_ActivityReport_MasterCoverage_Output(
		 OdsCustomerId
		,StartOfMonth
		,Customer
		,Year
		,Month
		,Company
		,Office
		,SOJ
		,Coverage
		,Form_Type
		,Total_Bills
		,Total_Provider_Charges
		,Total_Bill_Review_Reductions
		,ReportTypeID
		,RunDate)	
	SELECT WD.OdsCustomerId
		,WD.StartOfMonth
		,WD.Customer
		,WD.Year
		,WD.Month
		,WD.Company
		,WD.Office
		,WD.SOJ
		,WD.Coverage
		,WD.Form_Type
		,(WD.Total_Bills_WeekEnd + ISNULL((WD.Total_Bills_WeekEnd/NULLIF(@WeekEndDaysToDate,0))*@WeekendDaysRemaining,((LML.Bills_WeekEnd_Rate/LML.Bills_WeekDay_Rate)*(WD.Total_Bills_WeekDay/@TotalWeekDaysToDate))*@WeekendDaysRemaining))       
			+ (WD.Total_Bills_WeekDay +ISNULL((WD.Total_Bills_WeekDay/NULLIF(@TotalWeekDaysToDate,0))*@WeekDaysRemaining,((LML.Bills_WeekDay_Rate/LML.Bills_WeekEnd_Rate)*(WD.Total_Bills_WeekEnd/@WeekEndDaysToDate))*@WeekDaysRemaining)) AS Total_Bills
		,(WD.Total_Provider_Charges_WeekEnd + ISNULL((WD.Total_Provider_Charges_WeekEnd/NULLIF(@WeekEndDaysToDate,0))*@WeekendDaysRemaining,((LML.Provider_Charges_WeekEnd_Rate/LML.Provider_Charges_WeekDay_Rate)*(WD.Total_Provider_Charges_WeekDay/@TotalWeekDaysToDate))*@WeekendDaysRemaining))       
			+ (WD.Total_Provider_Charges_WeekDay +ISNULL((WD.Total_Provider_Charges_WeekDay/NULLIF(@TotalWeekDaysToDate,0))*@WeekDaysRemaining,((LML.Provider_Charges_WeekDay_Rate/LML.Provider_Charges_WeekEnd_Rate)*(WD.Total_Provider_Charges_WeekEnd/@WeekEndDaysToDate))*@WeekDaysRemaining)) AS Total_Provider_Charges		
		,(WD.Total_Bill_Review_Reductions_WeekEnd + ISNULL((WD.Total_Bill_Review_Reductions_WeekEnd/NULLIF(@WeekEndDaysToDate,0))*@WeekendDaysRemaining,((LML.Bill_Review_Reductions_WeekEnd_Rate/LML.Bill_Review_Reductions_WeekDay_Rate)*(WD.Total_Bill_Review_Reductions_WeekDay/@TotalWeekDaysToDate))*@WeekendDaysRemaining))       
			+ (WD.Total_Bill_Review_Reductions_WeekDay +ISNULL((WD.Total_Bill_Review_Reductions_WeekDay/NULLIF(@TotalWeekDaysToDate,0))*@WeekDaysRemaining,((LML.Bill_Review_Reductions_WeekDay_Rate/LML.Bill_Review_Reductions_WeekEnd_Rate)*(WD.Total_Bill_Review_Reductions_WeekEnd/@WeekEndDaysToDate))*@WeekDaysRemaining)) AS Total_Bill_Review_Reductions
		,ReportTypeID
		,GETDATE()
	FROM cte_PPO_ActivityReport_MasterCoverage_Output_WeekDayType WD
	LEFT OUTER JOIN cte_PPO_ActivityReport_MasterCoverage_Output_WeekDayType_MonthLevel LML
		ON WD.OdsCustomerId = LML.OdsCustomerId
		AND DATEDIFF(MONTH,WD.StartOfMonth,LML.StartOfMonth) = -1
	WHERE DATEDIFF(MONTH,WD.StartOfMonth,@CurrentStartOfMonth) = 0;	
	'
		
	EXEC  (@SQLScript);	
	
END
GO



IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.PPO_ActivityReport_MasterCoverage_SplitLines') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PPO_ActivityReport_MasterCoverage_SplitLines
GO

CREATE PROCEDURE dbo.PPO_ActivityReport_MasterCoverage_SplitLines(
@OdsCustomerId INT = 0)
AS
BEGIN
-- Setup Run parameters
-- DECLARE @OdsCustomerId INT = 5;
DECLARE @SQLScript VARCHAR(MAX) = '	
DECLARE  @returnstatus INT;
									
-- Identify Split Lines and Join with child lines
IF OBJECT_ID(''tempdb..#GroupedLines'') IS NOT NULL DROP TABLE #GroupedLines
SELECT   T1.OdsCustomerId
		,T1.billIDNo
        ,1 AS actionIndicator
        ,T2.ref_line_no
        ,T2.line_no
        ,T2.charged
        
INTO #GroupedLines
FROM    stg.PPO_ActivityReport_MasterCoverage_Input T1
INNER JOIN stg.PPO_ActivityReport_MasterCoverage_Input T2
	ON T1.OdsCustomerId = T2.OdsCustomerId
	AND T1.billIDNo = T2.billIDNo
	AND T1.line_no = T2.ref_line_no 
	AND T1.line_no != T2.line_no

WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN ' T1.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ' ELSE '' END +'T1.linetype = 1
        AND T1.line_no_disp = 0
        AND T1.charged = 0
        AND T1.allowed > 0;

-- Update split line charges with sum of charged from children and set Children to zero
;WITH cte_LineCharges AS(
SELECT  billIDNo
		,OdsCustomerId
		,ref_line_no
		,SUM(ISNULL(charged,0)) AS Charged
FROM #GroupedLines
GROUP BY billIDNo
		 ,OdsCustomerId
		 ,ref_line_no)        
SELECT T.OdsCustomerId
      ,T.billIDNo
      ,T.linetype
      ,T.line_no
      ,T.CreateDate
      ,T.CompanyID
      ,T.Company
      ,T.OfficeID
      ,T.Office
      ,T.Coverage
      ,T.SOJ
      ,T.Form_Type
      ,T.TypeOfBill
      ,T.line_no_disp
      ,0 as ref_line_no
      ,T.over_ride
      ,CASE WHEN S.Billidno IS NOT NULL THEN S.Charged 
					 WHEN G.billIDNo IS NOT NULL THEN 0 ELSE T.Charged END AS charged
      ,T.allowed
      ,T.PreApportionedAmount
      ,T.analyzed
      ,T.units
      ,T.reporttypeId
      ,T.RunDate 
INTO #PPO_ActivityReport_MasterCoverage_Input
FROM stg.PPO_ActivityReport_MasterCoverage_Input T
LEFT OUTER JOIN #GroupedLines G
	ON T.OdsCustomerId = G.OdsCustomerId 
	AND T.billIDNo = G.billIDNo
	AND T.line_no = G.line_no
LEFT OUTER JOIN cte_LineCharges S 
	ON T.OdsCustomerId = S.OdsCustomerId	
	AND T.billIDNo = S.billIDNo
	AND T.line_no = S.ref_line_no'+
CASE WHEN @OdsCustomerId <> 0 THEN CHAR(13)+CHAR(10)+'WHERE  T.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+';' ELSE ';'+CHAR(13)+CHAR(10) END +
CASE WHEN @OdsCustomerID <> 0 THEN '

EXEC adm.Rpt_CreateUnpartitionedTableSchema '+CAST(@OdsCustomerId AS VARCHAR(3))+',57,1,@returnstatus;
EXEC adm.Rpt_CreateUnpartitionedTableIndexes '+CAST(@OdsCustomerId AS VARCHAR(3))+',57,@returnstatus;
EXEC adm.Rpt_SwitchUnpartitionedTable '+CAST(@OdsCustomerId AS VARCHAR(3))+',57,'''',1,@returnstatus;

DROP TABLE stg.PPO_ActivityReport_MasterCoverage_Input_Unpartitioned;' 

ELSE '
TRUNCATE TABLE stg.PPO_ActivityReport_MasterCoverage_Input;' END+'

INSERT INTO stg.PPO_ActivityReport_MasterCoverage_Input
SELECT  OdsCustomerId
		,BillIDNo
		,CreateDate
		,Form_Type
		,TypeOfBill
		,CompanyID
		,Company
		,OfficeId
		,Office
		,Coverage
		,SOJ
		,LINE_NO_DISP
		,LINE_NO
		,REF_LINE_NO
		,LineType
		,OVER_RIDE
		,CHARGED
		,ALLOWED
		,PreApportionedAmount
		,ANALYZED
		,UNITS
		,ReportTypeId
        ,RunDate
FROM #PPO_ActivityReport_MasterCoverage_Input;'
	
EXEC (@SQLScript);

END 
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.PPO_ActivityReport_NetworkRepricedSubmitted_Prediction') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PPO_ActivityReport_NetworkRepricedSubmitted_Prediction
GO

CREATE PROCEDURE dbo.PPO_ActivityReport_NetworkRepricedSubmitted_Prediction(
@SourceDatabaseName VARCHAR(50)='AcsOds',
@StartDate AS DATETIME,
@EndDate AS DATETIME,
@RunType INT = 0,
@if_Date DATETIME  = NULL,
@OdsCustomerId INT,
@TargetDatabaseName VARCHAR(50)='ReportDB')
AS
BEGIN
--3.1
-- Combine Result from repriced and Submitted Monthly.

--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@StartDate AS DATETIME = '20160301',@EndDate AS DATETIME = '20160701',@RunType INT = 0,@if_Date AS DATETIME = NULL,@ReportType INT = 2,@OdsCustomerId INT = 2,@TargetDatabaseName VARCHAR(50)='ReportDB';

	DECLARE @SQLScript VARCHAR(MAX)  
	DECLARE @StartOfEndDateMonth DATETIME = DATEADD(MONTH, DATEDIFF(MONTH, 0, @EndDate), 0);

	SET @SQLScript =  CAST('' AS VARCHAR(MAX))  + '	'+CASE WHEN @OdsCustomerID <> 0 THEN '
	-- Get Copy of previous prediction
	INSERT INTO '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkRepricedSubmitted_Flashback
	SELECT * 
	FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output
	WHERE OdsCustomerId = '+CAST(@OdsCustomerID as VARCHAR(5))+' AND StartOfMonth BETWEEN '''+CONVERT(VARCHAR(10),@StartOfEndDateMonth,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+''' AND ReportTypeId = 2;

	-- Cleanup Previous Prediction	
	DELETE FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output
	WHERE OdsCustomerId = '+CAST(@OdsCustomerID as VARCHAR(5))+' AND StartOfMonth BETWEEN '''+CONVERT(VARCHAR(10),@StartOfEndDateMonth,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+''' AND ReportTypeId = 2;' 
	
	ELSE '
	-- Get Copy of previous prediction
	INSERT INTO '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkRepricedSubmitted_Flashback
	SELECT * 
	FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output
	WHERE StartOfMonth BETWEEN '''+CONVERT(VARCHAR(10),@StartOfEndDateMonth,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+''' AND ReportTypeId = 2;

	-- Cleanup Previous Prediction
	DELETE FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output
	WHERE StartOfMonth BETWEEN '''+CONVERT(VARCHAR(10),@StartOfEndDateMonth,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+''' AND ReportTypeId = 2;'  END+'

	DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;

	DECLARE  @CurrentStartOfMonth DATETIME 
			,@CutOffRunDate DATETIME  = (SELECT MAX(RunDate) FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output);

	SET @CutOffRunDate = @CutOffRunDate - DATEPART(dw, @CutOffRunDate) 
	SET @CurrentStartOfMonth = DATEADD(MONTH, DATEDIFF(MONTH, 0, @CutOffRunDate), 0)
  
	DECLARE  @TotalWeekDaysToDate INT 
			,@WeekEndDaysToDate INT
			,@WeekEndDaysInMonth INT
			,@WeekDaysRemaining INT
			,@WeekendDaysRemaining INT
			,@WeekEndDaysLastMonth INT
			,@WeekDaysLastMonth INT
			,@HolidaysInMonth INT
			,@HolidaysToDate INT;

	IF OBJECT_ID(''tempdb..#WeekEndsAndHolidays'') IS NOT NULL	DROP TABLE #WeekEndsAndHolidays
	SELECT DISTINCT 
			 DayOfWeekDate
			,DayName
	INTO #WeekEndsAndHolidays
	FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'WeekEndsAndHolidays' ELSE'if_WeekEndsAndHolidays(@RunPostingGroupAuditId)' END+'

	SELECT @WeekEndDaysToDate = SUM(CASE WHEN DayOfWeekDate <= @CutOffRunDate AND DayName IN (''SAT'',''SUN'') AND (MONTH(DayOfWeekDate) = MONTH(@CurrentStartOfMonth) AND YEAR(DayOfWeekDate) = YEAR(@CurrentStartOfMonth)) THEN 1 ELSE 0 END)
		  ,@WeekEndDaysInMonth = SUM(CASE WHEN DayName IN (''SAT'',''SUN'',''HOL'') AND (MONTH(DayOfWeekDate) = MONTH(@CurrentStartOfMonth) AND YEAR(DayOfWeekDate) = YEAR(@CurrentStartOfMonth)) THEN 1 ELSE 0 END)
		  ,@HolidaysInMonth = SUM(CASE WHEN DayName = ''HOL'' AND (MONTH(DayOfWeekDate) = MONTH(@CurrentStartOfMonth) AND YEAR(DayOfWeekDate) = YEAR(@CurrentStartOfMonth)) THEN 1 ELSE 0 END)
		  ,@HolidaysToDate = SUM(CASE WHEN DayOfWeekDate <= @CutOffRunDate AND DayName IN (''HOL'') AND (MONTH(DayOfWeekDate) = MONTH(@CurrentStartOfMonth) AND YEAR(DayOfWeekDate) = YEAR(@CurrentStartOfMonth)) THEN 1 ELSE 0 END)
		  ,@WeekEndDaysLastMonth = SUM(CASE WHEN DayName IN (''SAT'',''SUN'',''HOL'') AND (MONTH(DayOfWeekDate) = MONTH(DATEADD(mm,-1,@CurrentStartOfMonth)) AND YEAR(DayOfWeekDate) = YEAR(DATEADD(mm,-1,@CurrentStartOfMonth))) THEN 1 ELSE 0 END)
		  ,@WeekDaysLastMonth = DAY(EOMONTH(DATEADD(MONTH,-1,@CurrentStartOfMonth)))
			-SUM(CASE WHEN DayName IN (''SAT'',''SUN'',''HOL'') AND (MONTH(DayOfWeekDate) = MONTH(DATEADD(mm,-1,@CurrentStartOfMonth)) AND YEAR(DayOfWeekDate) = YEAR(DATEADD(mm,-1,@CurrentStartOfMonth))) THEN 1 ELSE 0 END)
			
	FROM #WeekEndsAndHolidays

	SELECT @TotalWeekDaysToDate = DATEDIFF(DAY,@CurrentStartOfMonth,@CutOffRunDate) + 1 - @WeekEndDaysToDate - @HolidaysToDate
	
	SELECT @WeekEndDaysToDate =  @WeekEndDaysToDate + @HolidaysToDate
		  ,@WeekendDaysRemaining  = @WeekEndDaysInMonth - @WeekEndDaysToDate + (@HolidaysInMonth-@HolidaysToDate)

	SELECT @WeekDaysRemaining = DATEDIFF(DAY,@CurrentStartOfMonth,EOMONTH(@CurrentStartOfMonth)) + 1 - @TotalWeekDaysToDate - @WeekEndDaysToDate - @WeekendDaysRemaining

--	SELECT @WeekEndDaysToDate		  ,@TotalWeekDaysToDate		  ,@WeekendDaysRemaining		  ,@WeekDaysRemaining

	;WITH cte_VPN_Monitoring_NetworkSubmitted_WeekDayType AS(	
	SELECT  StartOfMonth ,
			OdsCustomerId ,
			ReportYear ,
			ReportMonth ,
			SOJ ,
			NetworkName ,
			BillType ,
			CV_Type ,
			Company ,
			Office ,
			BillsCount_Weekend + 0.0 AS Total_BillsCount_WeekEnd,
			BillsCount_WeekDay + 0.0 AS Total_BillsCount_WeekDay,
			BillsRePriced_Weekend + 0.0 AS Total_BillsRePriced_WeekEnd,
			BillsRePriced_WeekDay + 0.0 AS  Total_BillsRePriced_WeekDay,
			ProviderCharges_Weekend AS Total_ProviderCharges_WeekEnd,
			ProviderCharges_WeekDay AS  Total_ProviderCharges_WeekDay,
			BRAllowable_Weekend AS Total_BRAllowable_WeekEnd,
			BRAllowable_WeekDay AS Total_BRAllowable_WeekDay

	FROM stg.VPN_Monitoring_NetworkSubmitted
	WHERE DATEDIFF(MONTH,EOMONTH(StartOfMonth),EOMONTH(@CurrentStartOfMonth)) <= 1),

	-- Rollup To month level
	cte_VPN_Monitoring_NetworkSubmitted_WeekDayType_MonthLevel AS(
	SELECT OdsCustomerId
		,StartOfMonth
		,SUM(Total_BillsCount_WeekEnd)/@WeekEndDaysLastMonth BillsCount_WeekEnd_Rate
		,SUM(Total_BillsCount_WeekDay)/@WeekDaysLastMonth BillsCount_WeekDay_Rate
		,SUM(Total_BillsRePriced_WeekEnd)/@WeekEndDaysLastMonth BillsRePriced_WeekEnd_Rate
		,SUM(Total_BillsRePriced_WeekDay)/@WeekDaysLastMonth BillsRePriced_WeekDay_Rate
		,SUM(Total_ProviderCharges_WeekEnd)/@WeekEndDaysLastMonth ProviderCharges_WeekEnd_Rate
		,SUM(Total_ProviderCharges_WeekDay)/@WeekDaysLastMonth ProviderCharges_WeekDay_Rate
		,SUM(Total_BRAllowable_WeekEnd)/@WeekEndDaysLastMonth BRAllowable_WeekEnd_Rate
		,SUM(Total_BRAllowable_WeekDay)/@WeekDaysLastMonth BRAllowable_WeekDay_Rate


	FROM cte_VPN_Monitoring_NetworkSubmitted_WeekDayType
	WHERE DATEDIFF(MONTH,@CurrentStartOfMonth,StartOfMonth) = -1
	GROUP BY OdsCustomerId
		,StartOfMonth),

	-- Predict Rest of Month for Network Submitted Data
	cte_VPN_Monitoring_NetworkSubmitted AS(
	SELECT  WD.StartOfMonth ,
			WD.OdsCustomerId ,
			WD.ReportYear ,
			WD.ReportMonth ,
			WD.SOJ ,
			WD.NetworkName ,
			WD.BillType ,
			WD.CV_Type ,
			WD.Company ,
			WD.Office ,
			(WD.Total_BillsCount_WeekEnd + ISNULL((WD.Total_BillsCount_WeekEnd/NULLIF(@WeekEndDaysToDate,0))*@WeekendDaysRemaining,((LML.BillsCount_WeekEnd_Rate/LML.BillsCount_WeekDay_Rate)*(WD.Total_BillsCount_WeekDay/@TotalWeekDaysToDate))*@WeekendDaysRemaining))       
				+ (WD.Total_BillsCount_WeekDay +ISNULL((WD.Total_BillsCount_WeekDay/NULLIF(@TotalWeekDaysToDate,0))*@WeekDaysRemaining,((LML.BillsCount_WeekDay_Rate/LML.BillsCount_WeekEnd_Rate)*(WD.Total_BillsCount_WeekEnd/@WeekEndDaysToDate))*@WeekDaysRemaining)) AS BillsCount,
			(WD.Total_BillsRePriced_WeekEnd + ISNULL((WD.Total_BillsRePriced_WeekEnd/NULLIF(@WeekEndDaysToDate,0))*@WeekendDaysRemaining,((LML.BillsRePriced_WeekEnd_Rate/LML.BillsRePriced_WeekDay_Rate)*(WD.Total_BillsRePriced_WeekDay/@TotalWeekDaysToDate))*@WeekendDaysRemaining))       
				+ (WD.Total_BillsRePriced_WeekDay +ISNULL((WD.Total_BillsRePriced_WeekDay/NULLIF(@TotalWeekDaysToDate,0))*@WeekDaysRemaining,((LML.BillsRePriced_WeekDay_Rate/LML.BillsRePriced_WeekEnd_Rate)*(WD.Total_BillsRePriced_WeekEnd/@WeekEndDaysToDate))*@WeekDaysRemaining)) AS BillsRePriced,
			(WD.Total_ProviderCharges_WeekEnd + ISNULL((WD.Total_ProviderCharges_WeekEnd/NULLIF(@WeekEndDaysToDate,0))*@WeekendDaysRemaining,((LML.ProviderCharges_WeekEnd_Rate/LML.ProviderCharges_WeekDay_Rate)*(WD.Total_ProviderCharges_WeekDay/@TotalWeekDaysToDate))*@WeekendDaysRemaining))       
				+ (WD.Total_ProviderCharges_WeekDay +ISNULL((WD.Total_ProviderCharges_WeekDay/NULLIF(@TotalWeekDaysToDate,0))*@WeekDaysRemaining,((LML.ProviderCharges_WeekDay_Rate/LML.ProviderCharges_WeekEnd_Rate)*(WD.Total_ProviderCharges_WeekEnd/@WeekEndDaysToDate))*@WeekDaysRemaining)) AS ProviderCharges,
			(WD.Total_BRAllowable_WeekEnd + ISNULL((WD.Total_BRAllowable_WeekEnd/NULLIF(@WeekEndDaysToDate,0))*@WeekendDaysRemaining,((LML.BRAllowable_WeekEnd_Rate/LML.BRAllowable_WeekDay_Rate)*(WD.Total_BRAllowable_WeekDay/@TotalWeekDaysToDate))*@WeekendDaysRemaining))       
				+ (WD.Total_BRAllowable_WeekDay +ISNULL((WD.Total_BRAllowable_WeekDay/NULLIF(@TotalWeekDaysToDate,0))*@WeekDaysRemaining,((LML.BRAllowable_WeekDay_Rate/LML.BRAllowable_WeekEnd_Rate)*(WD.Total_BRAllowable_WeekEnd/@WeekEndDaysToDate))*@WeekDaysRemaining)) AS BRAllowable

	FROM cte_VPN_Monitoring_NetworkSubmitted_WeekDayType WD
	LEFT OUTER JOIN cte_VPN_Monitoring_NetworkSubmitted_WeekDayType_MonthLevel LML
		ON WD.OdsCustomerId = LML.OdsCustomerId
		AND DATEDIFF(MONTH,WD.StartOfMonth,LML.StartOfMonth) = -1
	WHERE DATEDIFF(MONTH,WD.StartOfMonth,@CurrentStartOfMonth) = 0)	

	INSERT INTO '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output
	SELECT  ISNULL(VPNS.StartOfMonth ,VPNR.StartOfMonth) StartOfMonth,
			ISNULL(VPNS.OdsCustomerId ,VPNR.OdsCustomerId) OdsCustomerId,
			(SELECT CustomerName FROM '+@SourceDatabaseName+'.adm.Customer WHERE CustomerId = ISNULL(VPNS.OdsCustomerId ,VPNR.OdsCustomerId)) Customer,
			ISNULL(VPNS.SOJ ,VPNR.SOJ) SOJ,
			ISNULL(VPNS.NetworkName,VPNR.NetworkName) NetworkName,
			ISNULL(VPNS.BillType ,VPNR.BillType ) BillType,
			ISNULL(VPNS.ReportYear,VPNR.ReportYear) ReportYear,
			ISNULL(VPNS.ReportMonth,VPNR.ReportMonth) ReportMonth,
			ISNULL(VPNS.CV_Type,VPNR.CV_Type) CV_Type,
			ISNULL(VPNS.Company,VPNR.Company) Company,
			ISNULL(VPNS.Office,VPNR.Office) Office,
			ISNULL(VPNS.BillsCount, 0) AS BillsCount ,
			ISNULL(VPNS.BillsRePriced, 0) AS BillsRepriced ,
			ISNULL(VPNS.ProviderCharges, 0) AS ProviderCharges ,
			ISNULL(VPNS.BRAllowable, 0) AS BRAllowable ,
			(ISNULL(VPNR.InNetworkCharges, 0)/(@WeekEndDaysToDate+@TotalWeekDaysToDate))*(@WeekendDaysRemaining+@WeekDaysRemaining) + ISNULL(VPNR.InNetworkCharges,0) AS InNetworkCharges ,
			(ISNULL(VPNR.InNetworkAmountAllowed, 0)/(@WeekEndDaysToDate+@TotalWeekDaysToDate))*(@WeekendDaysRemaining+@WeekDaysRemaining) + ISNULL(VPNR.InNetworkAmountAllowed,0) AS InNetworkAmountAllowed ,
			(ISNULL(VPNR.Savings, 0)/(@WeekEndDaysToDate+@TotalWeekDaysToDate))*(@WeekendDaysRemaining+@WeekDaysRemaining) + ISNULL(VPNR.Savings,0) AS Savings ,
			(ISNULL(VPNR.Credits, 0)/(@WeekEndDaysToDate+@TotalWeekDaysToDate))*(@WeekendDaysRemaining+@WeekDaysRemaining) + ISNULL(VPNR.Credits,0) AS Credits ,
			(ISNULL(VPNR.NetSavings, 0)/(@WeekEndDaysToDate+@TotalWeekDaysToDate))*(@WeekendDaysRemaining+@WeekDaysRemaining) + ISNULL(VPNR.NetSavings,0) AS NetSavings,

			2 AS ReportTypeId,
			GETDATE() AS RunDate

	FROM cte_VPN_Monitoring_NetworkSubmitted VPNS
	FULL OUTER JOIN stg.VPN_Monitoring_NetworkRepriced VPNR
	ON VPNS.StartOfMonth = VPNR.StartOfMonth
		AND VPNS.OdsCustomerId = VPNR.OdsCustomerId
		AND VPNS.SOJ = VPNR.SOJ
		AND VPNS.NetworkName = VPNR.NetworkName
		AND VPNS.BillType = VPNR.BillType
		AND VPNS.CV_Type = VPNR.CV_Type
		AND VPNS.StartOfMonth = VPNR.StartOfMonth
		AND VPNS.Company = VPNR.Company
		AND VPNS.Office = VPNR.Office
		AND DATEDIFF(MONTH,VPNR.StartOfMonth,@CurrentStartOfMonth) = 0

	WHERE DATEDIFF(MONTH,VPNS.StartOfMonth,@CurrentStartOfMonth) = 0
		OR DATEDIFF(MONTH,VPNR.StartOfMonth,@CurrentStartOfMonth) = 0;'
        
	EXEC(@SQLScript);     

END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.PPO_ActivityReport_NetworkUniqueSubmitted_Prediction') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PPO_ActivityReport_NetworkUniqueSubmitted_Prediction
GO

CREATE PROCEDURE dbo.PPO_ActivityReport_NetworkUniqueSubmitted_Prediction(
@SourceDatabaseName VARCHAR(50)='AcsOds',
@StartDate AS DATETIME,
@EndDate AS DATETIME,
@RunType INT = 0,
@if_Date DATETIME  = NULL,
@OdsCustomerId INT,
@TargetDatabaseName VARCHAR(50)='ReportDB')
AS
BEGIN
--3.1
-- Combine Result from repriced and Submitted Monthly.

--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@StartDate AS DATETIME = '20200201',@EndDate AS DATETIME = '20200228',@RunType INT = 0,@if_Date AS DATETIME = NULL,@ReportType INT = 2,@OdsCustomerId INT = 2,@TargetDatabaseName VARCHAR(50)='ReportDB';

	DECLARE @SQLScript VARCHAR(MAX)  
	DECLARE @StartOfEndDateMonth DATETIME = DATEADD(MONTH, DATEDIFF(MONTH, 0, @EndDate), 0);

	SET @SQLScript =  CAST('' AS VARCHAR(MAX))  + '

	'+CASE WHEN @OdsCustomerID <> 0 THEN '
	-- Get Copy of previous prediction
	INSERT INTO '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkUniqueSubmitted_Flashback
	SELECT * 
	FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output
	WHERE OdsCustomerId = '+CAST(@OdsCustomerID as VARCHAR(5))+' AND StartOfMonth BETWEEN '''+CONVERT(VARCHAR(10),@StartOfEndDateMonth,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+''' AND ReportTypeId = 2;

	DELETE FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output
	WHERE OdsCustomerId = '+CAST(@OdsCustomerID as VARCHAR(5))+' AND StartOfMonth BETWEEN '''+CONVERT(VARCHAR(10),@StartOfEndDateMonth,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+''' AND ReportTypeId = 2;' 

	ELSE '
	-- Get Copy of previous prediction
	INSERT INTO '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkUniqueSubmitted_Flashback
	SELECT * 
	FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output
	WHERE StartOfMonth BETWEEN '''+CONVERT(VARCHAR(10),@StartOfEndDateMonth,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+''' AND ReportTypeId = 2;

	-- Cleanup Previous Prediction
	DELETE FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output
	WHERE StartOfMonth BETWEEN '''+CONVERT(VARCHAR(10),@StartOfEndDateMonth,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+''' AND ReportTypeId = 2;'  END+'

	DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;

	DECLARE  @CurrentStartOfMonth DATETIME
			,@CutOffRunDate DATETIME  = (SELECT MAX(RunDate) FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output);

	SET @CutOffRunDate = @CutOffRunDate - DATEPART(dw, @CutOffRunDate) 
	SET @CurrentStartOfMonth = DATEADD(MONTH, DATEDIFF(MONTH, 0, @CutOffRunDate), 0)
  
	DECLARE  @TotalWeekDaysToDate INT 
			,@WeekEndDaysToDate INT
			,@WeekEndDaysInMonth INT
			,@WeekDaysRemaining INT
			,@WeekendDaysRemaining INT
			,@WeekEndDaysLastMonth INT
			,@WeekDaysLastMonth INT
			,@HolidaysInMonth INT
			,@HolidaysToDate INT;

	IF OBJECT_ID(''tempdb..#WeekEndsAndHolidays'') IS NOT NULL	DROP TABLE #WeekEndsAndHolidays
	SELECT DISTINCT 
			 DayOfWeekDate
			,DayName
	INTO #WeekEndsAndHolidays
	FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'WeekEndsAndHolidays' ELSE'if_WeekEndsAndHolidays(@RunPostingGroupAuditId)' END+'

	SELECT @WeekEndDaysToDate = SUM(CASE WHEN DayOfWeekDate <= @CutOffRunDate AND DayName IN (''SAT'',''SUN'') AND (MONTH(DayOfWeekDate) = MONTH(@CurrentStartOfMonth) AND YEAR(DayOfWeekDate) = YEAR(@CurrentStartOfMonth)) THEN 1 ELSE 0 END)
		  ,@WeekEndDaysInMonth = SUM(CASE WHEN DayName IN (''SAT'',''SUN'',''HOL'') AND (MONTH(DayOfWeekDate) = MONTH(@CurrentStartOfMonth) AND YEAR(DayOfWeekDate) = YEAR(@CurrentStartOfMonth)) THEN 1 ELSE 0 END)
		  ,@HolidaysInMonth = SUM(CASE WHEN DayName = ''HOL'' AND (MONTH(DayOfWeekDate) = MONTH(@CurrentStartOfMonth) AND YEAR(DayOfWeekDate) = YEAR(@CurrentStartOfMonth)) THEN 1 ELSE 0 END)
		  ,@HolidaysToDate = SUM(CASE WHEN DayOfWeekDate <= @CutOffRunDate AND DayName IN (''HOL'') AND (MONTH(DayOfWeekDate) = MONTH(@CurrentStartOfMonth) AND YEAR(DayOfWeekDate) = YEAR(@CurrentStartOfMonth)) THEN 1 ELSE 0 END)
		  ,@WeekEndDaysLastMonth = SUM(CASE WHEN DayName IN (''SAT'',''SUN'',''HOL'') AND (MONTH(DayOfWeekDate) = MONTH(DATEADD(mm,-1,@CurrentStartOfMonth)) AND YEAR(DayOfWeekDate) = YEAR(DATEADD(mm,-1,@CurrentStartOfMonth))) THEN 1 ELSE 0 END)
		  ,@WeekDaysLastMonth = DAY(EOMONTH(DATEADD(MONTH,-1,@CurrentStartOfMonth)))
			-SUM(CASE WHEN DayName IN (''SAT'',''SUN'',''HOL'') AND (MONTH(DayOfWeekDate) = MONTH(DATEADD(mm,-1,@CurrentStartOfMonth)) AND YEAR(DayOfWeekDate) = YEAR(DATEADD(mm,-1,@CurrentStartOfMonth))) THEN 1 ELSE 0 END)
			
	FROM #WeekEndsAndHolidays

	SELECT @TotalWeekDaysToDate = DATEDIFF(DAY,@CurrentStartOfMonth,@CutOffRunDate) + 1 - @WeekEndDaysToDate - @HolidaysToDate
	
	SELECT @WeekEndDaysToDate =  @WeekEndDaysToDate + @HolidaysToDate
		  ,@WeekendDaysRemaining  = @WeekEndDaysInMonth - @WeekEndDaysToDate + (@HolidaysInMonth-@HolidaysToDate)

	SELECT @WeekDaysRemaining = DATEDIFF(DAY,@CurrentStartOfMonth,EOMONTH(@CurrentStartOfMonth)) + 1 - @TotalWeekDaysToDate - @WeekEndDaysToDate - @WeekendDaysRemaining

	--	SELECT @WeekEndDaysToDate		  ,@TotalWeekDaysToDate		  ,@WeekendDaysRemaining		  ,@WeekDaysRemaining

	-- Get max values returned when came back from all our networks
	-- We are going to use the latest date sent to a network for reporting (Doesnt really matter because we only consider activity in resporting month...)
	;WITH cte_BillMaxCharges AS(
	SELECT    StartOfMonth ,
			OdsCustomerId ,
			ReportYear ,
			ReportMonth ,
			SOJ ,
			BillType ,
			CV_Type ,
			Company ,
			Office ,
			BillIdNo ,
			CASE WHEN EventId = 11 THEN 1 WHEN EventId IN (10,16) AND ProcessInfo = 2 THEN 2 END EventType,
			MAX(LogDate) AS LogDate ,
			MAX(ProviderCharges) AS ProviderCharges ,
			MAX(BRAllowable) AS BRAllowable
	FROM  stg.VPN_Monitoring_ProviderNetworkEventLog_Filtered 

	GROUP BY  StartOfMonth ,
			OdsCustomerId ,
			ReportYear ,
			ReportMonth ,
			SOJ ,
			BillType ,
			CV_Type ,
			Company ,
			Office ,
			BillIdNo,
			CASE WHEN EventId = 11 THEN 1 WHEN EventId IN (10,16) AND ProcessInfo = 2 THEN 2 END)

	-- Rollup Data Above the Network Level
	,cte_VPNResults_View_savings AS(
	SELECT  StartOfMonth ,
			OdsCustomerId ,
			SOJ ,
			BillType ,
			CV_Type ,
			Company ,
			Office ,
			SUM(ISNULL(InNetworkCharges,0)) AS InNetworkCharges ,
			SUM(ISNULL(InNetworkAmountAllowed,0)) AS InNetworkAmountAllowed ,
			SUM(ISNULL(Savings,0)) AS Savings ,
			SUM(ISNULL(Credits,0)) AS Credits ,
			SUM(ISNULL(NetSavings,0)) AS NetSavings

	FROM    '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output
	WHERE ReportTypeId = 2 AND StartOfMonth >= '''+CONVERT(VARCHAR(10),@StartOfEndDateMonth,112)+'''
	GROUP BY StartOfMonth ,
			OdsCustomerId ,
			SOJ ,
			BillType ,
			CV_Type ,
			Company ,
			Office)

	,cte_BillMaxCharges_WeekDayType AS(
	SELECT  MC.StartOfMonth ,
			MC.OdsCustomerId ,
			MC.ReportYear ,
			MC.ReportMonth ,
			MC.SOJ ,
			MC.BillType ,
			MC.CV_Type ,
			MC.Company ,
			MC.Office ,
			COUNT(DISTINCT CASE WHEN WEAH.WeekEndsAndHolidayId IS NOT NULL AND MC.EventType = 1 THEN MC.BillIdNo END) + 0.0 BillsCount_WeekEnd ,
			COUNT(DISTINCT CASE WHEN WEAH.WeekEndsAndHolidayId IS NULL AND MC.EventType = 1 THEN MC.BillIdNo END) + 0.0 BillsCount_WeekDay ,
			COUNT(DISTINCT CASE WHEN WEAH.WeekEndsAndHolidayId IS NOT NULL AND MC.EventType = 2 THEN MC.BillIdNo END) + 0.0 BillsRePriced_WeekEnd ,
			COUNT(DISTINCT CASE WHEN WEAH.WeekEndsAndHolidayId IS NULL AND MC.EventType = 2 THEN MC.BillIdNo END) + 0.0 BillsRePriced_WeekDay ,
			SUM(CASE WHEN WEAH.WeekEndsAndHolidayId IS NOT NULL AND MC.EventType = 1 THEN MC.ProviderCharges ELSE 0 END) AS ProviderCharges_WeekEnd ,
			SUM(CASE WHEN WEAH.WeekEndsAndHolidayId IS NULL AND MC.EventType = 1 THEN MC.ProviderCharges ELSE 0 END) AS ProviderCharges_WeekDay ,
			SUM(CASE WHEN WEAH.WeekEndsAndHolidayId IS NOT NULL AND MC.EventType = 1 THEN MC.BRAllowable ELSE 0 END) AS BRAllowable_WeekEnd,
			SUM(CASE WHEN WEAH.WeekEndsAndHolidayId IS NULL AND MC.EventType = 1 THEN MC.BRAllowable ELSE 0 END) AS BRAllowable_WeekDay
	FROM cte_BillMaxCharges MC
	LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'WeekEndsAndHolidays' ELSE'if_WeekEndsAndHolidays(@RunPostingGroupAuditId)' END+' WEAH
			ON MC.OdsCustomerId = WEAH.OdsCustomerId
			AND CAST(MC.LogDate AS DATE) = CAST(WEAH.DayOfWeekDate AS DATE)
	WHERE DATEDIFF(MONTH,EOMONTH(MC.StartOfMonth),EOMONTH(@CurrentStartOfMonth)) <= 1

	GROUP BY  MC.StartOfMonth ,
			MC.OdsCustomerId ,
			MC.ReportYear ,
			MC.ReportMonth ,
			MC.SOJ ,
			MC.BillType ,
			MC.CV_Type ,
			MC.Company ,
			MC.Office 
	)
	,cte_BillMaxCharges_WeekDayType_Monthlevel AS(
	SELECT  StartOfMonth ,
			OdsCustomerId,
			SUM(BillsCount_WeekEnd)/@WeekEndDaysLastMonth AS BillsCount_WeekEnd_Rate,
			SUM(BillsCount_WeekDay)/@WeekDaysLastMonth AS BillsCount_WeekDay_Rate,
			SUM(BillsRePriced_WeekEnd)/@WeekEndDaysLastMonth AS BillsRePriced_WeekEnd_Rate,
			SUM(BillsRePriced_WeekDay)/@WeekDaysLastMonth AS BillsRePriced_WeekDay_Rate,
			SUM(ProviderCharges_WeekEnd)/@WeekEndDaysLastMonth AS ProviderCharges_WeekEnd_Rate,
			SUM(ProviderCharges_WeekDay)/@WeekDaysLastMonth AS ProviderCharges_WeekDay_Rate,
			SUM(BRAllowable_WeekEnd)/@WeekEndDaysLastMonth AS BRAllowable_WeekEnd_Rate,
			SUM(BRAllowable_WeekDay)/@WeekDaysLastMonth AS BRAllowable_WeekDay_Rate
	FROM cte_BillMaxCharges_WeekDayType
	WHERE DATEDIFF(MONTH,@CurrentStartOfMonth,StartOfMonth) = -1
	GROUP BY StartOfMonth ,
			OdsCustomerId)

	INSERT INTO '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output 
	SELECT  BMC.StartOfMonth ,
			BMC.OdsCustomerId ,
			C.CustomerName AS Customer,
			BMC.ReportYear ,
			BMC.ReportMonth ,
			BMC.SOJ ,
			BMC.BillType ,
			BMC.CV_Type ,
			BMC.Company ,
			BMC.Office ,
			SVGS.InNetworkCharges ,
			SVGS.InNetworkAmountAllowed ,
			SVGS.Savings ,
			SVGS.Credits ,
			SVGS.NetSavings,
			(BMC.BillsCount_WeekEnd + ISNULL((BMC.BillsCount_WeekEnd/NULLIF(@WeekEndDaysToDate,0))*@WeekendDaysRemaining,((LML.BillsCount_WeekEnd_Rate/LML.BillsCount_WeekDay_Rate)*(BMC.BillsCount_WeekDay/@TotalWeekDaysToDate))*@WeekendDaysRemaining))       
				+ (BMC.BillsCount_WeekDay +ISNULL((BMC.BillsCount_WeekDay/NULLIF(@TotalWeekDaysToDate,0))*@WeekDaysRemaining,((LML.BillsCount_WeekDay_Rate/LML.BillsCount_WeekEnd_Rate)*(BMC.BillsCount_WeekEnd/@WeekEndDaysToDate))*@WeekDaysRemaining)) AS BillsCount,
			(BMC.BillsRePriced_WeekEnd + ISNULL((BMC.BillsRePriced_WeekEnd/NULLIF(@WeekEndDaysToDate,0))*@WeekendDaysRemaining,((LML.BillsRePriced_WeekEnd_Rate/LML.BillsRePriced_WeekDay_Rate)*(BMC.BillsRePriced_WeekDay/@TotalWeekDaysToDate))*@WeekendDaysRemaining))       
				+ (BMC.BillsRePriced_WeekDay +ISNULL((BMC.BillsRePriced_WeekDay/NULLIF(@TotalWeekDaysToDate,0))*@WeekDaysRemaining,((LML.BillsRePriced_WeekDay_Rate/LML.BillsRePriced_WeekEnd_Rate)*(BMC.BillsRePriced_WeekEnd/@WeekEndDaysToDate))*@WeekDaysRemaining)) AS BillsRePriced,
			(BMC.ProviderCharges_WeekEnd + ISNULL((BMC.ProviderCharges_WeekEnd/NULLIF(@WeekEndDaysToDate,0))*@WeekendDaysRemaining,((LML.ProviderCharges_WeekEnd_Rate/LML.ProviderCharges_WeekDay_Rate)*(BMC.ProviderCharges_WeekDay/@TotalWeekDaysToDate))*@WeekendDaysRemaining))       
				+ (BMC.ProviderCharges_WeekDay +ISNULL((BMC.ProviderCharges_WeekDay/NULLIF(@TotalWeekDaysToDate,0))*@WeekDaysRemaining,((LML.ProviderCharges_WeekDay_Rate/LML.ProviderCharges_WeekEnd_Rate)*(BMC.ProviderCharges_WeekEnd/@WeekEndDaysToDate))*@WeekDaysRemaining)) AS ProviderCharges,
			(BMC.BRAllowable_WeekEnd + ISNULL((BMC.BRAllowable_WeekEnd/NULLIF(@WeekEndDaysToDate,0))*@WeekendDaysRemaining,((LML.BRAllowable_WeekEnd_Rate/LML.BRAllowable_WeekDay_Rate)*(BMC.BRAllowable_WeekDay/@TotalWeekDaysToDate))*@WeekendDaysRemaining))       
				+ (BMC.BRAllowable_WeekDay +ISNULL((BMC.BRAllowable_WeekDay/NULLIF(@TotalWeekDaysToDate,0))*@WeekDaysRemaining,((LML.BRAllowable_WeekDay_Rate/LML.BRAllowable_WeekEnd_Rate)*(BMC.BRAllowable_WeekEnd/@WeekEndDaysToDate))*@WeekDaysRemaining)) AS BRAllowable,
			2 AS ReportTypeId,
			GETDATE() AS RunDate

	FROM cte_BillMaxCharges_WeekDayType BMC
	INNER JOIN '+@SourceDatabaseName+'.adm.Customer C
	ON BMC.OdsCustomerId = C.CustomerId
	INNER JOIN cte_VPNResults_View_savings SVGS 
		ON SVGS.StartOfMonth = BMC.StartOfMonth
		AND SVGS.OdsCustomerId = BMC.OdsCustomerId
		AND SVGS.SOJ = BMC.SOJ
		AND SVGS.BillType = BMC.BillType
		AND SVGS.CV_Type = BMC.CV_Type
		AND SVGS.Company = BMC.Company
		AND SVGS.Office = BMC.Office
	LEFT OUTER JOIN cte_BillMaxCharges_WeekDayType_Monthlevel LML
		ON BMC.OdsCustomerId = LML.OdsCustomerId
		AND DATEDIFF(MONTH,BMC.StartOfMonth,LML.StartOfMonth) = -1

	WHERE DATEDIFF(MONTH,BMC.StartOfMonth,@CurrentStartOfMonth) = 0;'
        
	EXEC(@SQLScript);     

END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.ProcedureCodeAnalysisReport_Client') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProcedureCodeAnalysisReport_Client
GO

CREATE PROCEDURE  dbo.ProcedureCodeAnalysisReport_Client (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@OdsCustomerID INT, 
@ReportID int)
AS
BEGIN

-- DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@OdsCustomerID INT = 1, @ReportID int = 4

DECLARE @SQL VARCHAR(MAX)

SELECT @SQL = CAST('' AS VARCHAR(MAX)) +
CASE WHEN @OdsCustomerID <> 0 THEN 
'DELETE FROM stg.ProcedureCodeAnalysisClient
WHERE OdsCustomerId = '+CAST(@OdsCustomerID as VARCHAR(5))+';' ELSE 

'TRUNCATE TABLE stg.ProcedureCodeAnalysisClient;' END+'

/*Outlier Bills*/
IF OBJECT_ID(''tempdb..#Outlier'') IS NOT NULL DROP TABLE #Outlier;
SELECT C.CustomerId
	,B.BillIdNo
INTO #Outlier
FROM '+@SourceDatabaseName+'.adm.Customer C
JOIN  '+@SourceDatabaseName+'.dbo.CustomerBillExclusion B
	ON C.CustomerDatabase = B.Customer 
WHERE ' + CASE WHEN @OdsCustomerId <> 0 THEN ' C.CustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3)) + ' AND ' ELSE '' END + '
	B.ReportID = ' + CAST (@ReportID as Varchar(2))  + '  
  
IF OBJECT_ID(''tempdb..#DPPerformaceInput'') IS NOT NULL DROP TABLE #DPPerformaceInput;
SELECT   R.OdsCustomerId
		,R.BillIDNo
		,LINE_No
		,Coverage
		,Form_Type
		,Z.STATE
		,Z.County
		,Company
		,Office
		,CreateDate
		,ProcedureCode
		,ClaimIDNo
		,CmtIDNo
		,CHARGED
		,ISNULL(PreApportionedAmount,ALLOWED) AS ALLOWED
		,UNITS
INTO #DPPerformaceInput
FROM stg.DP_PerformanceReport_Input R 
LEFT OUTER JOIN #Outlier O 
	ON R.OdsCustomerId = O.CustomerId
	AND R.billIDNo = O.BillIdNo
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.ZipCode Z
	ON R.OdsCustomerId = Z.OdsCustomerId
	AND LEFT(R.ProviderZipOfService, 5) = Z.ZipCode
	AND Z.PrimaryRecord = 1
	    
WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN 'R.OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3)) + ' AND ' ELSE '' END +' ISNULL(PreApportionedAmount,ALLOWED) > 0 AND O.CustomerId IS NULL

    
INSERT INTO stg.ProcedureCodeAnalysisClient
SELECT ''ProcedureCode'' as ReportName
	    ,OdsCustomerId
	    ,CASE WHEN LTRIM(RTRIM(ISNULL(Coverage,''Uncategorized''))) = '''' THEN ''Uncategorized'' ELSE ISNULL(Coverage,''Uncategorized'') END CoverageType
		,Form_Type as FormType
		,CASE WHEN LTRIM(RTRIM(ISNULL(State,''UN''))) = '''' THEN ''UN'' ELSE ISNULL(State,''UN'') END State
		,CASE WHEN LTRIM(RTRIM(ISNULL(County,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(County,''Unknown'') END County
		,Company
		,Office
		,YEAR(CreateDate) Year
		,DATEPART(Quarter,CreateDate) Quarter
		,ProcedureCode
		,COUNT(DISTINCT ClaimIDNo) TotalClaims
		,COUNT(DISTINCT CmtIDNo) TotalClaimants
		,SUM(CHARGED) TotalCharged
		,SUM(ALLOWED) TotalAllowed
		,SUM(CHARGED) - SUM(ALLOWED) TotalReductions
		,COUNT(DISTINCT BillIDNo) TotalBills
		,Cast(SUM(UNITS) as Numeric(9,2)) TotalUnits
		,Count(LINE_NO) TotalLines
FROM #DPPerformaceInput 
GROUP BY OdsCustomerId
		,CASE WHEN LTRIM(RTRIM(ISNULL(Coverage,''Uncategorized''))) = '''' THEN ''Uncategorized'' ELSE ISNULL(Coverage,''Uncategorized'') END
		,Form_Type 
		,CASE WHEN LTRIM(RTRIM(ISNULL(State,''UN''))) = '''' THEN ''UN'' ELSE ISNULL(State,''UN'') END 
		,CASE WHEN LTRIM(RTRIM(ISNULL(County,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(County,''Unknown'') END 
		,Company
		,Office
		,YEAR(CreateDate) 
		,DATEPART(Quarter,CreateDate) 
		,ProcedureCode
OPTION (HASH GROUP);'

EXEC (@SQL);

END

GO




IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.ProcedureCodeAnalysisReport_GreenwichData') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProcedureCodeAnalysisReport_GreenwichData
GO

CREATE PROCEDURE dbo.ProcedureCodeAnalysisReport_GreenwichData (
@SourceDatabaseName VARCHAR(50) = 'AcsOds',
@TargetDatabaseName VARCHAR(50) = 'ReportDB')
AS
BEGIN

DECLARE @SQLQuery VARCHAR(MAX) = '
DELETE FROM '+@TargetDatabaseName+'.dbo.ProcedureCodeAnalysis_Output
WHERE DisplayName = ''Greenwich'';

INSERT INTO '+@TargetDatabaseName+'.dbo.ProcedureCodeAnalysis_Output
SELECT 0 AS OdsCustomerId
	,ReportName
    ,''Greenwich'' 
    ,Code
    ,[Desc]
    ,MajorGroup
    ,CoverageType
    ,CoverageTypeDesc
    ,FormType
    ,State
    ,County
    ,Company
    ,Office
    ,Year
    ,Quarter
    ,DateQuarter
    ,TotalCharged*2.3
    ,IndTotalCharged*3.5
    ,TotalAllowed*2.6
    ,IndTotalAllowed*3.6
    ,ClaimCnt*2
    ,IndClaimCnt*4
    ,ClaimantCnt*3
    ,IndClaimantCnt*5
    ,TotalReduction*2
    ,IndTotalReduction*2
    ,TotalBills*3
    ,IndTotalBills*5
    ,TotalLines*2
    ,IndTotalLines*4
    ,TotalUnits*3
    ,IndTotalUnits*4
    ,Getdate()
FROM '+@TargetDatabaseName+'.dbo.ProcedureCodeAnalysis_Output
Where DisplayName = ''Farmers Insurance Group'';'

EXEC (@SQLQuery);

END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.ProcedureCodeAnalysisReport_Industry') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProcedureCodeAnalysisReport_Industry
GO

CREATE PROCEDURE  dbo.ProcedureCodeAnalysisReport_Industry (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@OdsCustomerID INT, 
@ReportID INT )
AS
BEGIN

--DECLARE @DatabaseName VARCHAR(50)='AcsOds',@OdsCustomerID INT=1, @ReportID int = 1

DECLARE @SQL VARCHAR(MAX)

SELECT @SQL = 
 CAST('' AS VARCHAR(MAX)) +
 ' 
TRUNCATE TABLE stg.ProcedureCodeAnalysisIndustry;

INSERT INTO stg.ProcedureCodeAnalysisIndustry
SELECT ''ProcedureCode'' as ReportName
       ,CoverageType
       ,FormType
       ,State
       ,County
       ,Company
        ,Office
       ,Year
       ,Quarter
       ,ProcedureCode
       ,SUM(TotalClaims) IndTotalClaims
	   ,SUM(TotalClaimants) IndTotalClaimants
	   ,SUM(TotalCharged) IndTotalCharged
       ,SUM(TotalAllowed) IndTotalAllowed
	   ,SUM(TotalCharged) - SUM(TotalAllowed) IndTotalReductions
       ,SUM(TotalBills) IndTotalBills
	   ,Cast(SUM(TotalUnits) as Numeric(9,2)) IndTotalUnits
       ,SUM(TotalLines) IndTotalLines
    
FROM stg.ProcedureCodeAnalysisClient PC
INNER JOIN ' + @SourceDatabaseName + '.adm.Customer C
	ON PC.OdsCustomerId = C.CustomerId
	AND C.IncludeInIndustry = 1
GROUP BY CoverageType
		  ,FormType 
		  ,State
		  ,County
		  ,Company 
		  ,Office
		  ,Year
		  ,Quarter
		  ,ProcedureCode
OPTION (HASH GROUP)'

EXEC (@SQL);

END

GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.ProcedureCodeAnalysisReport_Output') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProcedureCodeAnalysisReport_Output
GO

CREATE PROCEDURE  dbo.ProcedureCodeAnalysisReport_Output (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@OdsCustomerID int,
@TargetDatabaseName VARCHAR(50) = 'ReportDB')
AS
BEGIN

-- DECLARE @DatabaseName VARCHAR(50)='AcsOds',@OdsCustomerID int
DECLARE @SQL VARCHAR(MAX);

SET @SQL = CASE WHEN @OdsCustomerID <> 0 THEN '

ALTER INDEX ALL ON   '+@TargetDatabaseName+'.dbo.ProcedureCodeAnalysis_Output DISABLE;

DELETE FROM '+@TargetDatabaseName+'.dbo.ProcedureCodeAnalysis_Output
WHERE OdsCustomerId = '+CAST(@OdsCustomerID as VARCHAR(5))+';' ELSE 

'TRUNCATE TABLE dbo.ProcedureCodeAnalysis_Output;' END+

'
/*Insert Results data into Table*/
INSERT INTO '+@TargetDatabaseName+'.dbo.ProcedureCodeAnalysis_Output (
	 OdsCustomerId
    ,ReportName
    ,DisplayName
    ,CoverageType
    ,CoverageTypeDesc
    ,FormType
    ,STATE
    ,County
    ,Company
    ,Office
    ,Year
    ,Quarter
    ,Code
    ,[DESC]
    ,MajorGroup
    ,DateQuarter
    ,ClaimCnt
    ,IndClaimCnt
    ,ClaimantCnt
    ,IndClaimantCnt
    ,TotalCharged
    ,IndTotalCharged
    ,TotalAllowed
    ,IndTotalAllowed
    ,TotalReduction
    ,IndTotalReduction
    ,TotalBills
    ,IndTotalBills
    ,TotalLines
    ,IndTotalLines
    ,TotalUnits
    ,IndTotalUnits
    )
			
SELECT  C.OdsCustomerId
	   ,C.ReportName
	   ,D.CustomerName DisplayName
	   ,C.CoverageType
	   ,CASE WHEN LTRIM(RTRIM(ISNULL(CV.LongName,''Uncategorized''))) = '''' THEN ''Uncategorized'' ELSE ISNULL(CV.LongName,''Uncategorized'') END CoverageTypeDesc
	   ,C.FormType
	   ,CASE WHEN LTRIM(RTRIM(ISNULL(C.State,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(C.State,''Unknown'') END State
	   ,CASE WHEN LTRIM(RTRIM(ISNULL(C.County,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(C.County,''Unknown'') END County
	   ,C.Company
	   ,C.Office
	   ,C.Year
	   ,C.Quarter
	   ,C.ProcedureCode as Code
	   ,CASE WHEN LTRIM(RTRIM(ISNULL(PRC.PRC_DESC,''Uncategorized''))) = '''' THEN ''Uncategorized'' ELSE ISNULL(PRC.PRC_DESC,''Uncategorized'') END [Desc]
	   ,CASE WHEN LEN(C.ProcedureCode) = 5 AND LTRIM(RTRIM(ISNULL(PRCGP.MajorCategory,''Uncategorized''))) = '''' THEN ''Uncategorized'' 
			 WHEN LEN(C.ProcedureCode) = 13 AND CASE WHEN LTRIM(RTRIM(ISNULL(PRC.PRC_DESC,''Uncategorized''))) = '''' THEN ''Uncategorized'' ELSE ISNULL(PRC.PRC_DESC,''Uncategorized'') END <> ''Uncategorized'' THEN ''GENERIC PHARMACY''
			 ELSE ISNULL(PRCGP.MajorCategory,''Uncategorized'') END MajorGroup
	   ,CAST(C.Year as Varchar(4)) + ''-'' + CASE WHEN C.Quarter = 1 THEN ''01'' WHEN C.Quarter = 2 THEN ''04'' WHEN C.Quarter = 3 THEN ''07'' ELSE ''10'' END    + ''-01'' as DateQuarter
	   ,C.TotalClaims
	   ,I.IndTotalClaims - C.TotalClaims
	   ,C.TotalClaimants
	   ,I.IndTotalClaimants - C.TotalClaimants
	   ,C.TotalCharged
	   ,I.IndTotalCharged - C.TotalCharged
	   ,C.TotalAllowed
	   ,I.IndTotalAllowed - C.TotalAllowed
	   ,C.TotalReductions
	   ,I.IndTotalReductions - C.TotalReductions
	   ,C.TotalBills
	   ,I.IndTotalBills - C.TotalBills
	   ,C.TotalLines  
	   ,I.IndTotalLines - C.TotalLines
	   ,C.TotalUnits
	   ,I.IndTotalUnits - C.TotalUnits
FROM stg.ProcedureCodeAnalysisClient C
LEFT OUTER JOIN stg.ProcedureCodeAnalysisIndustry I
    ON C.ReportName = I.ReportName 
    AND C.CoverageType = I.CoverageType
    AND C.FormType  = I.FormType 
    AND C.State  = I.State 
    AND C.County = I.County
    AND C.Company = I.Company 
    AND C.Office = I.Office
    AND C.Year = I.Year 
    AND C.Quarter = I.Quarter
    AND C.ProcedureCode = I.ProcedureCode
LEFT OUTER JOIN  (  SELECT OdsCustomerId,PRC_CD,PRC_DESC, ROW_NUMBER() OVER (PARTITION BY  OdsCustomerId,PRC_CD ORDER BY EndDate DESC) Rnk
					FROM '+@SourceDatabaseName+'.dbo.cpt_PRC_DICT
					' + CASE WHEN @OdsCustomerId <> 0 THEN 'WHERE OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END + '
					UNION
					SELECT OdsCustomerId,NDCCode,Description, ROW_NUMBER() OVER (PARTITION BY  OdsCustomerId,NDCCode ORDER BY EndDate DESC) Rnk
					FROM '+@SourceDatabaseName+'.dbo.ny_Pharmacy
					' + CASE WHEN @OdsCustomerId <> 0 THEN 'WHERE  OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END + ') AS PRC
    ON C.OdsCustomerId = PRC.OdsCustomerId
	AND C.ProcedureCode = PRC.PRC_CD
	AND PRC.Rnk = 1
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.ProcedureCodeGroup PRCGP 
    ON  C.OdsCustomerID = PRCGP.ODSCustomerID
    AND C.ProcedureCode = PRCGP.ProcedureCode
LEFT OUTER JOIN '+@SourceDatabaseName+'.adm.Customer D
    ON C.OdsCustomerID = D.CustomerId
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.CoverageType CV
    ON  C.OdsCustomerID = CV.OdsCustomerId AND C.CoverageType = CV.ShortName
WHERE ' + CASE WHEN @OdsCustomerId <> 0 THEN ' C.OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3)) + ' AND ' ELSE '' END + ' ( LEN(C.ProcedureCode) = 5 OR (LEN(C.ProcedureCode)=13 AND (CHARINDEX(''-'',C.ProcedureCode,1)+ CHARINDEX(''-'',C.ProcedureCode,7))=17) );

ALTER INDEX ALL ON   '+@TargetDatabaseName+'.dbo.ProcedureCodeAnalysis_Output REBUILD;
'

EXEC (@SQL);

END


GO



IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'adm.GetMaxOdsPostingGroupAuditId') AND type in (N'P', N'PC'))
DROP PROCEDURE adm.GetMaxOdsPostingGroupAuditId
GO

CREATE PROCEDURE adm.GetMaxOdsPostingGroupAuditId(
@SourceDatabaseName VARCHAR(50), 
@OdsCustomerId INT ,
@SnapshotAsOf DATETIME
)  
AS  
BEGIN   
    
DECLARE @SQLScript VARCHAR(MAX),  
		@MaxPostingGroupAuditId INT  
      
CREATE TABLE #PostingGroupAuditData  
(  
 MaxPostingGroupAuditId INT  
)  
SET @SQLScript = ' INSERT INTO #PostingGroupAuditData  
     SELECT    
      MAX(PostingGroupAuditId) LastPostingGroupAuditId    
     FROM     
      '+@SourceDatabaseName +'.adm.PostingGroupAudit pga    
     WHERE    
      pga. CustomerId='+CAST(@OdsCustomerId AS VARCHAR(50))    
      +' AND pga.SnapshotCreateDate <= ''' + CONVERT(VARCHAR(10),@SnapshotAsOf,112) + ''''  
  
   
EXEC (@SQLScript )    
  
SET @MaxPostingGroupAuditId = (SELECT MaxPostingGroupAuditId FROM #PostingGroupAuditData)  
  
RETURN @MaxPostingGroupAuditId  
  
END
GO 



IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderAnalyticsEtlAuditEnd') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderAnalyticsEtlAuditEnd
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerEtlAuditEnd') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerEtlAuditEnd
GO

CREATE PROCEDURE dbo.ProviderDataExplorerEtlAuditEnd(
@AuditFor VARCHAR(50),
@AuditProcess VARCHAR(50),
@AuditOdsPostingGroupAuditId INT,
@ReportId INT)
AS

BEGIN
-- update the end time for the Process in Audit table
DECLARE @LastAuditId INT;

SET @LastAuditId = (
			SELECT
				MAX(AuditId)
			FROM
				dbo.ProviderDataExplorerEtlAudit
			WHERE 
				AuditFor = @AuditFor
				AND AuditProcess = @AuditProcess
				AND DataAsOfOdsPostingGroupAuditId = ISNULL(@AuditOdsPostingGroupAuditId,0)
				AND ReportId = @ReportId
				AND EndDatetime IS NULL
				);

UPDATE
	dbo.ProviderDataExplorerEtlAudit
SET
	EndDatetime = GETDATE(),
	UpdatedDate = GETDATE()
WHERE
	AuditId = @LastAuditId;

END

GO 


IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderAnalyticsEtlAuditStart') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderAnalyticsEtlAuditStart
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerEtlAuditStart') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerEtlAuditStart
GO

CREATE PROCEDURE dbo.ProviderDataExplorerEtlAuditStart(
@AuditFor VARCHAR(50),
@AuditProcess VARCHAR(50),
@AuditOdsPostingGroupAuditId INT,
@ReportId INT)
AS
BEGIN
-- Insert the Process tracking in Audit Table
INSERT INTO dbo.ProviderDataExplorerEtlAudit(
	AuditFor,
	AuditProcess,
	DataAsOfOdsPostingGroupAuditId,
	StartDatetime,
	ReportId
	)
SELECT
	@AuditFor,
	@AuditProcess,
	ISNULL(@AuditOdsPostingGroupAuditId,0),
	GETDATE(),
	@ReportId

END

GO



IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerGreenwichData') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerGreenwichData

GO

CREATE PROCEDURE dbo.ProviderDataExplorerGreenwichData (@ReportId INT,
@SourceDatabaseName VARCHAR(250) = 'AcsOds',
@TargetDatabaseName VARCHAR(250) = 'ReportDB')
AS
BEGIN
DECLARE @AuditFor VARCHAR(30),
		@ProcessName VARCHAR(50),
		@OdsPostingGroupAuditId INT;


SET @AuditFor='OdsCustomerId : 0';

-- Get the Process Name
SET @ProcessName = ( SELECT OBJECT_NAME(@@PROCID) );

-- Tracking Process start in ETL Audit
EXEC dbo.ProviderDataExplorerEtlAuditStart @AuditFor,@ProcessName,@OdsPostingGroupAuditId,@ReportId;

DECLARE @SQLQuery VARCHAR(MAX) 
SET @SQLQuery=  CAST('' AS VARCHAR(MAX))+
	'
	-- Customers used to generate Greenwich data: AAA Michigan, Esurance, Sentry

	-- Inserting ClaimantHeader data for Greenwich

	DELETE FROM ' + @TargetDatabaseName + '.dbo.ProviderDataExplorerClaimantHeader
	WHERE OdsCustomerId in (0)

	IF OBJECT_ID(''tempdb..#ClaimantHeader'') IS NOT NULL
		DROP TABLE #ClaimantHeader

	SELECT 
			0 OdsPostingGroupAuditId,
			0 OdsCustomerId,
			 ClaimId,
			 ClaimId AS ClaimNumber,
			 DateLoss,
			 CVCode,
			 LossState,
			 ClaimantId,			 
			 ClaimantState,
			 ClaimantZip,			 
			 ClaimantStateofJurisdiction,
			 CoverageType,
			 ClaimantHeaderId,
			 ProviderId,
			 CreateDate,
			 LastChangedOn,
			 MinimumDateofService,
			 MaximumDateofService,
			 DOSTenureInDays,
			 ExpectedTenureInDays,
			 ExpectedRecoveryDate,
			 ''Greenwich'' CustomerName,
			 InjuryDescription,
			 InjuryNatureId,
			 InjuryNaturePriority,
			 DerivedCVType,
			 DerivedCVDesc,
			 ClaimantZipLat,
			 ClaimantZipLong,
			 MSADesignation,
			 CBSADesignation,
			 CVCodeDesciption,
			 CoverageTypeDescription,
			 RunDate,
			 ROW_NUMBER() OVER(PARTITION BY ClaimantHeaderId order by OdscustomerId) RowNum
	INTO #ClaimantHeader 
    FROM  ' + @TargetDatabaseName + '.dbo.ProviderDataExplorerClaimantHeader cmt 
	WHERE   OdsCustomerId IN (2,19,47 )

	INSERT INTO ' + @TargetDatabaseName + '.dbo.ProviderDataExplorerClaimantHeader(
			OdsPostingGroupAuditId,
			 OdsCustomerId,
			 ClaimId,
			 ClaimNumber,
			 DateLoss,
			 CVCode,
			 LossState,
			 ClaimantId,
			 ClaimantState,
			 ClaimantZip,
			 ClaimantStateofJurisdiction,
			 CoverageType,
			 ClaimantHeaderId,
			 ProviderId,
			 CreateDate,
			 LastChangedOn,
			 MinimumDateofService,
			 MaximumDateofService,
			 DOSTenureInDays,
			 ExpectedTenureInDays,
			 ExpectedRecoveryDate,
			 CustomerName,
			 InjuryDescription,
			 InjuryNatureId,
			 InjuryNaturePriority,
			 DerivedCVType,
			 DerivedCVDesc,
			 ClaimantZipLat,
			 ClaimantZipLong,
			 MSADesignation,
			 CBSADesignation,
			 CVCodeDesciption,
			 CoverageTypeDescription,
			 RunDate
	)
	SELECT 
			OdsPostingGroupAuditId,
			OdsCustomerId,
			 ClaimId,
			 ClaimId AS ClaimNumber,
			 DateLoss,
			 CVCode,
			 LossState,
			 ClaimantId,
			 ClaimantState,
			 ClaimantZip,
			 ClaimantStateofJurisdiction,
			 CoverageType,
			 ClaimantHeaderId,
			 ProviderId,
			 CreateDate,
			 LastChangedOn,
			 MinimumDateofService,
			 MaximumDateofService,
			 DOSTenureInDays,
			 ExpectedTenureInDays,
			 ExpectedRecoveryDate,
			 CustomerName,
			 InjuryDescription,
			 InjuryNatureId,
			 InjuryNaturePriority,
			 DerivedCVType,
			 DerivedCVDesc,
			 ClaimantZipLat,
			 ClaimantZipLong,
			 MSADesignation,
			 CBSADesignation,
			 CVCodeDesciption,
			 CoverageTypeDescription,
			 RunDate	
    FROM  #ClaimantHeader c
	WHERE  RowNum = 1

	-- Inserting BillHeader data for Greenwich
	DELETE FROM ' + @TargetDatabaseName + '.dbo.ProviderDataExplorerBillHeader
	WHERE OdsCustomerId in (0)

	IF OBJECT_ID(''tempdb..#BillHeader'') IS NOT NULL
		DROP TABLE #BillHeader

	SELECT 
			0 OdsPostingGroupAuditId,
			0 OdsCustomerId,
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
			 CVTypeDescription,
			 RunDate,
			 ROW_NUMBER() OVER(PARTITION BY BillId order by OdscustomerId) RowNum
	INTO #BillHeader		 				
	FROM ' + @TargetDatabaseName + '.dbo.ProviderDataExplorerBillHeader
	WHERE   OdsCustomerId IN (2,19,47 )

	INSERT INTO ' + @TargetDatabaseName + '.dbo.ProviderDataExplorerBillHeader
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
			 CVTypeDescription,
			 RunDate
		)
	SELECT 
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
			 CVTypeDescription,
			 RunDate							
	FROM #BillHeader
	WHERE RowNum = 1

	-- Inserting BillLine data for Greenwich
	DELETE FROM ' + @TargetDatabaseName + '.dbo.ProviderDataExplorerBillLine
	WHERE OdsCustomerId in (0)

	IF OBJECT_ID(''tempdb..#BillLine'') IS NOT NULL
	DROP TABLE #BillLine

	SELECT 
			0 OdsPostingGroupAuditId,
			0 OdsCustomerId,
			 BillId,
			 LineNumber,
			 OverRide,
			 DateofService,
			 ProcedureCode,
			 Units,
			 Charged,
			 Allowed,
			 Analyzed,
			 RefLineNo,
			 POSRevCode,
			 Adjustment,
			 FormType,
			 CodeType,
			 Code,
			 CodeDescription,
			 Category,
			 SubCategory,
			 BillLineType,
			 BundlingFlag,
			 ExceptionFlag,
			 ExceptionComments,
			 VisitType,
			 BillInjuryDescription,
			 ProviderZoSLat,
			 ProviderZoSLong,
			 ProviderZoSState,
			 ModalityType,
			 ModalityUnitType,
			 RunDate,
			 SubFormType,
			 Modifier,
			 EndNote,			
			 ROW_NUMBER() OVER(PARTITION BY BillId,LineNumber,BillLineType order by OdscustomerId) RowNum
	INTO #BillLine	
	FROM  ' + @TargetDatabaseName + '.dbo.ProviderDataExplorerBillLine b 
	WHERE   OdsCustomerId IN (2,19,47 )

	INSERT INTO ' + @TargetDatabaseName + '.dbo.ProviderDataExplorerBillLine(
			OdsPostingGroupAuditId,
			 OdsCustomerId,
			 BillId,
			 LineNumber,
			 OverRide,
			 DateofService,
			 ProcedureCode,
			 Units,
			 Charged,
			 Allowed,
			 Analyzed,
			 RefLineNo,
			 POSRevCode,
			 Adjustment,
			 FormType,
			 CodeType,
			 Code,
			 CodeDescription,
			 Category,
			 SubCategory,
			 BillLineType,
			 BundlingFlag,
			 ExceptionFlag,
			 ExceptionComments,
			 VisitType,
			 BillInjuryDescription,
			 ProviderZoSLat,
			 ProviderZoSLong,
			 ProviderZoSState,
			 ModalityType,
			 ModalityUnitType,
			 RunDate,
			 SubFormType,
			 Modifier,
			 EndNote					
			)
	SELECT 
			OdsPostingGroupAuditId,
			OdsCustomerId,
			 BillId,
			 LineNumber,
			 OverRide,
			 DateofService,
			 ProcedureCode,
			 Units,
			 Charged,
			 Allowed,
			 Analyzed,
			 RefLineNo,
			 POSRevCode,
			 Adjustment,
			 FormType,
			 CodeType,
			 Code,
			 CodeDescription,
			 Category,
			 SubCategory,
			 BillLineType,
			 BundlingFlag,
			 ExceptionFlag,
			 ExceptionComments,
			 VisitType,
			 BillInjuryDescription,
			 ProviderZoSLat,
			 ProviderZoSLong,
			 ProviderZoSState,
			 ModalityType,
			 ModalityUnitType,
			 RunDate,
			 SubFormType,
			 Modifier,
			 EndNote				
	FROM  #BillLine b 
	WHERE RowNum = 1

	-- Inserting Provider data for Greenwich
	DELETE FROM ' + @TargetDatabaseName + '.dbo.ProviderDataExplorerProvider
	WHERE OdsCustomerId in (0)

	IF OBJECT_ID(''tempdb..#Provider'') IS NOT NULL
		DROP TABLE #Provider

	SELECT 
			0 OdsPostingGroupAuditId,
			0 OdsCustomerId,
			ProviderId,
			ProviderTIN,
			ProviderFirstName, 
			ProviderLastName, 
			ProviderGroup, 
			ProviderState, 
			ProviderZip, 
			ProviderSPCList, 
			ProviderNPINumber, 
			ProviderName, 
			ProviderTypeID, 
			ProviderClusterId, 
			ProviderClusterName, 
			Specialty, 
			ClusterSpecialty, 
			CreatedDate, 
			RunDate,
			ROW_NUMBER() OVER(PARTITION BY ProviderId order by OdscustomerId) RowNum
	INTO #Provider
	FROM  ' + @TargetDatabaseName + '.dbo.ProviderDataExplorerProvider
	WHERE   OdsCustomerId IN (2,19,47)

	INSERT INTO ' + @TargetDatabaseName + '.dbo.ProviderDataExplorerProvider(
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
			ProviderName, 
			ProviderTypeID, 
			ProviderClusterId, 
			ProviderClusterName, 
			Specialty, 
			ClusterSpecialty, 
			CreatedDate, 
			RunDate	
	)
	SELECT 
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
			ProviderName, 
			ProviderTypeID, 
			ProviderClusterId, 
			ProviderClusterName, 
			Specialty, 
			ClusterSpecialty, 
			CreatedDate, 
			RunDate
	FROM  #Provider p
	WHERE  RowNum = 1
'
EXEC (@SQLQuery)



-- Tracking Process end in ETL Audit
EXEC dbo.ProviderDataExplorerEtlAuditEnd @AuditFor,@ProcessName,@OdsPostingGroupAuditId,@ReportId;

END


GO


IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerIndustryEtlAuditEnd') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerIndustryEtlAuditEnd
GO

CREATE PROCEDURE dbo.ProviderDataExplorerIndustryEtlAuditEnd(
@AuditFor VARCHAR(50),
@AuditProcess VARCHAR(50),
@ReportId INT)
AS

BEGIN
-- update the end time for the Process in Audit table
DECLARE @LastAuditId INT;

SET @LastAuditId = (
			SELECT
				MAX(AuditId)
			FROM
				dbo.ProviderDataExplorerIndustryEtlAudit
			WHERE 
				AuditFor = @AuditFor
				AND AuditProcess = @AuditProcess
				AND ReportId = @ReportId
				AND EndDatetime IS NULL
				);

UPDATE
	dbo.ProviderDataExplorerIndustryEtlAudit
SET
	EndDatetime = GETDATE(),
	UpdatedDate = GETDATE()
WHERE
	AuditId = @LastAuditId;

END


GO



IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerIndustryEtlAuditStart') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerIndustryEtlAuditStart
GO

CREATE PROCEDURE dbo.ProviderDataExplorerIndustryEtlAuditStart(
@AuditFor VARCHAR(50),
@AuditProcess VARCHAR(50),
@ReportId INT)
AS
BEGIN
-- Insert the Process tracking in Audit Table
INSERT INTO dbo.ProviderDataExplorerIndustryEtlAudit(
	AuditFor,
	AuditProcess,
	StartDatetime,
	ReportId
	)
SELECT
	@AuditFor,
	@AuditProcess,
	GETDATE(),
	@ReportId

END

GO


IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerIndustryInitialLoadPrep') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerIndustryInitialLoadPrep
GO

CREATE PROCEDURE dbo.ProviderDataExplorerIndustryInitialLoadPrep (@IsCustomerIncrementalLoad INT,@ReportId INT)  
AS  
BEGIN  
-- If full load then Initialize the Start Date for DateLoss
IF (@IsCustomerIncrementalLoad = 0)  
BEGIN  

  /*Update Start date of the Report in adm.Reportparameter table. */
 UPDATE  
   epsd  
 SET  
   ParameterValue = CONVERT(VARCHAR(25),DATEADD(MONTH,(-1*epgb.ParameterValue),DATEADD(month, DATEDIFF(month, -1 , getdate()) - 1, 0)),110)  
 FROM  
  adm.ReportParameters epsd  
  JOIN adm.ReportParameters epgb ON epsd.ParameterName = 'ODSPDEICStartDate' AND epsd.ReportId = @ReportId
              AND epgb.ParameterName = 'ODSPDEICGobackby' AND epgb.ReportId = @ReportId;

/*Update Enddate of the Report in adm.Reportparameter table. */
UPDATE  adm.reportparameters
		SET ParameterValue = DATEADD(MONTH,DATEDIFF(MONTH,-1,GETDATE())-1,-1)  
	WHERE ParameterName = 'ODSPDEICEndDate' AND ReportId = @ReportId
	  
DECLARE @TruncateFlag INT;
SELECT @TruncateFlag = ParameterValue FROM  adm.ReportParameters 
WHERE ReportId = @ReportId and ParameterName ='InitialLoadTruncateFlag'

DECLARE  @ReportName VARCHAR(255)
		,@SQLScript NVARCHAR(MAX)
		,@TrackingTable VARCHAR(255)
		,@IsResumed INT	
		
-- Get report Name
SET @SQLScript = 'SELECT @ReportName = RTRIM(LTRIM(REPLACE(ReportJobName,''RPT:'',''''))) FROM adm.ReportJob WHERE ReportID = '+CAST(@ReportId AS VARCHAR(3));
EXEC sp_executesql @SQLScript,N'@ReportName VARCHAR(255) OUT',@ReportName OUT;

-- Get Tracking table Name
SELECT 
	@TrackingTable = TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE='BASE TABLE'
	AND TABLE_NAME LIKE REPLACE(@ReportName,' ','_')+'_Tracking%';

-----Get the status of the track table 0-New Load 1-Incomplete Load
SET @SQLScript = 'SELECT @IsResumed = MAX(IsCustomerDone) FROM stg.'+@TrackingTable+' WHERE IsCustomerDone = 1'
EXEC sp_executesql @SQLScript,N'@IsResumed INT OUT',@IsResumed OUT

/* Get customerId for partially loaded customer in case of job restart.*/
DECLARE @Script NVARCHAR(MAX)
DECLARE @CustomerId INT
SET @Script = 'SELECT @CustomerId = OdsCustomerId  FROM stg.'+@TrackingTable+' WHERE IsCustomerDone = 0'
EXEC sp_executesql @Script,N'@CustomerId INT OUT',@CustomerId OUT

/* Delete records of partially loaded customer in case of job restart.*/
IF( @CustomerId <> 0)
BEGIN

DELETE FROM dbo.ProviderDataExplorerIndustryCustomerOutput
	   WHERE OdsCustomerId = @CustomerId;

END

-- If full load then Truncate the tables
	IF (@TruncateFlag = 1 AND ISNULL(@IsResumed,0) = 0)  
	BEGIN  
			 TRUNCATE TABLE dbo.ProviderDataExplorerIndustryCustomerOutput;  

	END

END  
  
END

GO

    
  

IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerIndustryLoadBillHeader') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerIndustryLoadBillHeader
GO

CREATE PROCEDURE dbo.ProviderDataExplorerIndustryLoadBillHeader(
@SourceDatabaseName VARCHAR(50),
@StartDate AS DATETIME,
@EndDate AS DATETIME,
@Debug BIT,
@ReportId INT
)
AS
BEGIN

DECLARE @ProcessName VARCHAR(50),
		@AuditFor VARCHAR(100)
-- Track the Audit for Customer
SET @AuditFor = 'OdsCustomerId : 0'

-- Get the Process Name
SET @ProcessName = ( SELECT OBJECT_NAME(@@PROCID) );

-- Tracking Process start in ETL Audit
EXEC dbo.ProviderDataExplorerIndustryEtlAuditStart @AuditFor,@ProcessName,@ReportId;

DECLARE @SQLScript VARCHAR(MAX)

SET @SQLScript =
' 

-- Create Index on stg.ProviderDataExplorerIndustryClaimantHeader
IF EXISTS (SELECT Name FROM sys.indexes  WHERE Name=''IDX_PDEIC_CHOdsCustomerIdCHId'' 
    AND object_id = OBJECT_ID(''stg.ProviderDataExplorerIndustryClaimantHeader''))
  BEGIN
    DROP INDEX IDX_PDEIC_CHOdsCustomerIdCHId ON stg.ProviderDataExplorerIndustryClaimantHeader;
  END
  CREATE INDEX IDX_PDEIC_CHOdsCustomerIdCHId ON stg.ProviderDataExplorerIndustryClaimantHeader (OdsCustomerId,ClaimantHeaderId);
  

TRUNCATE TABLE stg.ProviderDataExplorerIndustryBillHeader;

INSERT INTO stg.ProviderDataExplorerIndustryBillHeader(
			OdsCustomerId,
			BillId,
			ClaimantHeaderId,
			CVType,			
			Flags,
			TypeOfBill,
			CVTypeDescription
			
)
SELECT 	
			bh.OdsCustomerId,
			bh.BillIdNo,
			bh.CMT_HDR_IdNo,
			bh.CV_Type,
			bh.Flags,
			bh.TypeOfBill,			
			cvt.LongName
			
		FROM '
		+ CHAR(13)+CHAR(10)+CHAR(9)+@SourceDatabaseName+'.dbo.BILL_HDR bh
		INNER JOIN stg.ProviderDataExplorerIndustryClaimantHeader ch ON bh.OdsCustomerId = ch.OdsCustomerId
												AND bh.CMT_HDR_IdNo = ch.ClaimantHeaderId
		LEFT JOIN '+@SourceDatabaseName+'.dbo.CoverageType cvt ON bh.OdsCustomerId = cvt.OdsCustomerId 
															  AND bh.CV_Type = cvt.ShortName
														
		 DROP INDEX IDX_PDEIC_CHOdsCustomerIdCHId ON stg.ProviderDataExplorerIndustryClaimantHeader;'
		

IF(@Debug  = 1)
BEGIN
	PRINT @AuditFor;	
	PRINT @ProcessName;	
	PRINT(@SQLScript);
END

EXEC(@SQLScript);

-- Tracking Process end in ETL Audit
EXEC dbo.ProviderDataExplorerIndustryEtlAuditEnd @AuditFor,@ProcessName,@ReportId;

END

GO



IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerIndustryLoadBillLine') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerIndustryLoadBillLine
GO

CREATE PROCEDURE dbo.ProviderDataExplorerIndustryLoadBillLine(
@SourceDatabaseName VARCHAR(50),
@StartDate AS DATETIME,
@EndDate AS DATETIME,
@Debug BIT,
@ReportId INT
)
AS
BEGIN

DECLARE 
		@ProcessName VARCHAR(50),
		@AuditFor VARCHAR(100)		

-- Track the Audit for Customer
SET @AuditFor = 'OdsCustomerId : 0'

-- Get the Process Name
SET @ProcessName = ( SELECT OBJECT_NAME(@@PROCID) );

-- Tracking Process start in ETL Audit
EXEC dbo.ProviderDataExplorerIndustryEtlAuditStart @AuditFor,@ProcessName,@ReportId;

DECLARE @SQLScript VARCHAR(MAX)
		

SET @SQLScript = CAST('' AS VARCHAR(MAX))+
'

-- Fetching RevenueCodes, Cpt_prc codes and category,subcategory for revenue codes.

IF OBJECT_ID(''tempdb..#RevenueCodes'') IS NOT NULL
	DROP TABLE #RevenueCodes

SELECT * INTO #RevenueCodes FROM '+@SourceDatabaseName+'.dbo.ub_revenuecodes

UPDATE	rc
SET
	revenuecodesubcategoryid=rc2.revenuecodesubcategoryid
FROM
	#RevenueCodes rc
	JOIN (SELECT DISTINCT revenuecode,revenuecodesubcategoryid FROM #RevenueCodes WHERE  revenuecodesubcategoryid IS NOT NULL) rc2 ON
	rc.revenuecode=rc2.revenuecode AND rc.revenuecodesubcategoryid IS NULL

IF OBJECT_ID(''tempdb..#CodeHierarchy'') IS NOT NULL
	DROP TABLE #CodeHierarchy
	
SELECT
	''Procedure'' Dataset,
	odscustomerid OdsCustomerId,	
	prc_cd Code,
	SUBSTRING(prc_desc,0,2500) Description,
	''Procedure'' Category,
	''Procedure'' SubCategory,
	StartDate,
	EndDate
INTO #CodeHierarchy
FROM
	'+@SourceDatabaseName+'.dbo.cpt_prc_dict

UNION

SELECT
	''Revenue'' Dataset,
	rc.odscustomerid,	
	rc.revenuecode,
	SUBSTRING(rc.prc_desc,0,2500) prc_desc,
	UPPER(rcc.Description),
	UPPER(rcsc.Description),
	StartDate,
	EndDate
FROM
	#RevenueCodes rc
	LEFT JOIN '+@SourceDatabaseName+'.dbo.revenuecodesubcategory rcsc ON rc.revenuecodesubcategoryid=rcsc.revenuecodesubcategoryid AND rc.odscustomerid=rcsc.odscustomerid 
	LEFT JOIN '+@SourceDatabaseName+'.dbo.revenuecodecategory rcc ON rcsc.revenuecodecategoryid=rcc.revenuecodecategoryid AND rcsc.odscustomerid=rcc.odscustomerid 


IF EXISTS (SELECT Name FROM tempdb.sys.indexes  WHERE Name = ''IDXPACodeHierarchyCode'' 
    AND object_id = OBJECT_ID(''tempdb..#CodeHierarchy''))
  BEGIN
    DROP INDEX IDXPACodeHierarchyCode ON #CodeHierarchy;
  END
CREATE INDEX IDXPACodeHierarchyCode ON #CodeHierarchy (DataSet,Code);


-- Creating Index on BillHeader
IF EXISTS (SELECT Name FROM sys.indexes  WHERE Name=''IDX_PDE_IC_CHOdsCustomerIdBillIdNo'' 
    AND object_id = OBJECT_ID(''stg.ProviderDataExplorerIndustryBillHeader''))
  BEGIN
    DROP INDEX IDX_PDE_IC_CHOdsCustomerIdBillIdNo ON stg.ProviderDataExplorerIndustryBillHeader;
  END
CREATE INDEX IDX_PDE_IC_CHOdsCustomerIdBillIdNo ON stg.ProviderDataExplorerIndustryBillHeader (OdsCustomerId,BillId,TypeOfBill);


TRUNCATE TABLE stg.ProviderDataExplorerIndustryBillLine;

DECLARE @ODSPDEICPRCodeTypePharma  VARCHAR(100),
		@ODSPDEICUB04 VARCHAR(10),
		@ODSPDEICCMS1500 VARCHAR(10),
		@ODSPDEICBillLineTypePharma VARCHAR(30),
		@ODSPDEICBillLineType VARCHAR(30),
		@ODSPDEICPRDescPharma VARCHAR(100),
		@ODSPDEICPRCategoryPharma VARCHAR(100),
		@ODSPDEICPRSubCategoryPharma VARCHAR(100);

		SELECT @ODSPDEICUB04 = ParameterValue FROM  adm.ReportParameters WHERE ReportId = '+CAST(@ReportId AS VARCHAR(3))+' AND ParameterName = ''ODSPDEICUB04''
		SELECT @ODSPDEICCMS1500 = ParameterValue FROM  adm.ReportParameters WHERE ReportId = '+CAST(@ReportId AS VARCHAR(3))+' AND ParameterName = ''ODSPDEICCMS1500''
		SELECT @ODSPDEICBillLineType = ParameterValue FROM  adm.ReportParameters WHERE ReportId = '+CAST(@ReportId AS VARCHAR(3))+' AND ParameterName = ''ODSPDEICBillLineType''
		SELECT @ODSPDEICPRCodeTypePharma = ParameterValue FROM adm.ReportParameters WHERE ReportId = '+CAST(@ReportId AS VARCHAR(3))+' AND ParameterName = ''ODSPDEICPRCodeTypePharma''
		SELECT @ODSPDEICPRDescPharma = ParameterValue FROM adm.ReportParameters WHERE ReportId = '+CAST(@ReportId AS VARCHAR(3))+' AND ParameterName = ''ODSPDEICPRDescPharma''
		SELECT @ODSPDEICPRCategoryPharma = ParameterValue FROM adm.ReportParameters WHERE ReportId = '+CAST(@ReportId AS VARCHAR(3))+' AND ParameterName = ''ODSPDEICPRCategoryPharma''
		SELECT @ODSPDEICPRSubCategoryPharma = ParameterValue FROM adm.ReportParameters WHERE ReportId = '+CAST(@ReportId AS VARCHAR(3))+' AND ParameterName = ''ODSPDEICPRSubCategoryPharma''
		SELECT @ODSPDEICBillLineTypePharma = ParameterValue FROM  adm.ReportParameters WHERE ReportId = '+CAST(@ReportId AS VARCHAR(3))+' AND ParameterName = ''ODSPDEICBillLineTypePharma''

		-- Loading BillLines  and PharmabillLines by Union
INSERT INTO stg.ProviderDataExplorerIndustryBillLine(
			OdsCustomerId,
			BillId,
			LineNumber,			
			OverRide,
			DateofService,
			ProcedureCode,			
			Charged,
			Allowed,			
			RefLineNo,
			POSRevCode,
			Adjustment,
			FormType,
			CodeType,
			Code,
			BillLineType,
			CodeDescription,
			Category,
			SubCategory,
			IsCodeNumeric		
)
SELECT 		
			b.OdsCustomerId,
			b.BillIdNo,
			b.LINE_NO,			
			b.Over_Ride,
			b.DT_SVC,
			b.PRC_CD,
			b.Charged,
			b.Allowed,
			b.REF_LINE_NO,
			b.POS_RevCode,
			ISNULL(b.CHARGED, 0) - ISNULL(b.ALLOWED, 0) AS Adjustment,
			    CASE
                  WHEN(bh.Flags&4096) = 4096
                  THEN @ODSPDEICUB04
                  ELSE @ODSPDEICCMS1500
              END AS FormTypeDesc,
			  CASE
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)=''3'' THEN ''Procedure''
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)<>''3'' THEN ''REVENUE''
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')='''' THEN ''REVENUE''
			ELSE ''Procedure'' END PR_Code_Type,
			  CASE
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)=''3'' THEN b.prc_cd
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)<>''3'' THEN b.pos_revcode
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')='''' THEN b.pos_revcode
			ELSE b.prc_cd END PR_Code,
			@ODSPDEICBillLineType,
			ch.Description CodeDescription,
			ch.Category CodeCategory,
			ch.SubCategory CodeSubCategory,
			CASE WHEN ISNUMERIC(b.PRC_CD) = 1 THEN 1 
				 WHEN ISNUMERIC(b.PRC_CD) = 0 THEN 0 END		

	FROM '+@SourceDatabaseName+'.dbo.BILLS b 
	INNER JOIN stg.ProviderDataExplorerIndustryBillHeader bh ON b.OdsCustomerId = bh.OdsCustomerId 
																				AND b.BillIdNo = bh.BillId
	LEFT JOIN #CodeHierarchy ch ON	 CASE
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)=''3'' THEN ''Procedure''
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)<>''3'' THEN ''Revenue''
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')='''' THEN ''Revenue''
			ELSE ''Procedure'' END = ch.Dataset
			AND
					 CASE
							WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)=''3'' THEN b.prc_cd
							WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)<>''3'' THEN b.pos_revcode
							WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')='''' THEN b.pos_revcode
					ELSE b.prc_cd END = ch.Code
			AND b.DT_SVC BETWEEN ch.StartDate AND ch.EndDate
			AND b.OdsCustomerId = ch.OdsCustomerId        
		
		WHERE  b.PRC_CD <> ''COORD''

UNION 
-- Loading Pharmacy bills
SELECT 		
			bp.OdsCustomerId,
			bp.BillIdNo,
			bp.LINE_NO,
			bp.OverRide,
			bp.DateOfService,
			REPLACE(bp.NDC,''-'','''') AS NDC,
			bp.Charged,
			bp.Allowed,
			0,
			bp.POS_RevCode,
			ISNULL(bp.CHARGED, 0) - ISNULL(bp.ALLOWED, 0) AS Adjustment,
			CASE
               WHEN(bh.Flags&4096) = 4096
               THEN @ODSPDEICUB04
               ELSE @ODSPDEICCMS1500
			 END AS FormTypeDesc,			
			@ODSPDEICPRCodeTypePharma AS PR_Code_Type,			 
			CONVERT(VARCHAR(100),REPLACE(NDC,''-'','''')) AS PR_Code,
			@ODSPDEICBillLineTypePharma,			
			@ODSPDEICPRDescPharma,
			@ODSPDEICPRCategoryPharma,
			@ODSPDEICPRSubCategoryPharma,
			CASE WHEN ISNUMERIC(REPLACE(bp.NDC,''-'','''')) = 1 THEN 1 
				 WHEN ISNUMERIC(REPLACE(bp.NDC,''-'','''')) = 0 THEN 0 END			

		FROM '+@SourceDatabaseName+'.dbo.Bills_Pharm bp
		INNER JOIN stg.ProviderDataExplorerIndustryBillHeader bh ON bp.OdsCustomerId = bh.OdsCustomerId 
																				AND bp.BillIdNo = bh.BillId												
			
		DROP INDEX IDX_PDE_IC_CHOdsCustomerIdBillIdNo ON stg.ProviderDataExplorerIndustryBillHeader;
			
	   DELETE b  
       FROM  stg.ProviderDataExplorerIndustryBillLine b 
	   INNER JOIN '+@SourceDatabaseName+'.dbo.BILLS_Endnotes e ON b.BillId = e.BillIDNo 
													AND b.LineNumber = e.LINE_NO 
													AND b.OdsCustomerId = e.OdsCustomerId
       WHERE e.EndNote = 45 ;
	   
-- Update the category and subcategory for RC codes like 
-- RC250 is replaced with 0250 and provider category and subcategory 
	   
UPDATE	b 
SET
	b.Category = rc.Category,
	b.SubCategory = rc.SubCategory
FROM
	stg.ProviderDataExplorerIndustryBillLine b
    INNER JOIN  rpt.ProviderDataExplorerPRCodeDataQuality Pr ON b.Code = pr.Code 
												AND  ISNULL(pr.Category,'''' ) = '''' 
												AND pr.MappedCode = ''RC''
												AND b.Code like ''RC%''
	INNER JOIN #CodeHierarchy rc ON REPLACE(b.Code,''RC'',''0'') = rc.Code 
												AND b.OdsCustomerId = rc.OdsCustomerId ;

		
IF EXISTS (SELECT Name FROM sys.indexes  WHERE Name = ''IDPA_ProviderDataExplorerIndustryBillLinePOSRevCode'' 
    AND object_id = OBJECT_ID(''stg.ProviderDataExplorerIndustryBillLine''))
	BEGIN
    DROP INDEX IDPA_ProviderDataExplorerIndustryBillLinePOSRevCode ON stg.ProviderDataExplorerIndustryBillLine;
  END
CREATE INDEX IDPA_ProviderDataExplorerIndustryBillLinePOSRevCode ON stg.ProviderDataExplorerIndustryBillLine (BillId,POSRevCode);


-- Calculation for subformtype based on UB_BillType and PlaceOfServiceDictionary tables.

IF OBJECT_ID(''tempdb..#SubFormTypeTemp'') IS NOT NULL
	DROP TABLE #SubFormTypeTemp
SELECT  Bl.OdsCustomerId,
		Bl.BillId,
		Bl.LineNumber,
		ISNULL(CASE WHEN  bl.FormType = ''CMS-1500'' THEN Ps.Description 
								     WHEN  bl.FormType = ''UB-04''    THEN SUBSTRING(bt.Description,1,CHARINDEX('';'',bt.Description)-1)						   
						        END ,''N/A'') SubFormType
		INTO #SubFormTypeTemp
FROM stg.ProviderDataExplorerIndustryBillHeader bh 
INNER JOIN stg.ProviderDataExplorerIndustryBillLine bl ON bl.BillId = bh.BillId 
												AND bl.OdsCustomerId = bh.OdsCustomerId 												
LEFT JOIN '+@SourceDatabaseName+'.dbo.UB_BillType bt on bh.TypeOfBill = bt.tob 
												AND bl.OdsCustomerId = bt.OdsCustomerId 												
LEFT JOIN '+@SourceDatabaseName+'.dbo.PlaceOfServiceDictionary ps ON  bl.POSRevCode = RIGHT(CONCAT(''00'', ISNULL(CONVERT(VARCHAR(2),ps.PlaceOfServiceCode),'''')),2)
												AND bl.OdsCustomerId = ps.OdsCustomerId 
												AND (CONVERT(DATE,bl.DateOfService) BETWEEN StartDate AND EndDate)
		
		
	IF EXISTS (SELECT Name FROM tempdb.sys.indexes  WHERE Name = ''IDXPA_PDE_IC_SubFormTypeTempBillIdNo'' 
    AND object_id = OBJECT_ID(''tempdb..#SubFormTypeTemp''))
  BEGIN
    DROP INDEX IDXPA_PDE_IC_SubFormTypeTempBillIdNo ON #SubFormTypeTemp;
  END
CREATE INDEX IDXPA_PDE_IC_SubFormTypeTempBillIdNo ON #SubFormTypeTemp (OdsCustomerId,BillId,LineNumber);
		
	-- Update Subformtype into ProviderDataExplorerIndustryBillLine table
												
	UPDATE bl 
		SET 
		bl.SubFormType = ISNULL(UPPER( sf.SubFormType ), ''N/A'')
FROM stg.ProviderDataExplorerIndustryBillLine bl 
INNER JOIN  #SubFormTypeTemp SF ON SF.OdsCustomerId= bl.OdsCustomerId 
									AND  SF.BillId = bl.BillId 
									AND SF.LineNumber = bl.LineNumber
	
	
IF EXISTS (SELECT Name FROM sys.indexes  WHERE Name = ''IDPA_ProviderDataExplorerIndustryBillLinePOSRevCode'' 
    AND object_id = OBJECT_ID(''stg.ProviderDataExplorerIndustryBillLine''))
	BEGIN
    DROP INDEX IDPA_ProviderDataExplorerIndustryBillLinePOSRevCode ON stg.ProviderDataExplorerIndustryBillLine;
  END

  


  /*Implementing Category and subscategory logic.
  Using static rpt tables.
  */

   DECLARE @ODSPDEICPRDesc VARCHAR(100),
		@ODSPDEICPRCategory VARCHAR(100),
		@ODSPDEICPRSubCategory VARCHAR(100)	
		
		SELECT @ODSPDEICPRDesc = ParameterValue FROM  adm.ReportParameters WHERE ReportId = '+CAST(@ReportId AS VARCHAR(3))+' AND ParameterName = ''ODSPDEICPRDesc''
		SELECT @ODSPDEICPRCategory = ParameterValue FROM  adm.ReportParameters WHERE ReportId = '+CAST(@ReportId AS VARCHAR(3))+' AND ParameterName = ''ODSPDEICPRCategory''
		SELECT @ODSPDEICPRSubCategory = ParameterValue FROM  adm.ReportParameters WHERE ReportId = '+CAST(@ReportId AS VARCHAR(3))+' AND ParameterName = ''ODSPDEICPRSubCategory''



  IF OBJECT_ID(''tempdb..#IsCodeNumericzeroDP'',''U'') IS NOT NULL
		DROP TABLE #IsCodeNumericzeroDP;

   SELECT CodeStart,
	      CodeEnd,
	      Category,
	      SubCategory,
	      Description,
	      CodeType,
	      IsCodeNumeric
	INTO #IsCodeNumericzeroDP
	FROM rpt.ProviderDataExplorerCodeHierarchy WHERE IsCodeNumeric = 0
IF EXISTS (SELECT Name FROM tempdb.sys.indexes
			WHERE Name = ''IX_IsCodeNumericzeroDP''
			AND OBJECT_ID = OBJECT_ID(''tempdb..#IsCodeNumericzeroDP''))
BEGIN
DROP INDEX IX_IsCodeNumericzeroDP ON #IsCodeNumericzeroDP ;
END
CREATE INDEX IX_IsCodeNumericzeroDP ON #IsCodeNumericzeroDP (CodeStart,CodeEnd);


IF OBJECT_ID(''tempdb..#IsCodeNumericOneDP'',''U'') IS NOT NULL
		DROP TABLE #IsCodeNumericOneDP;

   SELECT CodeStart,
	      Category,
	      SubCategory,
	      Description,
	      CodeType,
	      IsCodeNumeric
	INTO #IsCodeNumericOneDP
	FROM rpt.ProviderDataExplorerCodeHierarchy WHERE IsCodeNumeric = 1 
IF EXISTS (SELECT Name FROM tempdb.sys.indexes
			WHERE Name = ''IX_IsCodeNumericOneDP''
			AND OBJECT_ID = OBJECT_ID(''tempdb..#IsCodeNumericOneDP''))
BEGIN
DROP INDEX IX_IsCodeNumericOneDP ON #IsCodeNumericOneDP ;
END
CREATE INDEX IX_IsCodeNumericOneDP ON #IsCodeNumericOneDP (CodeStart);


UPDATE  b
			SET 
			CodeType = CASE WHEN b.CodeType IN (''Procedure'',''NDC'') AND b.IsCodeNumeric = 0 THEN ISNULL(chy.CodeType,@ODSPDEICPRDesc)
							WHEN b.CodeType IN (''Procedure'',''NDC'') AND b.IsCodeNumeric = 1 THEN ISNULL(ndcchy.CodeType,@ODSPDEICPRDesc)
							WHEN b.CodeType = ''Revenue'' THEN ISNULL(b.CodeType,@ODSPDEICPRDesc)
							ELSE ISNULL(b.CodeType,@ODSPDEICPRDesc) END ,			
			
			CodeDescription = CASE WHEN b.CodeType = ''NDC'' AND b.IsCodeNumeric = 0 THEN ISNULL(ndcchy.Description,@ODSPDEICPRDesc)
									WHEN b.CodeType = ''NDC'' AND b.IsCodeNumeric = 1 THEN ISNULL(chy.Description,@ODSPDEICPRDesc)
									WHEN b.CodeType IN (''Procedure'',''Revenue'') THEN ISNULL(b.CodeDescription,@ODSPDEICPRDesc)
								END ,
			Category = CASE WHEN b.CodeType IN (''Procedure'',''NDC'') AND b.IsCodeNumeric = 0 THEN ISNULL(chy.Category,@ODSPDEICPRCategory)
							 WHEN b.CodeType IN (''Procedure'',''NDC'') AND b.IsCodeNumeric = 1 THEN ISNULL(ndcchy.Category,@ODSPDEICPRCategory)
							 WHEN b.CodeType = ''Revenue'' THEN ISNULL(b.Category,@ODSPDEICPRCategory)
								END ,
			SubCategory = CASE WHEN b.CodeType IN (''Procedure'',''NDC'') AND b.IsCodeNumeric = 0 THEN ISNULL(chy.SubCategory,@ODSPDEICPRSubCategory)
								WHEN b.CodeType IN (''Procedure'',''NDC'') AND b.IsCodeNumeric = 1 THEN ISNULL(ndcchy.SubCategory,@ODSPDEICPRSubCategory)
								WHEN b.CodeType = ''Revenue'' THEN ISNULL(b.SubCategory,@ODSPDEICPRSubCategory)
							END		
						
			
FROM  stg.ProviderDataExplorerIndustryBillLine b 
		LEFT JOIN #IsCodeNumericzeroDP chy ON b.Code BETWEEN chy.CodeStart AND chy.CodeEnd
			    AND b.IsCodeNumeric = chy.IsCodeNumeric
			    AND b.CodeType IN (''Procedure'',''NDC'')
			    AND b.IsCodeNumeric = 0			          
	LEFT JOIN #IsCodeNumericOneDP ndcchy ON b.Code = ndcchy.CodeStart
			    AND b.IsCodeNumeric = Ndcchy.IsCodeNumeric
			    AND b.CodeType IN (''Procedure'',''NDC'')
			    AND b.IsCodeNumeric = 1
	
		'

IF(@Debug = 1)
BEGIN
	PRINT @AuditFor;
	PRINT @ProcessName;
	PRINT(@SQLScript);
END

EXEC(@SQLScript);

-- Tracking Process end in ETL Audit
EXEC dbo.ProviderDataExplorerIndustryEtlAuditEnd @AuditFor,@ProcessName,@ReportId;

END
GO





IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerIndustryLoadClaimantHeader') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerIndustryLoadClaimantHeader
GO

CREATE PROCEDURE dbo.ProviderDataExplorerIndustryLoadClaimantHeader(
@SourceDatabaseName VARCHAR(50),
@StartDate AS DATETIME,
@EndDate AS DATETIME,
@Debug BIT,
@ReportId INT
)
AS
BEGIN

DECLARE @ProcessName VARCHAR(50),
		@AuditFor VARCHAR(100)
-- Track the Audit for Customer
SET @AuditFor = 'OdsCustomerId : 0';

-- Get the Process Name
SET @ProcessName = ( SELECT OBJECT_NAME(@@PROCID) );

-- Tracking Process start in ETL Audit
EXEC dbo.ProviderDataExplorerIndustryEtlAuditStart @AuditFor,@ProcessName,@ReportId;

DECLARE @SQLScript VARCHAR(MAX)
		
SET @SQLScript=
	-- Step1: Load the InScope data to stg table (Index on dateloss)
	-- Step2: Insert data joining the Inscope table
'
	IF OBJECT_ID(''stg.ProviderDataExplorerIndustryClaimsInScope'',''U'') IS NOT NULL					
	DROP TABLE stg.ProviderDataExplorerIndustryClaimsInScope;				
	
	CREATE TABLE stg.ProviderDataExplorerIndustryClaimsInScope
	(
	OdscustomerId INT NOT NULL,				
	ClaimIdNo INT NOT NULL,
	DateLoss DATETIME

	CONSTRAINT PK_ProviderDataExplorerIndustryClaimsInScope PRIMARY KEY
			(						
				OdsCustomerId,
				ClaimIdNo
			)
		
	);

	INSERT INTO stg.ProviderDataExplorerIndustryClaimsInScope
	SELECT	c.OdscustomerId,				
			ClaimIdNo,
			DateLoss
	FROM '+ @SourceDatabaseName + '.dbo.Claims c
	INNER JOIN '+@SourceDatabaseName+'.adm.Customer cus ON cus.CustomerId = c.OdsCustomerId
	AND cus.IncludeInIndustry = 1
	WHERE DateLoss >= '''+CONVERT(VARCHAR(10),@StartDate,112)+'''	 
	

	TRUNCATE TABLE stg.ProviderDataExplorerIndustryClaimantHeader;
	
	INSERT INTO stg.ProviderDataExplorerIndustryClaimantHeader(
				OdsCustomerId,
				ClaimId,
				DateLoss,
				CVCode,				
				ClaimantId,
				ClaimantStateOfJurisdiction,
				CoverageType,
				ClaimantHeaderId,	
				ProviderId,			
				CVCodeDesciption,
				CoverageTypeDescription	
				
	)
	SELECT 		
				c.OdsCustomerId,
				c.ClaimIDNo,
				c.DateLoss,
				c.CV_Code,
				cmt.CmtIDNo,
				cmt.CmtStateOfJurisdiction,
				cmt.CoverageType,
				ch.CMT_HDR_IDNo,
				ch.PvdIDNo,				
				cvt.LongName,
				cvtc.LongName
			
	FROM '+@SourceDatabaseName+'.dbo.Claims c 
	INNER JOIN stg.ProviderDataExplorerIndustryClaimsInScope cis ON c.OdsCustomerId = cis.OdsCustomerId
														 AND c.ClaimIdNo = cis.ClaimIdNo
	INNER JOIN '+@SourceDatabaseName+'.dbo.Claimant cmt ON c.ClaimIDNo = cmt.ClaimIDNo 
												AND c.OdsCustomerId = cmt.OdsCustomerId 												
	INNER JOIN '+@SourceDatabaseName+'.dbo.CMT_HDR ch ON ch.CmtIDNo = cmt.CmtIDNo 
												AND cmt.OdsCustomerId = ch.OdsCustomerId 												
	INNER JOIN '+@SourceDatabaseName+'.adm.Customer cus ON cus.CustomerId = ch.OdsCustomerId
														AND cus.IncludeInIndustry = 1
	LEFT JOIN '+@SourceDatabaseName+'.dbo.CoverageType cvt ON c.OdsCustomerId=cvt.OdsCustomerId 
												AND c.CV_Code=cvt.ShortName
	LEFT JOIN '+@SourceDatabaseName+'.dbo.CoverageType cvtc ON c.OdsCustomerId=cvtc.OdsCustomerId 
												AND cmt.CoverageType=cvtc.ShortName																	
		
'

IF (@Debug = 1)
BEGIN
	PRINT @AuditFor;	
	PRINT @ProcessName;
	PRINT(@SQLScript)
END

EXEC(@SQLScript);

-- Tracking Process end in ETL Audit
EXEC dbo.ProviderDataExplorerIndustryEtlAuditEnd @AuditFor,@ProcessName,@ReportId;

END

GO



IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerIndustryLoadCustomerOutput') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerIndustryLoadCustomerOutput
GO

CREATE PROCEDURE dbo.ProviderDataExplorerIndustryLoadCustomerOutput(
@SourceDatabaseName VARCHAR(50),
@OdsCustomerId INT,
@Debug BIT,
@ReportId INT
)
AS
BEGIN

DECLARE @ProcessName VARCHAR(50),		
		@AuditFor VARCHAR(100);


-- Track the Audit for Customer
SET @AuditFor = 'OdsCustomerId : '+CAST(@OdsCustomerId as varchar(3));

-- Get the Process Name
SET @ProcessName = ( SELECT OBJECT_NAME(@@PROCID) );

-- Tracking Process start in ETL Audit
EXEC dbo.ProviderDataExplorerIndustryEtlAuditStart @AuditFor,@ProcessName,@ReportId;

DECLARE @SQLScript VARCHAR(MAX);				

SET @SQLScript = CAST('' as VARCHAR(MAX)) + '

-- Get Aggrigated data for customers.

INSERT INTO dbo.ProviderDataExplorerIndustryCustomerOutput
(
		OdsCustomerId
		,CustomerName
		,ProviderClusterName
		,FormType
		,SubFormType
		,CoverageLine
		,StateofJurisdiction
		,InjuryType
		,CodeType
		,Code
		,Category
		,SubCategory
		,AvgActualTenure
		,AvgExpectedTenure
		,TotalCharged
		,TotalAllowed
		,TotalAdjustment
		,TotalClaims
		,TotalClaimants
		,TotalBills
		,TotalLines
		)

SELECT  ch.OdsCustomerId
		,ch.CustomerName
		,p.ProviderClusterName
		,bl.FormType
		,bl.SubFormType as DFSubFormType
		,ch.DerivedCVDesc as DFCoverageLine
		,ch.ClaimantStateofJurisdiction as DFClaimantStateofJurisdiction
		,ch.InjuryDescription as DFInjuryDescription
		,bl.CodeType
		,bl.Code
		,bl.Category
		,bl.SubCategory
		,AVG(ch.DOSTenureinDays) AS AvgActualTenure
		,AVG(ExpectedTenureinDays) AS AvgExpectedTenure
		,SUM(Charged) AS TotalCharged
		,SUM(Allowed) AS TotalAllowed 
		,SUM(Adjustment) AS TotalAdjustment
		,COUNT(DISTINCT ch.ClaimId) AS TotalClaims
		,COUNT(DISTINCT ch.ClaimantId) AS TotalClaimExposures
		,COUNT(DISTINCT bl.BillId) AS TotalBills
		,COUNT(LineNumber) AS TotalLines
FROM    
    dbo.ProviderDataExplorerClaimantHeader ch 
    INNER JOIN dbo.ProviderDataExplorerProvider p ON p.ProviderId = ch.ProviderId
										AND ch.OdsCustomerId = p.OdsCustomerId
	INNER JOIN dbo.ProviderDataExplorerBillHeader bh ON bh.ClaimantHeaderId = ch.ClaimantHeaderId
										AND bh.OdsCustomerId = ch.OdsCustomerId
	INNER JOIN dbo.ProviderDataExplorerBillLine bl ON bl.BillId = bh.BillId
										AND bl.OdsCustomerId = bh.OdsCustomerId
									
WHERE ExceptionFlag = 0 		
		AND ch.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+'
GROUP BY ch.OdsCustomerId,ch.CustomerName,ProviderClusterName, FormType,SubFormType , ch.DerivedCVDesc, InjuryDescription
			,ClaimantStateofJurisdiction ,CodeType, Code,  Category, SubCategory


'
-- Script generates when debug mode is on 
IF (@Debug = 1)
BEGIN
	PRINT @AuditFor;	
	PRINT @ProcessName;
	PRINT(@SQLScript);

END

EXEC(@SQLScript);

-- Tracking Process end in ETL Audit
EXEC dbo.ProviderDataExplorerIndustryEtlAuditEnd @AuditFor,@ProcessName,@ReportId;

END

GO


IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerIndustryLoadOutput') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerIndustryLoadOutput
GO

CREATE PROCEDURE dbo.ProviderDataExplorerIndustryLoadOutput(
@SourceDatabaseName VARCHAR(50),
@Debug BIT,
@ReportId INT
)
AS
BEGIN

DECLARE @ProcessName VARCHAR(50),		
		@AuditFor VARCHAR(100);

-- Track the Audit for Customer
SET @AuditFor = 'OdsCustomerId : 0';

-- Get the Process Name
SET @ProcessName = ( SELECT OBJECT_NAME(@@PROCID) );

-- Tracking Process start in ETL Audit
EXEC dbo.ProviderDataExplorerIndustryEtlAuditStart @AuditFor,@ProcessName,@ReportId;

DECLARE @SQLScript VARCHAR(MAX);				

SET @SQLScript = CAST('' as VARCHAR(MAX)) + '

-- Get Aggrigated data for all customers.
Truncate table dbo.ProviderDataExplorerIndustryOutput

INSERT INTO dbo.ProviderDataExplorerIndustryOutput
(
		ProviderClusterName
		,FormType
		,SubFormType
		,CoverageLine
		,StateofJurisdiction
		,InjuryType
		,CodeType
		,Code
		,Category
		,SubCategory
		,AvgActualTenure
		,AvgExpectedTenure
		,TotalCharged
		,TotalAllowed
		,TotalAdjustment
		,TotalClaims
		,TotalClaimants
		,TotalBills
		,TotalLines
		)

SELECT  
		ProviderClusterName
		,FormType
		,SubFormType as DFSubFormType
		,ch.DerivedCVDesc as DFCoverageLine
		,ClaimantStateofJurisdiction as DFClaimantStateofJurisdiction
		,InjuryDescription as DFInjuryDescription
		,CodeType
		,Code
		,Category
		,SubCategory
		,AVG(ch.DOSTenureinDays) AS AvgActualTenure
		,AVG(ExpectedTenureinDays) AS AvgExpectedTenure
		,SUM(Charged) AS TotalCharged
		,SUM(Allowed) AS TotalAllowed 
		,SUM(Adjustment) AS TotalAdjustment
		,COUNT(DISTINCT ch.ClaimId) AS TotalClaims
		,COUNT(DISTINCT ch.ClaimantId) AS TotalClaimants
		,COUNT(DISTINCT bl.BillId) AS TotalBills
		,COUNT(LineNumber) AS TotalLines
FROM    
    stg.ProviderDataExplorerIndustryClaimantHeader ch 
    INNER JOIN stg.ProviderDataExplorerIndustryProvider p ON p.ProviderId = ch.ProviderId
										AND ch.OdsCustomerId = p.OdsCustomerId
	INNER JOIN stg.ProviderDataExplorerIndustryBillHeader bh ON bh.ClaimantHeaderId = ch.ClaimantHeaderId
										AND bh.OdsCustomerId = ch.OdsCustomerId
	INNER JOIN stg.ProviderDataExplorerIndustryBillLine bl ON bl.BillId = bh.BillId
										AND bl.OdsCustomerId = bh.OdsCustomerId
   
									
WHERE 
	 ExceptionFlag = 0 		
GROUP BY 
		ProviderClusterName, FormType,SubFormType, ch.DerivedCVDesc, ClaimantStateofJurisdiction, 
		InjuryDescription,CodeType, Code, Category, SubCategory


'
-- Script generates when debug mode is on 
IF (@Debug = 1)
BEGIN
	PRINT @AuditFor;	
	PRINT @ProcessName;
	PRINT(@SQLScript);

END

EXEC(@SQLScript);

-- Tracking Process end in ETL Audit
EXEC dbo.ProviderDataExplorerIndustryEtlAuditEnd @AuditFor,@ProcessName,@ReportId;

END

GO




IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerIndustryLoadProvider') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerIndustryLoadProvider
GO

CREATE PROCEDURE dbo.ProviderDataExplorerIndustryLoadProvider(
@SourceDatabaseName VARCHAR(50),
@StartDate AS DATETIME,
@EndDate AS DATETIME,
@Debug BIT,
@ReportId INT
)
AS
BEGIN

DECLARE 
		@ProcessName VARCHAR(50),
		@AuditFor VARCHAR(100)
		-- Track the Audit for Customer
SET @AuditFor = 'OdsCustomerId : 0';

-- Get the Process Name
SET @ProcessName = ( SELECT OBJECT_NAME(@@PROCID) );

-- Tracking Process start in ETL Audit
EXEC dbo.ProviderDataExplorerIndustryEtlAuditStart @AuditFor,@ProcessName,@ReportId;

DECLARE @SQLScript VARCHAR(MAX);

SET @SQLScript=

	-- Step1: Insert providers data joining with staging ClaimantHeader table 

' 
IF EXISTS (SELECT Name FROM sys.indexes  WHERE Name=''IDX_PDEIC_CHOdsCustomerIdProviderId'' 
    AND object_id = OBJECT_ID(''stg.ProviderDataExplorerIndustryClaimantHeader''))
  BEGIN
    DROP INDEX IDX_PDEIC_CHOdsCustomerIdProviderId ON stg.ProviderDataExplorerIndustryClaimantHeader;
  END
CREATE INDEX IDX_PDEIC_CHOdsCustomerIdProviderId ON stg.ProviderDataExplorerIndustryClaimantHeader (OdsCustomerId,ProviderId);


TRUNCATE TABLE stg.ProviderDataExplorerIndustryProvider;

INSERT INTO stg.ProviderDataExplorerIndustryProvider(
			OdsCustomerId,
			ProviderId,
			ProviderTIN,
			ProviderFirstName,
			ProviderLastName,
			ProviderGroup,
			ProviderState,
			ProviderZip,
			ProviderNPINumber,	
			ProviderTypeID,
			ProviderName,
			ProviderClusterID				
)
SELECT 					
			p.OdsCustomerId,
			p.PvdIDNo,
			p.PvdTIN,
			p.PvdFirstName,
			p.PvdLastName,			
			p.PvdGroup,
			p.PvdState,
			SUBSTRING(p.PvdZip,1,5),			
			p.PvdNPINo,
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

			prs.ProviderClusterKey
				

		FROM   '
		+ CHAR(13)+CHAR(10)+CHAR(9) +@SourceDatabaseName+'.dbo.PROVIDER p 
		INNER JOIN (SELECT DISTINCT OdsCustomerId,ProviderId FROM stg.ProviderDataExplorerIndustryClaimantHeader) ch ON p.OdsCustomerId = ch.OdsCustomerId 
												AND p.PvdIdNo = ch.ProviderId
		LEFT JOIN  '+@SourceDatabaseName+'.dbo.ProviderCluster prs ON p.PvdIDNo = prs.PvdIDNo 
											    AND p.ODSCustomerID = prs.OrgOdsCustomerId												
		  DROP INDEX IDX_PDEIC_CHOdsCustomerIdProviderId ON stg.ProviderDataExplorerIndustryClaimantHeader;'		
		
		
IF (@Debug = 1)
BEGIN
	PRINT @AuditFor;	
	PRINT @ProcessName;	
	PRINT(@SQLScript);

END

EXEC(@SQLScript);

-- Tracking Process end in ETL Audit
EXEC dbo.ProviderDataExplorerIndustryEtlAuditEnd @AuditFor,@ProcessName,@ReportId;

END

GO



IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerIndustryUpdateBillLine') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerIndustryUpdateBillLine
GO

CREATE PROCEDURE dbo.ProviderDataExplorerIndustryUpdateBillLine(
@SourceDatabaseName VARCHAR(50),
@Debug BIT,
@ReportId INT
)
AS
BEGIN

DECLARE 
		@ProcessName VARCHAR(50),
		@AuditFor VARCHAR(100);


-- Track the Audit for Customer
SET @AuditFor = 'OdsCustomerId : 0';


-- Get the Process Name
SET @ProcessName = ( SELECT OBJECT_NAME(@@PROCID) );

-- Tracking Process start in ETL Audit
EXEC dbo.ProviderDataExplorerIndustryEtlAuditStart @AuditFor,@ProcessName,@ReportId;

DECLARE @SQLScript VARCHAR(MAX);

SET @SQLScript = CAST('' AS VARCHAR(MAX))+
 '
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

 IF EXISTS (SELECT Name FROM sys.indexes  WHERE Name = ''IDXPACHUpdateClaimantHeader'' 
    AND object_id = OBJECT_ID(''stg.ProviderDataExplorerIndustryClaimantHeader''))
  BEGIN
    DROP INDEX IDXPACHUpdateClaimantHeader ON stg.ProviderDataExplorerIndustryClaimantHeader;
  END
CREATE INDEX IDXPACHUpdateClaimantHeader ON stg.ProviderDataExplorerIndustryClaimantHeader (OdsCustomerId,ClaimantHeaderId);



IF EXISTS (SELECT Name FROM sys.indexes  WHERE Name = ''IDXPACHUpdateBillHeader'' 
    AND object_id = OBJECT_ID(''stg.ProviderDataExplorerIndustryBillHeader''))
  BEGIN
    DROP INDEX IDXPACHUpdateBillHeader ON stg.ProviderDataExplorerIndustryBillHeader;
  END
CREATE INDEX IDXPACHUpdateBillHeader ON stg.ProviderDataExplorerIndustryBillHeader (OdsCustomerId,ClaimantHeaderId,BillId);


/*	Set ExceptionFlag as 1 with records having condition date_of_service is less than date_loss */
UPDATE bl 
	SET
	bl.ExceptionFlag = 1,
	ExceptionComments=''Date of service is less than date loss''	
FROM stg.ProviderDataExplorerIndustryBillLine bl
	     INNER JOIN stg.ProviderDataExplorerIndustryBillHeader bh ON bl.BillId = bh.BillId
												AND bl.OdsCustomerId = bh.OdsCustomerId 												
		 INNER JOIN stg.ProviderDataExplorerIndustryClaimantHeader ch ON bh.ClaimantHeaderId = ch.ClaimantHeaderId
											    AND bh.OdsCustomerId = ch.OdsCustomerId											   
												  
		 WHERE bl.DateOfService < ch.DateLoss  

/*	set exception_flag as 1 with records having condition Allowed amount is higher than charged amount. */
	
UPDATE stg.ProviderDataExplorerIndustryBillLine 
SET 
	ExceptionFlag=1,
	ExceptionComments=''Allowed amount is higher than charged amount.'' 

WHERE ISNULL(Allowed,0) > ISNULL(Charged,0);


/*	Set exception_flag as 1 where Duplicate records where identified with endnote as 4. */

IF OBJECT_ID(''tempdb..#DuplicateBillLines'') IS NOT NULL					
	DROP TABLE #DuplicateBillLines;

SELECT  ISNULL(Be.OdsCustomerId,bo.OdsCustomerId ) AS OdsCustomerId,
		ISNULL(Be.BillIDNo,bo.BillIDNo) as BillIdNo, 
		Isnull(be.LINE_NO,bo.Line_No) as Line_No
		
INTO #DuplicateBillLines
FROM '+@SourceDatabaseName+'.dbo.Bills_Pharm_Endnotes BE
FULL OUTER JOIN '+@SourceDatabaseName+'.dbo.Bills_Pharm_OverrideEndNotes BO ON Be.OdsCustomerId = BO.OdsCustomerId 
														AND BE.BillIDNo = BO.BillIDNo 
														AND BE.LINE_NO = BO.LINE_NO
WHERE  (BO.OverrideEndNote = 4 OR (be.EndNote = 4 AND  BO.OverrideEndNote IS NULL))
		
UNION

  SELECT ISNULL(Be.OdsCustomerId,bo.OdsCustomerId ) AS OdsCustomerId,
		 ISNULL(Be.BillIDNo,bo.BillIDNo) AS BillIdNo, 
		 Isnull(be.LINE_NO,bo.Line_No) AS Line_No

FROM '+@SourceDatabaseName+'.dbo.Bills_EndNotes BE
FULL OUTER JOIN '+@SourceDatabaseName+'.dbo.Bills_OverrideEndNotes BO ON BE.OdsCustomerId = BO.OdsCustomerId 
																AND BE.BillIDNo = BO.BillIDNo 
																AND BE.LINE_NO = BO.LINE_NO
WHERE (BO.OverrideEndNote = 4 OR (be.EndNote = 4 AND  BO.OverrideEndNotE IS NULL))

UNION

SELECT ISNULL(Be.OdsCustomerId,bo.OdsCustomerId ) AS OdsCustomerId,
		 ISNULL(Be.BillID,bo.BillIDNo) AS BillIdNo, 
		 Isnull(be.LineNumber,bo.Line_No) AS Line_No

FROM stg.ProviderDataExplorerIndustryBillLine BE
Inner JOIN '+@SourceDatabaseName+'.dbo.Bills_OverrideEndNotes BO ON BE.OdsCustomerId = BO.OdsCustomerId 
																AND BE.BillID = BO.BillIDNo 
																AND BE.LineNumber = BO.LINE_NO
WHERE  BO.OverrideEndNote = 4

UNION

  SELECT ISNULL(Be.OdsCustomerId,bo.OdsCustomerId ) AS OdsCustomerId,
		 ISNULL(Be.BillID,bo.BillIDNo) AS BillIdNo, 
		 Isnull(be.LineNumber,bo.Line_No) AS Line_No

FROM stg.ProviderDataExplorerIndustryBillLine BE
Inner JOIN '+@SourceDatabaseName+'.dbo.Bills_Pharm_OverrideEndNotes BO ON BE.OdsCustomerId = BO.OdsCustomerId 
																AND BE.BillID = BO.BillIDNo 
																AND BE.LineNumber = BO.LINE_NO
WHERE  BO.OverrideEndNote = 4


UPDATE b
SET 
	ExceptionFlag = 1,
	ExceptionComments  = ''Duplicate records identified with endnote as 4.''				
FROM stg.ProviderDataExplorerIndustryBillLine B 
INNER JOIN #DuplicateBillLines BE ON BE.BillIDNo = B.BillId
								 AND BE.LINE_NO = B.LineNumber
		                         AND BE.OdsCustomerId = B.OdsCustomerId


		
/* Every claim first Date_of_Service should be last 12 months*/

IF OBJECT_ID(''tempdb..#DTSVC'') IS NOT NULL
         DROP TABLE #DTSVC;
  
BEGIN
	
IF OBJECT_ID(''tempdb..#DTSVC_Bills'') IS NOT NULL					
	DROP TABLE #DTSVC_Bills;			
	
CREATE TABLE #DTSVC_Bills
	(
	OdsCustomerId INT NOT NULL,	
	ClaimIDNo INT NOT NULL,
	BillIdNo INT NOT NULL,
	BillLineNo INT NOT NULL,
	DTSVC DATETIME

	CONSTRAINT PK_ProviderDataExplorerIndustryDTSVC_Bills PRIMARY KEY
			(						
				OdsCustomerId,
				ClaimIDNo,
				BillIdNo,
				BillLineNo
			)
		
	);

	INSERT INTO #DTSVC_Bills
	SELECT  ch.OdsCustomerId,
	        ch.ClaimId,				
			b.BillIDNo,
			b.LINE_NO,
			b.DT_SVC
	FROM stg.ProviderDataExplorerIndustryClaimantHeader ch  
              INNER JOIN stg.ProviderDataExplorerIndustryBillHeader Bh ON ch.OdsCustomerId = bh.OdsCustomerId 	
														 AND ch.ClaimantHeaderId = bh.ClaimantHeaderId
			  INNER JOIN '+@SourceDatabaseName+'.dbo.BILLS b ON bh.OdsCustomerId = b.OdsCustomerId
																		 AND bh.BillID = b.BillIDNo
	

	IF EXISTS (SELECT Name FROM tempdb.sys.indexes  WHERE Name=''IDX_DTSVC_Bills_DT_SVC'' 
		  AND OBJECT_ID = OBJECT_ID(''tempdb..#DTSVC_Bills''))
		BEGIN
		  DROP INDEX IDX_DTSVC_Bills_DT_SVC ON #DTSVC_Bills;
		END
	CREATE INDEX IDX_DTSVC_Bills_DT_SVC ON #DTSVC_Bills(DTSVC);	
	
	SELECT 
		  C.OdsCustomerId,
		  C.ClaimIDNo
		  ,MIN(c.DTSVC ) MinDtsvc
		 INTO  #DTSVC
		From  #DTSVC_Bills c 
			  
	GROUP BY 						
			C.OdsCustomerId,
			C.ClaimIDNo;
END


IF OBJECT_ID(''tempdb..#DateOfService'') IS NOT NULL
           DROP TABLE #DateOfService ;
BEGIN
	SELECT 
		ch.OdsCustomerId,
		ch.ClaimId,
		MIN(CAST(bl.DateofService AS DATE)) MinDateOfService 
	INTO #DateOfService
	FROM
		 stg.ProviderDataExplorerIndustryBillLine bl 
	     INNER JOIN stg.ProviderDataExplorerIndustryBillHeader bh ON bl.BillId = bh.BillId
												AND bl.OdsCustomerId = bh.OdsCustomerId 												
		 INNER JOIN stg.ProviderDataExplorerIndustryClaimantHeader ch ON bh.ClaimantHeaderId = ch.ClaimantHeaderId 
											    AND bh.OdsCustomerId = ch.OdsCustomerId
											    

GROUP BY 
		ch.OdsCustomerId,
		ch.ClaimID;
END

/* take records which do not match from the above two temp tables */
IF OBJECT_ID(''tempdb..#ClaimLevelDataofService'') IS NOT NULL
        DROP TABLE #ClaimLevelDataofService;
BEGIN
SELECT 
		S.OdsCustomerId,
		S.ClaimID,
		D.MinDtsvc,
		S.MinDateOfService 
	INTO #ClaimLevelDataofService  
FROM #DTSVC D INNER JOIN #DateOfService S ON D.OdsCustomerId = S.OdsCustomerId 
										AND D.ClaimIDNo = S.ClaimID
										WHERE D.MinDtsvc <> S.MinDateOfService
					
END


UPDATE bl 
    SET
ExceptionFlag = 1,
ExceptionComments = ''Claim''''s with first date of sevice is < 12 months.''

FROM
	 stg.ProviderDataExplorerIndustryBillLine bl 
	     INNER JOIN stg.ProviderDataExplorerIndustryBillHeader bh ON bl.BillId = bh.BillId
												AND bl.OdsCustomerId = bh.OdsCustomerId 												
		 INNER JOIN stg.ProviderDataExplorerIndustryClaimantHeader ch ON bh.ClaimantHeaderId = ch.ClaimantHeaderId
											    AND bh.OdsCustomerId = ch.OdsCustomerId											    
    JOIN  #ClaimLevelDataofService D ON  D.ClaimID = ch.ClaimID 
												AND D.OdsCustomerId = ch.OdsCustomerId ;



	IF OBJECT_ID(''stg.CustomerBillExclusionTemp'',''U'') IS NOT NULL					
		DROP TABLE stg.CustomerBillExclusionTemp;	

	CREATE TABLE stg.CustomerBillExclusionTemp( 
				OdsCustomerId  INT NOT NULL,
				BillIdNo INT NOT NULL
				);

	INSERT INTO stg.CustomerBillExclusionTemp
	SELECT cus.CustomerId
		   ,ex.BillIdNo 	  
	FROM '+@SourceDatabaseName+'.dbo.CustomerBillExclusion ex 
	INNER JOIN '+@SourceDatabaseName+'.adm.Customer cus ON ex.Customer =cus.CustomerDatabase 
	WHERE ex.ReportID = '+CAST(@ReportId AS VARCHAR(3))+ ' 
 
		   
/*Bundling Unbundling Script*/


UPDATE B 
  SET 
      B.BundlingFlag = -1

FROM stg.ProviderDataExplorerIndustryBillLine B 
WHERE EXISTS(
      SELECT 1  
	  FROM '+@SourceDatabaseName+'.dbo.BILLS_Endnotes BE 
	  WHERE BE.BillIDNo = B.BillId
		AND BE.LINE_NO = B.LineNumber
		AND BE.OdsCustomerId = B.OdsCustomerId		
		AND BE.EndNote IN(10)
		)


UPDATE B
  SET 
      B.BundlingFlag = -2
FROM stg.ProviderDataExplorerIndustryBillLine B 
WHERE EXISTS(
      SELECT 1  
	  FROM '+@SourceDatabaseName+'.dbo.BILLS_Endnotes BE 
	  WHERE BE.BillIDNo = B.BillId
		AND BE.LINE_NO = B.LineNumber
		AND BE.OdsCustomerId = B.OdsCustomerId		
		AND BE.EndNote IN(35)
		)

IF OBJECT_ID(''tempdb..#BillLineArchive'') IS NOT NULL
         DROP TABLE #BillLineArchive;
BEGIN
        
SELECT *
INTO #BillLineArchive
FROM stg.ProviderDataExplorerIndustryBillLine B 
WHERE BundlingFlag IN(-1, -2);

DELETE FROM stg.ProviderDataExplorerIndustryBillLine
WHERE BundlingFlag IN(-1, -2);

END


INSERT INTO stg.ProviderDataExplorerIndustryBillLine
SELECT 
	
		a.OdsCustomerId,
		a.BillId,
		a.LineNumber,
		a.OverRide,
		a.DateofService,
		a.ProcedureCode,
		b.c,
		a.Allowed,
		a.RefLineNo,
		a.POSRevCode,
		ISNULL(b.c,0) - ISNULL(a.ALLOWED,0)  Adjustment, 
		a.FormType,
		a.CodeType,
		a.Code,
		a.CodeDescription,
		a.Category,
		a.SubCategory,
		a.BillLineType,
		1 AS BundlingFlag,
		a.ExceptionFlag,
		a.ExceptionComments,
		a.SubFormType,
		a.IsCodeNumeric,
		a.RunDate
		
       FROM #BillLineArchive a 
            INNER JOIN
       (
           SELECT bl.BillId, 
                  bl.LineNumber, 
                  bl.OdsCustomerId,                  
                  SUM(isnull(ul.charged,0)) c
           FROM #BillLineArchive bl 
                LEFT JOIN #BillLineArchive ul ON ul.BillId = bl.BillId
                                                                     AND ul.RefLineNo = bl.LineNumber
                                                                     AND ul.BundlingFlag = -1
																	 AND ul.OdsCustomerId = bl.OdsCustomerId                                                                   
                                                                     
           WHERE bl.BundlingFlag = -2
           GROUP BY bl.BillId, 
                    bl.LineNumber, 
                    bl.OdsCustomerId                   
       ) b ON a.BillId = b.BillId
              AND a.LineNumber = b.LineNumber
              AND a.OdsCustomerId = b.OdsCustomerId;


/*	Set exception_flag as 1 where Benefits exhausted records were identified with endnote as 202. 
	Using BILLS_Endnotes, Bills_OverrideEndNotes,
	Bills_Pharm_Endnotes and Bills_Pharm_OverrideEndNotes tables */
		
UPDATE b
SET 
	ExceptionFlag = 1,
	ExceptionComments  = ''Benefits exhausted records identified with endnote as 202.''				
FROM stg.ProviderDataExplorerIndustryBillLine B 
WHERE EXISTS(
      SELECT 1  
	  FROM '+@SourceDatabaseName+'.dbo.BILLS_Endnotes BE 
	  WHERE BE.BillIDNo = B.BillId
		AND BE.LINE_NO = B.LineNumber
		AND BE.OdsCustomerId = B.OdsCustomerId
		AND BE.EndNote = 202
		)

	
UPDATE b
SET 
	ExceptionFlag = 1,
	ExceptionComments  = ''Benefits exhausted records identified with endnote as 202.''			
FROM stg.ProviderDataExplorerIndustryBillLine B 
WHERE EXISTS(
      SELECT 1  
	  FROM '+@SourceDatabaseName+'.dbo.Bills_OverrideEndNotes BE 
	  WHERE BE.BillIDNo = B.BillId
		AND BE.LINE_NO = B.LineNumber
		AND BE.OdsCustomerId = B.OdsCustomerId
		AND BE.OverrideEndNote = 202
		)

UPDATE b
SET 
	ExceptionFlag = 1,
	ExceptionComments  = ''Benefits exhausted records identified with endnote as 202.''			
FROM stg.ProviderDataExplorerIndustryBillLine B 
WHERE EXISTS(
      SELECT 1  
	  FROM '+@SourceDatabaseName+'.dbo.Bills_Pharm_Endnotes BE 
	  WHERE BE.BillIDNo = B.BillId
		AND BE.LINE_NO = B.LineNumber
		AND BE.OdsCustomerId = B.OdsCustomerId
		AND BE.EndNote = 202
		)

UPDATE b
SET 
	ExceptionFlag = 1,
	ExceptionComments  = ''Benefits exhausted records identified with endnote as 202.''			
FROM stg.ProviderDataExplorerIndustryBillLine B 
WHERE EXISTS(
      SELECT 1  
	  FROM '+@SourceDatabaseName+'.dbo.Bills_Pharm_OverrideEndNotes BE 
	  WHERE BE.BillIDNo = B.BillId
		AND BE.LINE_NO = B.LineNumber
		AND BE.OdsCustomerId = B.OdsCustomerId
		AND BE.OverrideEndNote = 202
		
		)



/* Exclude bill lines with future date of service. Using Adm.ReportParameters.EndDate.*/
DECLARE @ODSPDEICEndDate DATETIME
SELECT @ODSPDEICEndDate = ParameterValue FROM  adm.ReportParameters WHERE ReportId = '+CAST(@ReportId AS VARCHAR(3))+' 
			AND ParameterName = ''ODSPDEICEndDate''

UPDATE b
	SET ExceptionFlag = 1,
		ExceptionComments =''Exclude Bill Lines with future date of service.''
FROM stg.ProviderDataExplorerIndustryBillLine b 
	WHERE OdsCustomerId =0 
		AND b.DateofService > @ODSPDEICEndDate

		 

	DECLARE @ODSPDEICPRCategory VARCHAR(50)
	SELECT @ODSPDEICPRCategory = ParameterValue FROM adm.ReportParameters WHERE ReportId = '+CAST(@ReportId AS VARCHAR(3))+' AND ParameterName=''ODSPDEICPRCategory'';

	/* Make ExceptionFlag is 1 where Invalid or Alternative Procedure Codes - Exclude */
	 UPDATE bl 
		SET bl.ExceptionFlag = 1,
			bl.ExceptionComments = ''Invalid or Alternative Procedure Codes - Exclude''
		FROM stg.ProviderDataExplorerIndustryBillLine bl
		INNER JOIN rpt.ProviderDataExplorerPRCodeDataQuality cdq ON cdq.Code = bl.Code 	
	WHERE  bl.Category = @ODSPDEICPRCategory   AND cdq.ExceptionFlag = 1
	; 

	/*  update category and subcategory in bill lines */
	UPDATE bl
		SET 
		bl.Category = cdq.Category,
		bl.SubCategory = cdq.SubCategory
	FROM stg.ProviderDataExplorerIndustryBillLine bl
	INNER JOIN rpt.ProviderDataExplorerPRCodeDataQuality cdq ON cdq.Code = bl.Code 
	WHERE  bl.Category = @ODSPDEICPRCategory AND cdq.Category IN (''Historical'',''Mitchell'')
		;


	/*Set Old procedrue code mapped to new procedure codes.*/
	UPDATE bl
	SET
		bl.CodeType = cm.CodeType,
		bl.Category = cm.Category,
		bl.SubCategory = cm.SubCategory
	 FROM stg.ProviderDataExplorerIndustryBillLine bl 
	INNER JOIN rpt.ProviderDataExplorerPRCodeDataQuality cdq ON cdq.Code = bl.Code 
													AND ISNULL(cdq.MappedCode,'''') <> '''' 
													AND ISNULL(cdq.MappedCode,'''') <> ''RC''
	INNER JOIN rpt.ProviderDataExplorerCodeHierarchy cm ON cdq.MappedCode BETWEEN cm.CodeStart AND cm.CodeEnd 
															AND cm.CodeType IN (''CPT'',''HCPCS'',''CDT'')
 
	WHERE  bl.Category = @ODSPDEICPRCategory
		;

  
	 /* Exclude Bills based on the CustomerBillExclusion list.*/

	 UPDATE bl
			SET ExceptionFlag = 1,
				ExceptionComments = ''Bill excluded based on the CustomerBillExclusion list''
	FROM stg.ProviderDataExplorerIndustryBillLine bl 
	JOIN stg.CustomerBillExclusionTemp t ON bl.OdsCustomerId = t.OdsCustomerId 
											   AND bl.BillId = t.BillIdNo ;
 
	  IF OBJECT_ID(''stg.CustomerBillExclusionTemp'',''U'') IS NOT NULL					
		DROP TABLE stg.CustomerBillExclusionTemp;			 
	 
	 '	 	 	  		  
			  			   			  
IF (@Debug = 1)
BEGIN
	PRINT @AuditFor;
	PRINT @ProcessName;
	PRINT(@SQLScript);
END	

EXEC(@SQLScript);

-- Tracking Process end in ETL Audit
EXEC dbo.ProviderDataExplorerIndustryEtlAuditEnd @AuditFor,@ProcessName,@ReportId;

END

GO





IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerIndustryUpdateClaimantHeader') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerIndustryUpdateClaimantHeader
GO

CREATE PROCEDURE dbo.ProviderDataExplorerIndustryUpdateClaimantHeader(
@SourceDatabaseName VARCHAR(50),
@Debug BIT,
@ReportId INT
)
AS
BEGIN

DECLARE 
		@ProcessName VARCHAR(50),
		@AuditFor VARCHAR(100);

-- Track the Audit for Customer
SET @AuditFor = 'OdsCustomerId : 0';


-- Get the Process Name
SET @ProcessName = ( SELECT OBJECT_NAME(@@PROCID) );

-- Tracking Process start in ETL Audit
EXEC dbo.ProviderDataExplorerIndustryEtlAuditStart @AuditFor,@ProcessName,@ReportId;

DECLARE @SQLScript VARCHAR(MAX);

SET @SQLScript = CAST('' as VARCHAR(MAX)) +
' 
IF OBJECT_ID(''tempdb..#ClaimantDiagnosis'') IS NOT NULL 
		DROP TABLE #ClaimantDiagnosis;
BEGIN
SELECT ch.ODSCustomerID, 	 
	   ch.ClaimantHeaderId AS ClaimantHeaderID, 
	   bh.billId AS BillID,	    
	   dx.IcdVersion AS ICDVersion, 	   
	   icd.Duration AS RecoveryDuration, 
	   icd.Description AS ICDDescription,	   
	   icd.DiagnosisSeverityId AS DiagnosisSeverityID, 
	   icd.InjuryNatureId AS InjuryNatureID, 
	   it.InjuryNaturePriority AS InjuryNaturePriority, 
	   it.Description AS InjuryDescription 
INTO #ClaimantDiagnosis

FROM stg.ProviderDataExplorerIndustryClaimantHeader ch  
INNER JOIN stg.ProviderDataExplorerIndustryBillHeader bh ON ch.OdsCustomerId = bh.OdsCustomerId
													AND ch.ClaimantHeaderId = bh.ClaimantHeaderId
INNER JOIN '+@SourceDatabaseName+'.dbo.cmt_dx dx ON bh.OdsCustomerId = dx.odscustomerid
													AND bh.billId = dx.billIdNo
INNER JOIN '+@SourceDatabaseName+'.dbo.icddiagnosiscodedictionary icd ON dx.dx = icd.diagnosiscode
													AND dx.icdversion = icd.icdversion
													AND dx.OdsCustomerId = icd.OdsCustomerId												
INNER JOIN '+@SourceDatabaseName+'.dbo.injurynature it ON icd.OdsCustomerId = it.OdsCustomerId													
													AND icd.injurynatureid = it.injurynatureid

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
							SELECT ch.ClaimantId,
									MAX(cd.RecoveryDuration) MaxRecoveryDuration
							FROM stg.ProviderDataExplorerIndustryClaimantHeader ch 
							INNER JOIN #ClaimantDiagnosis cd ON cd.ClaimantHeaderID = ch.ClaimantHeaderId															
																AND cd.OdsCustomerId = ch.OdsCustomerId															
							GROUP BY ch.ClaimantId
						    ),

MinInjuryPriority AS (
							SELECT ch.ClaimantId,
								   mrd.MaxRecoveryDuration,
								   MIN(cd.InjuryNaturePriority) MinInjuryNaturePriority
							FROM stg.ProviderDataExplorerIndustryClaimantHeader ch 
							INNER JOIN #ClaimantDiagnosis cd ON cd.ClaimantHeaderID = ch.ClaimantHeaderId
																AND cd.OdsCustomerId = ch.OdsCustomerId															
							INNER JOIN MaxRecoveryDuration mrd ON ch.ClaimantId = mrd.ClaimantId
																AND cd.RecoveryDuration = mrd.MaxRecoveryDuration
                            GROUP BY ch.ClaimantId,
								     mrd.MaxRecoveryDuration
						 ),

InjuryDetailsForClaimant AS (
							SELECT DISTINCT ch.ClaimantId,
								   cd.InjuryDescription,
								   cd.InjuryNatureID,
								   cd.InjuryNaturePriority,
								   cd.RecoveryDuration * 7 AS MaxRecoveryDurationDays

							FROM #ClaimantDiagnosis cd 
							INNER JOIN stg.ProviderDataExplorerIndustryClaimantHeader ch ON cd.ClaimantHeaderID = ch.ClaimantHeaderId
															AND cd.OdsCustomerId = ch.OdsCustomerId																					
							INNER JOIN MinInjuryPriority minip ON ch.ClaimantId = minip.ClaimantId
															AND cd.InjuryNaturePriority = minip.MinInjuryNaturePriority
															AND cd.RecoveryDuration = minip.MaxRecoveryDuration 
								)
-- update calculated fields in Claimant Header 
UPDATE  ch 
SET ch.ExpectedTenureInDays = ic.MaxRecoveryDurationDays,
	ch.InjuryDescription = ic.InjuryDescription
FROM stg.ProviderDataExplorerIndustryClaimantHeader ch 
INNER JOIN InjuryDetailsForClaimant ic ON ic.ClaimantId = ch.ClaimantId  ;


IF OBJECT_ID(''tempdb..#BillInjuryDescription'') IS NOT NULL 
		DROP TABLE #BillInjuryDescription;


/*Update max min Dos tenture days*/

UPDATE ch
  SET 
      MinimumDateofService = dr.MinimumDateofService, 
      MaximumDateofService = dr.MaximumDateofService, 
      DOSTenureInDays = dr.DOSTenureInDays
FROM stg.ProviderDataExplorerIndustryClaimantHeader ch
     JOIN
(
    SELECT ch.OdsCustomerId, 
           ch.ClaimantHeaderId, 
           MIN(bl.DateofService) MinimumDateofService, 
           MAX(bl.DateofService) MaximumDateofService, 
           DATEDIFF(d, MIN(bl.DateofService), MAX(bl.DateofService)) DOSTenureInDays

 FROM stg.ProviderDataExplorerIndustryClaimantHeader ch  
INNER JOIN stg.ProviderDataExplorerIndustryBillHeader bh ON ch.OdsCustomerId = bh.OdsCustomerId
													AND ch.ClaimantHeaderId = bh.ClaimantHeaderId
INNER JOIN stg.ProviderDataExplorerIndustryBillLine bl ON bl.OdsCustomerId = bh.OdsCustomerId
													AND bl.BillId = bh.BillId 
													AND bl.ExceptionFlag = 0 


    GROUP BY ch.OdsCustomerId, 
             ch.ClaimantHeaderId
) dr ON ch.OdsCustomerId = dr.OdsCustomerId       
        AND ch.ClaimantHeaderId = dr.ClaimantHeaderId;


/*Update the Derived_CV_Type from Bill Hdr level into ProviderDataExplorerIndustryClaimantHeader level.*/

UPDATE ch
	  SET 
      ch.DerivedCVType = COALESCE(bh.CVType, ch.CoverageType, ch.CVCode)
FROM stg.ProviderDataExplorerIndustryClaimantHeader ch 
     LEFT JOIN stg.ProviderDataExplorerIndustryBillHeader bh  ON bh.ClaimantHeaderId = ch.ClaimantHeaderId
                                   AND bh.OdsCustomerId = ch.OdsCustomerId	 


UPDATE ch
	  SET 
      ch.DerivedCVDesc = COALESCE(bh.CVTypeDescription, ch.CoverageTypeDescription, ch.CVCodeDesciption)
FROM stg.ProviderDataExplorerIndustryClaimantHeader ch 
     LEFT JOIN stg.ProviderDataExplorerIndustryBillHeader bh ON bh.ClaimantHeaderId = ch.ClaimantHeaderId
                                   AND bh.OdsCustomerId = ch.OdsCustomerId	 '



IF (@Debug = 1)
BEGIN
	PRINT @AuditFor;
	PRINT @ProcessName;
	PRINT(@SQLScript);
END

EXEC(@SQLScript);

-- Tracking Process end in ETL Audit
EXEC dbo.ProviderDataExplorerIndustryEtlAuditEnd @AuditFor,@ProcessName,@ReportId;

END


GO




IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerIndustryUpdateProviderClusterName') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerIndustryUpdateProviderClusterName
GO

CREATE PROCEDURE dbo.ProviderDataExplorerIndustryUpdateProviderClusterName(
@SourceDatabaseName VARCHAR(50),
@Debug BIT,
@ReportId INT
)
AS
BEGIN

DECLARE 
		@ProcessName VARCHAR(50),		
		@AuditFor VARCHAR(100);

-- Track the Audit for Customer
SET @AuditFor = 'OdsCustomerId : 0';

-- Get the Process Name
SET @ProcessName = ( SELECT OBJECT_NAME(@@PROCID) );

-- Tracking Process start in ETL Audit
EXEC dbo.ProviderDataExplorerIndustryEtlAuditStart @AuditFor,@ProcessName,@ReportId;

DECLARE @SQLScript VARCHAR(MAX);				

SET @SQLScript = CAST('' as VARCHAR(MAX)) + '

------------------STEP:1

IF OBJECT_ID(''tempdb..#ProviderClusterName'') IS NOT NULL 
		DROP TABLE #ProviderClusterName;

-- Mitigate Blank Cluster Names based on all customers Which occure the maximum number.

SELECT 
CASE WHEN LEN(LTRIM(RTRIM(ISNULL(a.ProviderClusterKey,'''')))) > 0 THEN

     CASE WHEN a.ProviderType = ''G'' THEN
                CASE WHEN LEN(LTRIM(RTRIM(b.PvdGroup))) > 0 THEN LTRIM(RTRIM(UPPER(b.PvdGroup))) 
				     ELSE LTRIM(RTRIM(UPPER(b.PvdFirstName))) + '' '' + LTRIM(RTRIM(UPPER(b.PvdLastName)))
                END 
          ELSE
                CASE WHEN LEN(LTRIM(RTRIM(b.PvdFirstName))) > 0 THEN  LTRIM(RTRIM(UPPER(b.PvdFirstName))) + '' '' + LTRIM(RTRIM(UPPER(b.PvdLastName))) 
					 ELSE LTRIM(RTRIM(UPPER(b.PvdGroup)))
                END       

          END

 ELSE
              ''Unclustered''

END AS ProviderClusterName
, a.ProviderClusterKey
, COUNT(1) AS RecCnt

INTO #ProviderClusterName
FROM '+@SourceDatabaseName+'.dbo.ProviderCluster AS a
INNER JOIN '+@SourceDatabaseName+'.dbo.PROVIDER AS b ON a.OrgOdsCustomerId = b.OdsCustomerId													
												  AND a.PvdIDNo = b.PvdIDNo
GROUP BY
CASE WHEN LEN(LTRIM(RTRIM(ISNULL(a.ProviderClusterKey,'''')))) > 0 THEN

     CASE WHEN a.ProviderType = ''G'' THEN
                CASE WHEN LEN(LTRIM(RTRIM(b.PvdGroup))) > 0 THEN LTRIM(RTRIM(UPPER(b.PvdGroup))) 
				     ELSE LTRIM(RTRIM(UPPER(b.PvdFirstName))) + '' '' + LTRIM(RTRIM(UPPER(b.PvdLastName)))
                END 
          ELSE
                CASE WHEN LEN(LTRIM(RTRIM(b.PvdFirstName))) > 0 THEN  LTRIM(RTRIM(UPPER(b.PvdFirstName))) + '' '' + LTRIM(RTRIM(UPPER(b.PvdLastName))) 
					 ELSE LTRIM(RTRIM(UPPER(b.PvdGroup)))
                END       

          END

 ELSE
               ''Unclustered''
END 
		, a.ProviderClusterKey
 ;
 

IF OBJECT_ID(''tempdb..#CalculateProviderCluster'') IS NOT NULL 
		DROP TABLE #CalculateProviderCluster
 
;WITH MaxProviderCluster AS (
SELECT ProviderClusterName,
		ProviderClusterKey,
		RecCnt,
		ROW_NUMBER() OVER(PARTITION BY ProviderClusterKey ORDER BY  RecCnt DESC,ProviderClusterName) AS RowNumber  
	FROM  #ProviderClusterName 
 
 )
 SELECT 
		p.ProviderClusterName,
		m.ProviderClusterKey
 INTO #CalculateProviderCluster 
 FROM MaxProviderCluster m  
 INNER JOIN #ProviderClusterName p ON m.ProviderClusterKey = p.ProviderClusterKey 
								  AND p.ProviderClusterName = m.ProviderClusterName
								  AND p.RecCnt = m.RecCnt 
 WHERE m.RowNumber = 1
 
 
 ------------------------------STEP :2 /* Load provider with adderss , tin and npi details based on ClusterID level. */
 
IF OBJECT_ID(''tempdb..#ProviderName'') IS NOT NULL 
		DROP TABLE #ProviderName;

SELECT 
CASE WHEN LEN(LTRIM(RTRIM(ISNULL(a.ProviderClusterKey,'''')))) > 0 THEN

    CASE WHEN a.ProviderType = ''G'' THEN
                CASE WHEN LEN(LTRIM(RTRIM(b.PvdGroup))) > 0 THEN LTRIM(RTRIM(UPPER(b.PvdGroup))) 
				     ELSE LTRIM(RTRIM(UPPER(b.PvdFirstName))) + '' '' + LTRIM(RTRIM(UPPER(b.PvdLastName)))
                END 
          ELSE
                CASE WHEN LEN(LTRIM(RTRIM(b.PvdFirstName))) > 0 THEN  LTRIM(RTRIM(UPPER(b.PvdFirstName))) + '' '' + LTRIM(RTRIM(UPPER(b.PvdLastName))) 
					 ELSE LTRIM(RTRIM(UPPER(b.PvdGroup)))
                END 

          END

 ELSE
              Null

END AS ProviderName
,LTRIM(RTRIM(UPPER(ISNULL(b.PvdState,''''))))  State
,LTRIM(RTRIM(UPPER(ISNULL(b.PvdAddr1,''''))))  Address
,LTRIM(RTRIM(LEFT(ISNULL(b.PvdZip,''''),5))) Zip
,ISNULL(LTRIM(RTRIM(b.PvdTIN)),'''') Tin
,ISNULL(LTRIM(RTRIM(b.PvdNPINo)),'''') NPI
, a.ProviderClusterKey

INTO #ProviderName
FROM '+@SourceDatabaseName+'.dbo.ProviderCluster AS a
INNER JOIN '+@SourceDatabaseName+'.dbo.PROVIDER AS b ON a.OrgOdsCustomerId = b.OdsCustomerId
										 	AND a.PvdIDNo = b.PvdIDNo ;

 
 ---------STEP 4 Get the most frequently occured address , tin and npi

  IF OBJECT_ID(''tempdb..#MaxRankDetails'') IS NOT NULL 
		DROP TABLE #MaxRankDetails;
 
;WITH MaxClusterName AS (
				SELECT  				
				Providerclusterkey 
				,State 
				,Zip
				,Address
				,Tin
				,NPI
				,DENSE_RANK() OVER(PARTITION BY Providerclusterkey ORDER BY Providerclusterkey,State,Zip,Address) Rnk    
			FROM #ProviderName 
 
 ),
RnkRownumber AS(
			SELECT 				
				m.Providerclusterkey 
				,m.State 
				,m.Zip
				,m.Address
				,m.Tin
				,m.NPI
				,m.Rnk				
				,ROW_NUMBER() OVER(PARTITION BY Rnk,Providerclusterkey ORDER BY Providerclusterkey) RowNumber
				,ROW_NUMBER() OVER(PARTITION BY Tin,Providerclusterkey ORDER BY Providerclusterkey,Tin ) TinRnk 
				,CASE WHEN LEN(LTRIM(RTRIM(ISNULL(NPI,'''') ))) > 0 THEN  ROW_NUMBER() OVER(PARTITION BY Npi,Providerclusterkey ORDER BY Providerclusterkey,NPI ) ELSE '''' END  NpiRnk 
			FROM MaxClusterName m  
              ) SELECT * INTO #MaxRankDetails FROM RnkRownumber ; 
  

------Find most frequently occurred adress(state , zip , address) within the clusterid


 IF OBJECT_ID(''tempdb..#ProviderClusterAddress'') IS NOT NULL 
		DROP TABLE #ProviderClusterAddress;
		
;WITH MaxRowNumber AS(
			 SELECT 
					  Providerclusterkey
					  ,MAX(RowNumber) MaxCnt									  
				FROM #MaxRankDetails
				GROUP BY Providerclusterkey
				)
			 SELECT
					A.Providerclusterkey ,
					MAX( b.State) State ,
					MAX( b.Zip) Zip, 
					MAX( b.Address) Address 
			 INTO #ProviderClusterAddress
			 FROM #MaxRankDetails b  
			 INNER JOIN  MaxRowNumber A ON A.ProviderClusterKey = b.ProviderClusterKey 					 
									               AND A.MaxCnt = b.RowNumber
			GROUP BY 
					  A.Providerclusterkey 

					  
------Find most frequently occurred Tin within the clusterid

 IF OBJECT_ID(''tempdb..#ProviderClusterTin'') IS NOT NULL 
		DROP TABLE #ProviderClusterTin;
		
;WITH MaxTin AS(
				SELECT
					  Providerclusterkey
					  ,MAX(TinRnk) MaxTin									  
				FROM #MaxRankDetails
				GROUP BY Providerclusterkey
				)
		 SELECT
				A.Providerclusterkey ,
				MAX( b.Tin) Tin 
		 INTO #ProviderClusterTin
		 FROM #MaxRankDetails b  
		 INNER JOIN  MaxTin A ON A.ProviderClusterKey = b.ProviderClusterKey 						
								         AND A.MaxTin = b.TinRnk
		GROUP BY  A.Providerclusterkey 


------Find most frequently occurred NPI within the clusterid

 IF OBJECT_ID(''tempdb..#ProviderClusterNPI'') IS NOT NULL 
		DROP TABLE #ProviderClusterNPI;
		
 ;WITH MaxNPI AS(
				SELECT Providerclusterkey
					  ,MAX(NpiRnk) MaxNpi									  
				FROM #MaxRankDetails
				GROUP BY Providerclusterkey
				)
				SELECT				
					A.Providerclusterkey ,
					MAX( b.Npi) NPI 
			    INTO #ProviderClusterNPI
 FROM #MaxRankDetails b  
 INNER JOIN  MaxNPI A ON A.ProviderClusterKey = b.ProviderClusterKey 						  
						         AND A.MaxNpi = b.NpiRnk
  GROUP BY  A.Providerclusterkey 

-----Update ProviderClusterName with New providerClusterName.
UPDATE P 
	SET 
		p.ProviderClusterName = Pc.ProviderClusterName +'' | ''+ State +'' | ''+Zip+'' | ''+Address+'' | ''+Tin+'' | ''+NPI 
 FROM stg.ProviderDataExplorerIndustryProvider p 
 INNER JOIN #CalculateProviderCluster pc ON P.ProviderClusterId = pc.ProviderClusterKey 
 INNER JOIN #ProviderClusterAddress A ON Pc.ProviderClusterKey = A.ProviderClusterKey
 INNER JOIN #ProviderClusterTin B ON A.ProviderClusterKey = B.ProviderClusterKey
 INNER JOIN #ProviderClusterNPI C ON B.ProviderClusterKey = C.ProviderClusterKey ;



  UPDATE 
        stg.ProviderDataExplorerIndustryProvider 
        SET 
		ProviderClusterName = ''Unclustered''		
	WHERE LEN(LTRIM(RTRIM(ISNULL(ProviderClusterId,'''')))) = 0 ;

	'
-- Script generates when debug mode is on 
IF (@Debug = 1)
BEGIN
	PRINT @AuditFor;	
	PRINT @ProcessName;
	PRINT(@SQLScript);

END

EXEC(@SQLScript);

-- Tracking Process end in ETL Audit
EXEC dbo.ProviderDataExplorerIndustryEtlAuditEnd @AuditFor,@ProcessName,@ReportId;

END


GO




IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderAnalyticsInitialLoadPrep') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderAnalyticsInitialLoadPrep
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerInitialLoadPrep') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerInitialLoadPrep
GO

CREATE PROCEDURE dbo.ProviderDataExplorerInitialLoadPrep (@IsIncrementalLoad INT,@ReportId INT)  
AS  
BEGIN  
-- If full load then Initialize the Start Date for DateLoss
IF (@IsIncrementalLoad = 0)  
BEGIN  

  /*Update Start date of the Report in adm.Reportparameter table. */
 UPDATE  
   epsd  
 SET  
   ParameterValue = CONVERT(VARCHAR(25),DATEADD(MONTH,(-1*epgb.ParameterValue),DATEADD(month, DATEDIFF(month, -1 , getdate()) - 1, 0)),110)  
 FROM  
  adm.ReportParameters epsd  
  JOIN adm.ReportParameters epgb ON epsd.ParameterName = 'ODSPAStartDate' AND epsd.ReportId = @ReportId
              AND epgb.ParameterName = 'ODSPAGobackby' AND epgb.ReportId = @ReportId;

/*Update Enddate of the Report in adm.Reportparameter table. */
UPDATE  adm.reportparameters
		SET ParameterValue = DATEADD(MONTH,DATEDIFF(MONTH,-1,GETDATE())-1,-1)  
	WHERE ParameterName = 'ODSPAEndDate' AND ReportId = @ReportId

	  
DECLARE @TruncateFlag INT;
SELECT @TruncateFlag = ParameterValue FROM  adm.ReportParameters WHERE ReportId = @ReportId and ParameterName ='InitialLoadTruncateFlag'

DECLARE  @ReportName VARCHAR(255)
		,@SQLScript NVARCHAR(MAX)
		,@TrackingTable VARCHAR(255)
		,@IsResumed INT	
		
-- Get report Name
SET @SQLScript = 'SELECT @ReportName = RTRIM(LTRIM(REPLACE(ReportJobName,''RPT:'',''''))) FROM adm.ReportJob WHERE ReportID = '+CAST(@ReportId AS VARCHAR(3));
EXEC sp_executesql @SQLScript,N'@ReportName VARCHAR(255) OUT',@ReportName OUT;

-- Get Tracking table Name
SELECT 
	@TrackingTable = TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE='BASE TABLE'
	AND TABLE_NAME LIKE REPLACE(@ReportName,' ','_')+'_Tracking%';

-----Get the status of the track table 0-New Load 1-Incomplete Load
SET @SQLScript = 'SELECT @IsResumed = MAX(IsCustomerDone) FROM stg.'+@TrackingTable+' WHERE IsCustomerDone = 1'
EXEC sp_executesql @SQLScript,N'@IsResumed INT OUT',@IsResumed OUT


/* Get customerId for partially loaded customer in case of job restart.*/
DECLARE @Script NVARCHAR(MAX)
DECLARE @CustomerId INT
SET @Script = 'SELECT @CustomerId = OdsCustomerId  FROM stg.'+@TrackingTable+' WHERE IsCustomerDone = 0'
EXEC sp_executesql @Script,N'@CustomerId INT OUT',@CustomerId OUT

/* Delete records of partially loaded customer in case of job restart.*/
IF( @CustomerId <> 0)
BEGIN

DELETE FROM dbo.ProviderDataExplorerClaimantHeader
	   WHERE OdsCustomerId = @CustomerId;
DELETE FROM dbo.ProviderDataExplorerProvider
	   WHERE OdsCustomerId = @CustomerId;
DELETE FROM dbo.ProviderDataExplorerBillHeader
	   WHERE OdsCustomerId = @CustomerId;
DELETE FROM dbo.ProviderDataExplorerBillLine
	   WHERE OdsCustomerId = @CustomerId;

END

-- If full load then Truncate the tables
	IF (@TruncateFlag = 1 AND ISNULL(@IsResumed,0) = 0)  
	BEGIN  

		 TRUNCATE TABLE dbo.ProviderDataExplorerClaimantHeader;  
		 TRUNCATE TABLE dbo.ProviderDataExplorerProvider;  
		 TRUNCATE TABLE dbo.ProviderDataExplorerBillHeader;  
		 TRUNCATE TABLE dbo.ProviderDataExplorerBillLine;  
  
	END

  
END  
  
END  
    
    
  
GO



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






IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderAnalyticsLoadBillLine') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderAnalyticsLoadBillLine

GO 

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerLoadBillLine') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerLoadBillLine

GO 

CREATE PROCEDURE dbo.ProviderDataExplorerLoadBillLine(
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
		@WhereClauseforBills VARCHAR(MAX),
		@WhereClauseforBillsPharm VARCHAR(MAX),
		@RunFromOdsPostingGroupAuditId INT;

-- Get OdsPostingGroupAuditId from ETLAudit table for Incremental Load
SET @RunFromOdsPostingGroupAuditId = dbo.GetMaxRunFromOdsPostingGroupAuditId(@ProcessName,@AuditFor,@ReportId)


-- Build Where clause for Bills
SET @WhereClauseforBills =
	  CHAR(13)+CHAR(10)+'WHERE '
	+ CHAR(13)+CHAR(10)+CHAR(9) + ' b.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))
	+ CHAR(13)+CHAR(10)+CHAR(9) + ' AND b.PRC_CD <> ''COORD'''
	+ CHAR(13)+CHAR(10)+CHAR(9) + CASE WHEN @IsIncrementalLoad = 1 THEN ' AND b.OdsPostingGroupAuditID > '+CAST(@RunFromOdsPostingGroupAuditId AS VARCHAR(50)) ELSE '' END	
	+ CHAR(13)+CHAR(10)+CHAR(9)
-- Build Where clause for BillsPharm
SET @WhereClauseforBillsPharm =
	  CHAR(13)+CHAR(10)+'WHERE '
	+ CHAR(13)+CHAR(10)+CHAR(9) + ' bp.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))
	+ CHAR(13)+CHAR(10)+CHAR(9) + CASE WHEN @IsIncrementalLoad = 1 THEN ' AND bp.OdsPostingGroupAuditID > '+CAST(@RunFromOdsPostingGroupAuditId AS VARCHAR(50)) ELSE '' END


SET @SQLScript = CAST('' AS VARCHAR(MAX))+
'
IF OBJECT_ID(''tempdb..#RevenueCodes'') IS NOT NULL
	DROP TABLE #RevenueCodes

SELECT * INTO #RevenueCodes FROM '+@SourceDatabaseName+'.dbo.ub_revenuecodes

UPDATE	rc
SET
	revenuecodesubcategoryid=rc2.revenuecodesubcategoryid
FROM
	#RevenueCodes rc
	JOIN (SELECT DISTINCT revenuecode,revenuecodesubcategoryid FROM #RevenueCodes WHERE  revenuecodesubcategoryid IS NOT NULL) rc2 ON
	rc.revenuecode=rc2.revenuecode AND rc.revenuecodesubcategoryid IS NULL

IF OBJECT_ID(''tempdb..#CodeHierarchy'') IS NOT NULL
	DROP TABLE #CodeHierarchy
	
SELECT
	''Procedure'' Dataset,
	odscustomerid OdsCustomerId,	
	prc_cd Code,
	SUBSTRING(prc_desc,0,2500) Description,
	''Procedure'' Category,
	''Procedure'' SubCategory,
	StartDate,
	EndDate
INTO #CodeHierarchy
FROM
	'+@SourceDatabaseName+'.dbo.cpt_prc_dict

UNION

SELECT
	''Revenue'' Dataset,
	rc.odscustomerid,	
	rc.revenuecode,
	SUBSTRING(rc.prc_desc,0,2500) prc_desc,
	UPPER(rcc.Description),
	UPPER(rcsc.Description),
	StartDate,
	EndDate
FROM
	#RevenueCodes rc
	LEFT JOIN '+@SourceDatabaseName+'.dbo.revenuecodesubcategory rcsc ON rc.revenuecodesubcategoryid=rcsc.revenuecodesubcategoryid AND rc.odscustomerid=rcsc.odscustomerid 
	LEFT JOIN '+@SourceDatabaseName+'.dbo.revenuecodecategory rcc ON rcsc.revenuecodecategoryid=rcc.revenuecodecategoryid AND rcsc.odscustomerid=rcc.odscustomerid 


IF EXISTS (SELECT Name FROM tempdb.sys.indexes  WHERE Name = ''IDXPACodeHierarchyCode'' 
    AND object_id = OBJECT_ID(''tempdb..#CodeHierarchy''))
  BEGIN
    DROP INDEX IDXPACodeHierarchyCode ON #CodeHierarchy;
  END
CREATE INDEX IDXPACodeHierarchyCode ON #CodeHierarchy (DataSet,Code);


'+
CASE WHEN @IsIncrementalLoad = 0 THEN
'
IF EXISTS (SELECT Name FROM sys.indexes  WHERE Name=''IDXPACHOdsCustomerIdBillIdNo'' 
    AND object_id = OBJECT_ID(''stg.ProviderDataExplorerBillHeader''))
  BEGIN
    DROP INDEX IDXPACHOdsCustomerIdBillIdNo ON stg.ProviderDataExplorerBillHeader;
  END
CREATE INDEX IDXPACHOdsCustomerIdBillIdNo ON stg.ProviderDataExplorerBillHeader (OdsCustomerId,BillIdNo,TypeOfBill);
'
ELSE '' END
+
'
TRUNCATE TABLE stg.ProviderDataExplorerBillLine;

DECLARE @ODSPAPRCodeTypePharma  VARCHAR(100),
		@ODSPAUB04 VARCHAR(10),
		@ODSPACMS1500 VARCHAR(10),
		@ODSPABillLineTypePharma VARCHAR(30),
		@ODSPABillLineType VARCHAR(30),
		@ODSPAPRDescPharma VARCHAR(100),
		@ODSPAPRCategoryPharma VARCHAR(100),
		@ODSPAPRSubCategoryPharma VARCHAR(100);

		SELECT @ODSPAUB04 = ParameterValue FROM  adm.ReportParameters WHERE ReportId = 9 AND ParameterName = ''ODSPAUB04''
		SELECT @ODSPACMS1500 = ParameterValue FROM  adm.ReportParameters WHERE ReportId = 9 AND ParameterName = ''ODSPACMS1500''
		SELECT @ODSPABillLineType = ParameterValue FROM  adm.ReportParameters WHERE ReportId = 9 AND ParameterName = ''ODSPABillLineType''
		SELECT @ODSPAPRCodeTypePharma = ParameterValue FROM adm.ReportParameters WHERE ReportId = 9 AND ParameterName = ''ODSPAPRCodeTypePharma''
		SELECT @ODSPAPRDescPharma = ParameterValue FROM adm.ReportParameters WHERE ReportId = 9 AND ParameterName = ''ODSPAPRDescPharma''
		SELECT @ODSPAPRCategoryPharma = ParameterValue FROM adm.ReportParameters WHERE ReportId = 9 AND ParameterName = ''ODSPAPRCategoryPharma''
		SELECT @ODSPAPRSubCategoryPharma = ParameterValue FROM adm.ReportParameters WHERE ReportId = 9 AND ParameterName = ''ODSPAPRSubCategoryPharma''
		SELECT @ODSPABillLineTypePharma = ParameterValue FROM  adm.ReportParameters WHERE ReportId = 9 AND ParameterName = ''ODSPABillLineTypePharma''

INSERT INTO stg.ProviderDataExplorerBillLine(
			OdsPostingGroupAuditId,
			OdsCustomerId,
			BillIdNo,
			LineNumber,			
			OverRide,
			DTSVC,
			PRCCD,
			Units,
			Charged,
			Allowed,
			Analyzed,
			RefLineNo,
			POSRevCode,
			Adjustment,
			FormType,
			CodeType,
			Code,
			ProviderZipOfService,
			BillLineType,
			CodeDescription,
			CodeCategory,
			CodeSubCategory,
			IsCodeNumeric,
			Modifier			
)
SELECT 		
			b.OdsPostingGroupAuditId,
			b.OdsCustomerId,
			b.BillIdNo,
			b.LINE_NO,			
			b.Over_Ride,
			b.DT_SVC,
			b.PRC_CD,
			b.Units,
			b.Charged,
			b.Allowed,
			b.Analyzed,
			b.REF_LINE_NO,
			b.POS_RevCode,
			ISNULL(b.CHARGED, 0) - ISNULL(b.ALLOWED, 0) AS Adjustment,
			    CASE
                  WHEN(bh.Flags&4096) = 4096
                  THEN @ODSPAUB04
                  ELSE @ODSPACMS1500
              END AS FormTypeDesc,
			  CASE
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)=''3'' THEN ''Procedure''
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)<>''3'' THEN ''REVENUE''
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')='''' THEN ''REVENUE''
			ELSE ''Procedure'' END PR_Code_Type,
			  CASE
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)=''3'' THEN b.prc_cd
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)<>''3'' THEN b.pos_revcode
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')='''' THEN b.pos_revcode
			ELSE b.prc_cd END PR_Code,
			bh.PvdZOS,
			@ODSPABillLineType,
			ch.Description CodeDescription,
			ch.Category CodeCategory,
			ch.SubCategory CodeSubCategory,
			CASE WHEN ISNUMERIC(b.PRC_CD) = 1 THEN 1 
				 WHEN ISNUMERIC(b.PRC_CD) = 0 THEN 0 END,
			b.TS_CD												

	FROM '+@SourceDatabaseName+'.dbo.BILLS b '
		+ CHAR(13)+CHAR(10)+CHAR(9) + 
		CASE
			WHEN @IsIncrementalLoad = 0 THEN
		'INNER JOIN stg.ProviderDataExplorerBillHeader bh ON b.OdsCustomerId = bh.OdsCustomerId 
																				AND b.BillIdNo = bh.BillIdNo'
												
			ELSE 'INNER JOIN '+@SourceDatabaseName+'.dbo.BILL_HDR bh ON b.OdsCustomerId = bh.OdsCustomerId 
																				AND b.BillIdNo = bh.BillIdNo'
		  END
		+ CHAR(13)+CHAR(10)+CHAR(9) +
		'LEFT JOIN #CodeHierarchy ch ON	 CASE
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)=''3'' THEN ''Procedure''
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)<>''3'' THEN ''Revenue''
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')='''' THEN ''Revenue''
			ELSE ''Procedure'' END = ch.Dataset
			AND
					 CASE
							WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)=''3'' THEN b.prc_cd
							WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)<>''3'' THEN b.pos_revcode
							WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')='''' THEN b.pos_revcode
					ELSE b.prc_cd END = ch.Code
			AND b.dt_svc BETWEEN ch.StartDate AND ch.EndDate
			AND b.OdsCustomerId = ch.OdsCustomerId        
			'											    
		+ @WhereClauseforBills  +'		

UNION 

SELECT 		
			bp.OdsPostingGroupAuditId,
			bp.OdsCustomerId,
			bp.BillIdNo,
			bp.LINE_NO,
			bp.OverRide,
			bp.DateOfService,
			REPLACE(bp.NDC,''-'','''') AS NDC,
			bp.Units,
			bp.Charged,
			bp.Allowed,
			bp.Analyzed,
			0,
			bp.POS_RevCode,
			ISNULL(bp.CHARGED, 0) - ISNULL(bp.ALLOWED, 0) AS Adjustment,
			CASE
               WHEN(bh.Flags&4096) = 4096
               THEN @ODSPAUB04
               ELSE @ODSPACMS1500
			 END AS FormTypeDesc,			
			@ODSPAPRCodeTypePharma AS PR_Code_Type,			 
			CONVERT(VARCHAR(100),REPLACE(NDC,''-'','''')) AS PR_Code,
			bh.PvdZOS,
			@ODSPABillLineTypePharma,			
			@ODSPAPRDescPharma,
			@ODSPAPRCategoryPharma,
			@ODSPAPRSubCategoryPharma,
			CASE WHEN ISNUMERIC(REPLACE(bp.NDC,''-'','''')) = 1 THEN 1 
				 WHEN ISNUMERIC(REPLACE(bp.NDC,''-'','''')) = 0 THEN 0 END,
			'''' as TS_CD

		FROM '+@SourceDatabaseName+'.dbo.Bills_Pharm bp '
		+ CHAR(13)+CHAR(10)+CHAR(9) + 
			CASE
			WHEN @IsIncrementalLoad = 0 THEN
		'INNER JOIN stg.ProviderDataExplorerBillHeader bh ON bp.OdsCustomerId = bh.OdsCustomerId 
																				AND bp.BillIdNo = bh.BillIdNo'												
			ELSE 'INNER JOIN '+@SourceDatabaseName+'.dbo.BILL_HDR bh ON bp.OdsCustomerId = bh.OdsCustomerId 
																				AND bp.BillIdNo = bh.BillIdNo'
		  END
		+ CHAR(13)+CHAR(10)+CHAR(9) +											
				   + @WhereClauseforBillsPharm  

				  	+ CHAR(13)+CHAR(10)+CHAR(9)
        +CASE
			WHEN @IsIncrementalLoad = 0 THEN
		+'DROP INDEX IDXPACHOdsCustomerIdBillIdNo ON stg.ProviderDataExplorerBillHeader;'
		ELSE '' END
		+ CHAR(13)+CHAR(10)+CHAR(9)+'
		
			
	   DELETE b  
       FROM  stg.ProviderDataExplorerBillLine b 
	   INNER JOIN '+@SourceDatabaseName+'.dbo.BILLS_Endnotes e ON b.BillIdNo = e.BillIDNo 
													AND b.LineNumber = e.LINE_NO 
													AND b.OdsCustomerId = e.OdsCustomerId
       WHERE e.EndNote = 45 AND e.OdsCustomerId ='+CONVERT(VARCHAR(100),@OdsCustomerId)+';	
	   
/*Update the category and subcategory for RC codes like 
RC250 is replaced with 0250 and provider category and subcategory */
	   
UPDATE	b 
SET
	b.CodeCategory = rc.Category,
	b.CodeSubCategory = rc.SubCategory
FROM
	stg.ProviderDataExplorerBillLine b
    INNER JOIN  rpt.ProviderDataExplorerPRCodeDataQuality Pr ON b.Code = pr.Code 
												AND  ISNULL(pr.Category,'''' ) = '''' 
												AND pr.MappedCode = ''RC''
												AND b.Code like ''RC%''
	INNER JOIN #CodeHierarchy rc ON REPLACE(b.Code,''RC'',''0'') = rc.Code 
												AND b.OdsCustomerId = rc.OdsCustomerId ;


		
IF EXISTS (SELECT Name FROM sys.indexes  WHERE Name = ''IDPA_ProviderDataExplorerBillLinePOSRevCode'' 
    AND object_id = OBJECT_ID(''stg.ProviderDataExplorerBillLine''))
	BEGIN
    DROP INDEX IDPA_ProviderDataExplorerBillLinePOSRevCode ON stg.ProviderDataExplorerBillLine;
  END
CREATE INDEX IDPA_ProviderDataExplorerBillLinePOSRevCode ON stg.ProviderDataExplorerBillLine (BillIdno,POSRevCode);



IF OBJECT_ID(''tempdb..#SubFormTypeTemp'') IS NOT NULL
	DROP TABLE #SubFormTypeTemp
SELECT 	Bl.BillIdNo,
		Bl.LineNumber,
		ISNULL(CASE WHEN  bl.FormType = ''CMS-1500'' THEN Ps.Description 
								     WHEN  bl.FormType = ''UB-04''    THEN SUBSTRING(bt.Description,1,CHARINDEX('';'',bt.Description)-1)						   
						        END ,''N/A'') SubFormType
		INTO #SubFormTypeTemp
FROM stg.ProviderDataExplorerBillHeader bh 
INNER JOIN stg.ProviderDataExplorerBillLine bl ON bl.BillIdNo = bh.BillIdNo 
												AND bl.OdsCustomerId = bh.OdsCustomerId 												
LEFT JOIN '+@SourceDatabaseName+'.dbo.UB_BillType bt on bh.TypeOfBill = bt.tob 
												AND bl.OdsCustomerId = bt.OdsCustomerId 												
LEFT JOIN '+@SourceDatabaseName+'.dbo.PlaceOfServiceDictionary ps ON  bl.POSRevCode = RIGHT(CONCAT(''00'', ISNULL(CONVERT(VARCHAR(2),ps.PlaceOfServiceCode),'''')),2)
												AND bl.OdsCustomerId = ps.OdsCustomerId 
												AND (CONVERT(DATE,bl.DTSVC) BETWEEN StartDate AND EndDate)
		
		
	IF EXISTS (SELECT Name FROM tempdb.sys.indexes  WHERE Name = ''IDXPA_SubFormTypeTempBillIdNo'' 
    AND object_id = OBJECT_ID(''tempdb..#SubFormTypeTemp''))
  BEGIN
    DROP INDEX IDXPA_SubFormTypeTempBillIdNo ON #SubFormTypeTemp;
  END
CREATE INDEX IDXPA_SubFormTypeTempBillIdNo ON #SubFormTypeTemp (BillIdNo,LineNumber);
		
												
	UPDATE bl 
		SET 
		bl.SubFormType = sf.SubFormType
FROM stg.ProviderDataExplorerBillLine bl 
INNER JOIN  #SubFormTypeTemp SF ON SF.BillIdNo = bl.BillIdNo 
									AND SF.LineNumber = bl.LineNumber
	
	
IF EXISTS (SELECT Name FROM sys.indexes  WHERE Name = ''IDPA_ProviderDataExplorerBillLinePOSRevCode'' 
    AND object_id = OBJECT_ID(''stg.ProviderDataExplorerBillLine''))
	BEGIN
    DROP INDEX IDPA_ProviderDataExplorerBillLinePOSRevCode ON stg.ProviderDataExplorerBillLine;
  END

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




IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderAnalyticsRptLoadBillLine') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderAnalyticsRptLoadBillLine

GO 

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerRptLoadBillLine') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerRptLoadBillLine

GO 

CREATE PROCEDURE dbo.ProviderDataExplorerRptLoadBillLine(
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
		@AuditFor Varchar(100),
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

SET @SQLScript = CAST('' AS VARCHAR(MAX)) + 
'
DECLARE @ODSPAPRDesc VARCHAR(100),
		@ODSPAPRCategory VARCHAR(100),
		@ODSPAPRSubCategory VARCHAR(100),		
		@ODSPAPRDescPharma VARCHAR(100),
		@ODSPAPRCategoryPharma VARCHAR(100),
		@ODSPAPRSubCategoryPharma VARCHAR(100);

		SELECT @ODSPAPRDesc = ParameterValue FROM  adm.ReportParameters WHERE ReportId = 9 AND ParameterName = ''ODSPAPRDesc''
		SELECT @ODSPAPRCategory = ParameterValue FROM  adm.ReportParameters WHERE ReportId = 9 AND ParameterName = ''ODSPAPRCategory''
		SELECT @ODSPAPRSubCategory = ParameterValue FROM  adm.ReportParameters WHERE ReportId = 9 AND ParameterName = ''ODSPAPRSubCategory''
		SELECT @ODSPAPRDescPharma = ParameterValue FROM  adm.ReportParameters WHERE ReportId = 9 AND ParameterName = ''ODSPAPRDescPharma''
		SELECT @ODSPAPRCategoryPharma = ParameterValue FROM  adm.ReportParameters WHERE ReportId = 9 AND ParameterName = ''ODSPAPRCategoryPharma''
		SELECT @ODSPAPRSubCategoryPharma = ParameterValue FROM  adm.ReportParameters WHERE ReportId = 9 AND ParameterName = ''ODSPAPRSubCategoryPharma''
'+
	CASE 
		WHEN  @IsIncrementalLoad = 1 THEN		
--Incremental Load
-- Update all the records coming from staging and insert the new records to destination
'
UPDATE d 
SET		
			d.OverRide = s.OverRide,
			d.DateofService = s.DTSVC,
			d.ProcedureCode = s.PRCCD,
			d.Units = ISNULL(s.Units,0),
			d.Charged = s.Charged,
			d.Allowed = s.Allowed,
			d.Analyzed = s.Analyzed,
			d.RefLineNo = s.RefLineNo,
			d.POSRevCode = s.POSRevCode,
			d.Adjustment = s.Adjustment,
			d.FormType = s.FormType,
			d.CodeType = CASE WHEN s.CodeType IN (''Procedure'',''NDC'') AND s.IsCodeNumeric = 1 THEN ISNULL(ndcchy.CodeType,@ODSPAPRDesc)
							  WHEN s.CodeType IN (''Procedure'',''NDC'') AND s.IsCodeNumeric = 0 THEN ISNULL(chy.CodeType,@ODSPAPRDesc)
						      WHEN s.CodeType = ''Revenue'' THEN ISNULL(s.CodeType,@ODSPAPRDesc)
							  ELSE ISNULL(s.CodeType,@ODSPAPRDesc) END ,
			d.Code = s.Code,
			d.CodeDescription = CASE WHEN s.CodeType = ''NDC'' AND s.IsCodeNumeric = 0 THEN ISNULL(ndcchy.Description,@ODSPAPRDesc)
									 WHEN s.CodeType = ''NDC'' AND s.IsCodeNumeric = 1 THEN ISNULL(chy.Description,@ODSPAPRDesc)
									 WHEN s.CodeType IN (''Procedure'',''Revenue'') THEN ISNULL(s.CodeDescription,@ODSPAPRDesc)
									 END,
			d.Category = CASE WHEN s.CodeType IN (''Procedure'',''NDC'') AND s.IsCodeNumeric = 0 THEN ISNULL(chy.Category,@ODSPAPRCategory)
							  WHEN s.CodeType IN (''Procedure'',''NDC'') AND s.IsCodeNumeric = 1 THEN ISNULL(ndcchy.Category,@ODSPAPRCategory)
							  WHEN s.CodeType = ''Revenue'' THEN ISNULL(s.CodeCategory,@ODSPAPRCategory)
							  END ,
			d.SubCategory = CASE WHEN s.CodeType IN (''Procedure'',''NDC'') AND s.IsCodeNumeric = 0 THEN ISNULL(chy.SubCategory,@ODSPAPRSubCategory)
								 WHEN s.CodeType IN (''Procedure'',''NDC'') AND s.IsCodeNumeric = 1 THEN ISNULL(ndcchy.SubCategory,@ODSPAPRSubCategory)
								 WHEN s.CodeType = ''Revenue'' THEN ISNULL(s.CodeSubCategory,@ODSPAPRSubCategory)
								 END,
			d.BillLineType = s.BillLineType,
			d.BundlingFlag = s.BundlingFlag,
			d.ExceptionFlag = s.ExceptionFlag,
			d.ExceptionComments = s.ExceptionComments,
			d.VisitType = cm1.CodeCategory,
			d.ProviderZoSLat = zc.Lat,
			d.ProviderZoSLong = zc.Long,
			d.ProviderZoSState = zc.State,
			d.ModalityType = cm2.CodeCategory,
			d.ModalityUnitType = CASE WHEN cm2.CodeSubCategory = ''Timed''	AND s.Units >= 1 THEN ''Timed'' 
									  WHEN cm2.CodeSubCategory = ''UnTimed'' AND s.Units > 1 THEN ''UnTimed''
				                      ELSE ''Other'' END,		
			d.RunDate = GETDATE(),
			d.SubFormType = ISNULL(UPPER(s.SubFormType),''N/A''),
			d.BillInjuryDescription = s.BillInjuryDescription,
			d.Modifier = s.Modifier,
			d.EndNote = s.EndNote
FROM dbo.ProviderDataExplorerBillLine d 
	INNER JOIN stg.ProviderDataExplorerBillLine s ON s.BillIdNo = d.BillId
											 AND s.LineNumber = d.LineNumber
											 AND s.BillLineType = d.BillLineType
											 AND s.OdsCustomerId = d.OdsCustomerId
																					 
	LEFT JOIN rpt.ProviderDataExplorerZipCode zc ON SUBSTRING(s.ProviderZipOfService,1,5) = SUBSTRING(zc.zipcode,1,5)
	LEFT JOIN (SELECT CodeStart,
			          CodeEnd,
			          Category,
			          SubCategory,
			          Description,
			          CodeType,
			          IsCodeNumeric
			    FROM rpt.ProviderDataExplorerCodeHierarchy WHERE IsCodeNumeric = 0 ) chy ON s.Code BETWEEN chy.CodeStart AND chy.CodeEnd
			    AND s.IsCodeNumeric = chy.IsCodeNumeric
			    AND s.CodeType IN (''Procedure'',''NDC'')
			    AND s.IsCodeNumeric = 0			          
	LEFT JOIN (SELECT CodeStart,
			          Category,
			          SubCategory,
			          Description,
			          CodeType,
			          IsCodeNumeric
			    FROM rpt.ProviderDataExplorerCodeHierarchy WHERE IsCodeNumeric = 1 ) ndcchy ON s.Code = ndcchy.CodeStart
			    AND s.IsCodeNumeric = Ndcchy.IsCodeNumeric
			    AND s.CodeType IN (''Procedure'',''NDC'')
			    AND s.IsCodeNumeric = 1
	LEFT JOIN rpt.ProviderDataExplorerCodeMapping cm1 ON s.Code BETWEEN cm1.CodeStart AND cm1.CodeEnd AND cm1.CodeType = ''VisitType''
	LEFT JOIN rpt.ProviderDataExplorerCodeMapping cm2 ON s.Code BETWEEN cm2.CodeStart AND cm2.CodeEnd AND cm2.CodeType = ''ModalityType''
	


INSERT INTO dbo.ProviderDataExplorerBillLine
		  (
			OdsPostingGroupAuditId,
			OdsCustomerId,
			BillId,
			LineNumber,			
			OverRide,
			DateofService,
			ProcedureCode,
			Units,
			Charged,
			Allowed,
			Analyzed,
			RefLineNo,
			POSRevCode,
			Adjustment,
			FormType,
			CodeType,
			Code,
			CodeDescription,
			Category,
			SubCategory,
			BillLineType,
			BundlingFlag,
			ExceptionFlag,
			ExceptionComments,
			VisitType,							
			ProviderZoSLat,
			ProviderZoSLong,
			ProviderZoSState,
			ModalityType,
			ModalityUnitType,
			SubFormType,
			BillInjuryDescription,
			Modifier,
			EndNote		
		   )
SELECT 
			s.OdsPostingGroupAuditId,
			s.OdsCustomerId,
			s.BillIdNo,
			s.LineNumber,			
			s.OverRide,
			s.DTSVC,
			s.PRCCD,
			ISNULL(s.Units,0) AS Units,
			s.Charged,
			s.Allowed,
			s.Analyzed,
			s.RefLineNo,
			s.POSRevCode,	
			s.Adjustment,
			s.FormType,			
			CASE WHEN s.CodeType IN (''Procedure'',''NDC'') AND s.IsCodeNumeric = 1 THEN ISNULL(ndcchy.CodeType,@ODSPAPRDesc)
				 WHEN s.CodeType IN (''Procedure'',''NDC'') AND s.IsCodeNumeric = 0 THEN ISNULL(chy.CodeType,@ODSPAPRDesc)
				 WHEN s.CodeType = ''Revenue'' THEN ISNULL(s.CodeType,@ODSPAPRDesc)
				 ELSE ISNULL(s.CodeType,@ODSPAPRDesc) END CodeType,			
			s.Code,			
			CASE WHEN s.CodeType = ''NDC'' AND s.IsCodeNumeric = 0 THEN ISNULL(ndcchy.Description,@ODSPAPRDesc)
				 WHEN s.CodeType = ''NDC'' AND s.IsCodeNumeric = 1 THEN ISNULL(chy.Description,@ODSPAPRDesc)
				 WHEN s.CodeType IN (''Procedure'',''Revenue'') THEN ISNULL(s.CodeDescription,@ODSPAPRDesc)
				 END  CodeDescription,				
			CASE WHEN s.CodeType IN (''Procedure'',''NDC'') AND s.IsCodeNumeric = 0 THEN ISNULL(chy.Category,@ODSPAPRCategory)
				 WHEN s.CodeType IN (''Procedure'',''NDC'') AND s.IsCodeNumeric = 1 THEN ISNULL(ndcchy.Category,@ODSPAPRCategory)
				 WHEN s.CodeType = ''Revenue'' THEN ISNULL(s.CodeCategory,@ODSPAPRCategory)
				 END  CodeCategory,			
			CASE WHEN s.CodeType IN (''Procedure'',''NDC'') AND s.IsCodeNumeric = 0 THEN ISNULL(chy.SubCategory,@ODSPAPRSubCategory)
				 WHEN s.CodeType IN (''Procedure'',''NDC'') AND s.IsCodeNumeric = 1 THEN ISNULL(ndcchy.SubCategory,@ODSPAPRSubCategory)
				 WHEN s.CodeType = ''Revenue'' THEN ISNULL(s.CodeSubCategory,@ODSPAPRSubCategory)
				 END  CodeSubCategory,
			s.BillLineType,	
			s.BundlingFlag,
			s.ExceptionFlag,
			s.ExceptionComments,
			cm1.CodeCategory,		
			zc.Lat AS ProviderZoSLat,
			zc.Long AS ProviderZoSLong,
			zc.State AS ProviderZoSState,
			cm2.CodeCategory,
			CASE WHEN cm2.CodeSubCategory = ''Timed''	AND s.Units >= 1 THEN ''Timed'' 
				 WHEN cm2.CodeSubCategory = ''UnTimed''	AND s.Units > 1 THEN ''UnTimed''
				 ELSE ''Other'' END	,
			ISNULL(UPPER(s.SubFormType),''N/A''),
			s.BillInjuryDescription,
			s.Modifier,
			s.EndNote
	FROM dbo.ProviderDataExplorerBillLine d 
	LEFT JOIN stg.ProviderDataExplorerBillLine s ON s.BillIdNo = d.BillId
										 AND s.LineNumber = d.LineNumber
										 AND s.BillLineType = d.BillLineType
										 AND s.OdsCustomerId = d.OdsCustomerId
	LEFT JOIN rpt.ProviderDataExplorerZipCode zc ON SUBSTRING(s.ProviderZipOfService,1,5) = SUBSTRING(zc.zipcode,1,5)
	LEFT JOIN (SELECT CodeStart,
			          CodeEnd,
			          Category,
			          SubCategory,
			          Description,
			          CodeType,
			          IsCodeNumeric
			    FROM rpt.ProviderDataExplorerCodeHierarchy WHERE IsCodeNumeric = 0 ) chy ON s.Code BETWEEN chy.CodeStart AND chy.CodeEnd
			    AND s.IsCodeNumeric = chy.IsCodeNumeric
			    AND s.CodeType IN (''Procedure'',''NDC'')
			    AND s.IsCodeNumeric = 0			          
	LEFT JOIN (SELECT CodeStart,
			          Category,
			          SubCategory,
			          Description,
			          CodeType,
			          IsCodeNumeric
			    FROM rpt.ProviderDataExplorerCodeHierarchy WHERE IsCodeNumeric = 1 ) ndcchy ON s.Code = ndcchy.CodeStart
			    AND s.IsCodeNumeric = Ndcchy.IsCodeNumeric
			    AND s.CodeType IN (''Procedure'',''NDC'')
			    AND s.IsCodeNumeric = 1
	LEFT JOIN rpt.ProviderDataExplorerCodeMapping cm1 ON s.Code BETWEEN cm1.CodeStart AND cm1.CodeEnd AND cm1.CodeType = ''VisitType''
	LEFT JOIN rpt.ProviderDataExplorerCodeMapping cm2 ON s.Code BETWEEN cm2.CodeStart AND cm2.CodeEnd AND cm2.CodeType = ''ModalityType''	 
	WHERE d.BillId IS NULL AND d.LineNumber IS NULL 


'				
ELSE
--Full Load
--Insert all the records coming from staging
'
IF OBJECT_ID(''tempdb..#IsCodeNumericzeroDP'',''U'') IS NOT NULL
		DROP TABLE #IsCodeNumericzeroDP;

   SELECT CodeStart,
	      CodeEnd,
	      Category,
	      SubCategory,
	      Description,
	      CodeType,
	      IsCodeNumeric
	INTO #IsCodeNumericzeroDP
	FROM rpt.ProviderDataExplorerCodeHierarchy WHERE IsCodeNumeric = 0
IF EXISTS (SELECT Name FROM tempdb.sys.indexes
			WHERE Name = ''IX_IsCodeNumericzeroDP''
			AND OBJECT_ID = OBJECT_ID(''tempdb..#IsCodeNumericzeroDP''))
BEGIN
DROP INDEX IX_IsCodeNumericzeroDP ON #IsCodeNumericzeroDP ;
END
CREATE INDEX IX_IsCodeNumericzeroDP ON #IsCodeNumericzeroDP (CodeStart,CodeEnd);


IF OBJECT_ID(''tempdb..#IsCodeNumericOneDP'',''U'') IS NOT NULL
		DROP TABLE #IsCodeNumericOneDP;

   SELECT CodeStart,
	      Category,
	      SubCategory,
	      Description,
	      CodeType,
	      IsCodeNumeric
	INTO #IsCodeNumericOneDP
	FROM rpt.ProviderDataExplorerCodeHierarchy WHERE IsCodeNumeric = 1 
IF EXISTS (SELECT Name FROM tempdb.sys.indexes
			WHERE Name = ''IX_IsCodeNumericOneDP''
			AND OBJECT_ID = OBJECT_ID(''tempdb..#IsCodeNumericOneDP''))
BEGIN
DROP INDEX IX_IsCodeNumericOneDP ON #IsCodeNumericOneDP ;
END
CREATE INDEX IX_IsCodeNumericOneDP ON #IsCodeNumericOneDP (CodeStart);


INSERT INTO dbo.ProviderDataExplorerBillLine(
			OdsPostingGroupAuditId,
			OdsCustomerId,
			BillId,
			LineNumber,		
			OverRide,
			DateofService,
			ProcedureCode,
			Units,
			Charged,
			Allowed,
			Analyzed,
			RefLineNo,
			POSRevCode,
			Adjustment,
			FormType,
			CodeType,
			Code,
			CodeDescription,
			Category,
			SubCategory,
			BillLineType,
			BundlingFlag,
			ExceptionFlag,
			ExceptionComments,
			VisitType,
			ProviderZoSLat,
			ProviderZoSLong,
			ProviderZoSState,
			ModalityType,
			ModalityUnitType,
			SubFormType,
			BillInjuryDescription,
			Modifier,
			EndNote							
			)
	SELECT 
			b.OdsPostingGroupAuditId,
			b.OdsCustomerId,
			b.BillIdNo,
			b.LineNumber,			
			b.OverRide,
			b.DTSVC,
			b.PRCCD,
			ISNULL(b.Units,0),
			b.Charged,
			b.Allowed,
			b.Analyzed,
			b.RefLineNo,
			b.POSRevCode,	
			b.Adjustment,			
			b.FormType,			
			CASE WHEN b.CodeType IN (''Procedure'',''NDC'') AND b.IsCodeNumeric = 0 THEN ISNULL(chy.CodeType,@ODSPAPRDesc)
				 WHEN b.CodeType IN (''Procedure'',''NDC'') AND b.IsCodeNumeric = 1 THEN ISNULL(ndcchy.CodeType,@ODSPAPRDesc)
				 WHEN b.CodeType = ''Revenue'' THEN ISNULL(b.CodeType,@ODSPAPRDesc)
				 ELSE ISNULL(b.CodeType,@ODSPAPRDesc) END CodeType,			
			b.Code,			
			CASE WHEN b.CodeType = ''NDC'' AND b.IsCodeNumeric = 0 THEN ISNULL(ndcchy.Description,@ODSPAPRDesc)
				 WHEN b.CodeType = ''NDC'' AND b.IsCodeNumeric = 1 THEN ISNULL(chy.Description,@ODSPAPRDesc)
				 WHEN b.CodeType IN (''Procedure'',''Revenue'') THEN ISNULL(b.CodeDescription,@ODSPAPRDesc)
				 END CodeDescription,				
			CASE WHEN b.CodeType IN (''Procedure'',''NDC'') AND b.IsCodeNumeric = 0 THEN ISNULL(chy.Category,@ODSPAPRCategory)
				 WHEN b.CodeType IN (''Procedure'',''NDC'') AND b.IsCodeNumeric = 1 THEN ISNULL(ndcchy.Category,@ODSPAPRCategory)
				 WHEN b.CodeType = ''Revenue'' THEN ISNULL(b.CodeCategory,@ODSPAPRCategory)
				 END AS CodeCategory,			
			CASE WHEN b.CodeType IN (''Procedure'',''NDC'') AND b.IsCodeNumeric = 0 THEN ISNULL(chy.SubCategory,@ODSPAPRSubCategory)
				 WHEN b.CodeType IN (''Procedure'',''NDC'') AND b.IsCodeNumeric = 1 THEN ISNULL(ndcchy.SubCategory,@ODSPAPRSubCategory)
				 WHEN b.CodeType = ''Revenue'' THEN ISNULL(b.CodeSubCategory,@ODSPAPRSubCategory)
				 END AS CodeSubCategory,
			BillLineType,
			b.BundlingFlag,
			b.ExceptionFlag,
			b.ExceptionComments,
			cm1.CodeCategory,			
			zc.Lat AS ProviderZoSLat,
			zc.Long AS ProviderZoSLong,
			zc.State AS ProviderZoSState,
			cm2.CodeCategory,
			CASE WHEN cm2.CodeSubCategory = ''Timed''	AND b.Units >= 1 THEN ''Timed'' 
				 WHEN cm2.CodeSubCategory = ''UnTimed''	AND b.Units > 1 THEN ''UnTimed''
				 ELSE ''Other'' END	,
			ISNULL(UPPER(b.SubFormType),''N/A''),
			b.BillInjuryDescription,
			b.Modifier,
			b.EndNote		
FROM  stg.ProviderDataExplorerBillLine b 
	LEFT JOIN rpt.ProviderDataExplorerZipCode zc ON SUBSTRING(b.ProviderZipOfService,1,5) = SUBSTRING(zc.zipcode,1,5)
	LEFT JOIN #IsCodeNumericzeroDP chy ON b.Code BETWEEN chy.CodeStart AND chy.CodeEnd
			    AND b.IsCodeNumeric = chy.IsCodeNumeric
			    AND b.CodeType IN (''Procedure'',''NDC'')
			    AND b.IsCodeNumeric = 0			          
	LEFT JOIN #IsCodeNumericOneDP ndcchy ON b.Code = ndcchy.CodeStart
			    AND b.IsCodeNumeric = Ndcchy.IsCodeNumeric
			    AND b.CodeType IN (''Procedure'',''NDC'')
			    AND b.IsCodeNumeric = 1
	LEFT JOIN rpt.ProviderDataExplorerCodeMapping cm1 ON b.Code BETWEEN cm1.CodeStart AND cm1.CodeEnd AND cm1.CodeType = ''VisitType''
	LEFT JOIN rpt.ProviderDataExplorerCodeMapping cm2 ON b.Code BETWEEN cm2.CodeStart AND cm2.CodeEnd AND cm2.CodeType = ''ModalityType''
	
	
	
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


IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderAnalyticsRptLoadClaimantHeader') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderAnalyticsRptLoadClaimantHeader
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerRptLoadClaimantHeader') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerRptLoadClaimantHeader
GO

CREATE PROCEDURE dbo.ProviderDataExplorerRptLoadClaimantHeader(
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
 
-- Get the Process Name
SET @ProcessName = ( SELECT OBJECT_NAME(@@PROCID) );

-- Tracking Process start in ETL Audit
EXEC dbo.ProviderDataExplorerEtlAuditStart @AuditFor,@ProcessName,@OdsPostingGroupAuditId,@ReportId;

DECLARE @SQLScript VARCHAR(MAX),
		@WhereClause VARCHAR(MAX),
		@RunFromOdsPostingGroupAuditId INT;

-- Get OdsPostingGroupAuditId from ETLAudit table for Incremental Load
SET @RunFromOdsPostingGroupAuditId = dbo.GetMaxRunFromOdsPostingGroupAuditId(@ProcessName,@AuditFor,@ReportId);


SET @SQLScript = CASE WHEN  @IsIncrementalLoad = 1 THEN 
--Incremental Load
-- Update all the records coming from staging and insert the new records to destination
'
UPDATE  d
SET   			 
		d.ClaimNumber = S.ClaimNo,
		d.DateLoss = S.DateLoss,
		d.CVCode = S.CVCode,
		d.LossState = S.LossState,			  
		d.ClaimantState = S.ClaimantState,
		d.ClaimantZip = S.ClaimantZip,
		d.ClaimantStateofJurisdiction = S.ClaimantStateofJurisdiction,
		d.CoverageType = S.CoverageType,			  
		d.ProviderID = S.ProviderIDNo,
		d.LastChangedOn = S.LastChangedOn,
		d.CustomerName = S.CustomerName,
		d.CVCodeDesciption = S.CVCodeDesciption,
		d.CoverageTypeDescription = S.CoverageTypeDescription,
		d.ClaimantZipLat =  zc.Lat,
		d.ClaimantZipLong = zc.Long,
		d.MSADesignation = ISNULL(msa.MSAUrbanBlankRuralRSuperRuralB,''U''),
		d.CBSADesignation = ISNULL(cb.CBSAUrbanBlankRuralRSuperRuralB,''U''),
		d.ExpectedTenureInDays = s.ExpectedTenureInDays,
		d.ExpectedRecoveryDate = s.ExpectedRecoveryDate,
		d.InjuryDescription = s.InjuryDescription,
		d.InjuryNatureId = s.InjuryNatureId,
		d.InjuryNaturePriority = s.InjuryNaturePriority,
		d.RunDate = GETDATE()		 			
FROM stg.ProviderDataExplorerClaimantHeader s 
	INNER JOIN dbo.ProviderDataExplorerClaimantHeader d ON s.ClaimantHdrIdNo=d.ClaimantHeaderId 	
														 AND s.OdsCustomerId = d.OdsCustomerId	 
	LEFT JOIN rpt.ProviderDataExplorerZipCode zc ON SUBSTRING(s.ClaimantZip,1,5) = SUBSTRING(zc.zipcode,1,5)
	LEFT JOIN rpt.ProviderDataExplorerZipCodeMSAvCBSA msa ON SUBSTRING(s.ClaimantZip,1,5)=msa.MSAZipCode
	LEFT JOIN rpt.ProviderDataExplorerZipCodeMSAvCBSA cb ON SUBSTRING(s.ClaimantZip,1,5)=cb.CBSAZipCode 

INSERT INTO dbo.ProviderDataExplorerClaimantHeader
       (
		OdsPostingGroupAuditId,
		OdsCustomerId,
		ClaimId,
		ClaimNumber,
		DateLoss,
		CVCode,
		LossState,
		ClaimantID,
		ClaimantState,
		ClaimantZip,
		ClaimantStateofJurisdiction,
		CoverageType,
		ClaimantHeaderID,
		ProviderID,
		CreateDate,
		LastChangedOn,
		CustomerName,
		CVCodeDesciption,
		CoverageTypeDescription,
		ClaimantZipLat,
		ClaimantZipLong,
		MSADesignation,
		CBSADesignation,
		ExpectedTenureInDays,
		ExpectedRecoveryDate,
		InjuryDescription,
	    InjuryNatureId,
		InjuryNaturePriority	
	   )
SELECT 
		s.OdsPostingGroupAuditId,
		s.OdsCustomerId,
		s.ClaimIDNo,
		s.ClaimNo,
		s.DateLoss,
		s.CVCode,
		s.LossState,			
		s.ClaimantIdNo,
		s.ClaimantState,
		s.ClaimantZip,
		s.ClaimantStateOfJurisdiction,
		s.CoverageType,
		s.ClaimantHdrIdNo,
		s.ProviderIDNo,
		s.CreateDate,
		s.LastChangedOn,
		s.CustomerName,
		s.CVCodeDesciption,
		s.CoverageTypeDescription	,
		zc.Lat AS ClaimantZipLat,
		zc.Long AS ClaimantZipLong,
		ISNULL(msa.MSAUrbanBlankRuralRSuperRuralB,''U'') AS MSADesignation,			  
		ISNULL(cb.CBSAUrbanBlankRuralRSuperRuralB,''U'') AS CBSADesignation,
		s.ExpectedTenureInDays,
		s.ExpectedRecoveryDate,
		s.InjuryDescription,
		s.InjuryNatureId,
		s.InjuryNaturePriority	

FROM stg.ProviderDataExplorerClaimantHeader s 
	LEFT JOIN dbo.ProviderDataExplorerClaimantHeader d ON  s.ClaimantHdrIdNo=d.ClaimantHeaderId 																
															AND s.OdsCustomerId = d.OdsCustomerId	 
	LEFT JOIN rpt.ProviderDataExplorerZipCode zc ON SUBSTRING(s.ClaimantZip,1,5) = SUBSTRING(zc.zipcode,1,5)
	LEFT JOIN rpt.ProviderDataExplorerZipCodeMSAvCBSA msa ON SUBSTRING(s.ClaimantZip,1,5)=msa.MSAZipCode
	LEFT JOIN rpt.ProviderDataExplorerZipCodeMSAvCBSA cb ON SUBSTRING(s.ClaimantZip,1,5)=cb.CBSAZipCode 
WHERE  d.ClaimId IS NULL AND d.ClaimantId IS NULL AND d.ClaimantHeaderId IS NULL
'
ELSE 
--Full Load
--Insert all the records coming from staging
'  

INSERT INTO dbo.ProviderDataExplorerClaimantHeader(
			OdsPostingGroupAuditId,
			OdsCustomerId,
			ClaimId,
			ClaimNumber,
			DateLoss,
			CVCode,
			LossState,
			ClaimantId,
			ClaimantState,
			ClaimantZip,
			ClaimantStateofJurisdiction,
			CoverageType,
			ClaimantHeaderId,
			ProviderId,
			CreateDate,
			LastChangedOn,
			CustomerName,
			CVCodeDesciption,
			CoverageTypeDescription,
			ClaimantZipLat,
			ClaimantZipLong,
			MSADesignation,
			CBSADesignation,
			ExpectedTenureInDays,
			ExpectedRecoveryDate,
			InjuryDescription,
			InjuryNatureId,
			InjuryNaturePriority
)
SELECT 
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
			CoverageTypeDescription,
			zc.Lat,
			zc.Long,
			ISNULL(msa.MSAUrbanBlankRuralRSuperRuralB,''U''),
			ISNULL(cb.CBSAUrbanBlankRuralRSuperRuralB,''U''),
			ExpectedTenureInDays,
			ExpectedRecoveryDate,
			InjuryDescription,
			InjuryNatureId,
			InjuryNaturePriority	
    FROM  stg.ProviderDataExplorerClaimantHeader cmt 
	LEFT JOIN rpt.ProviderDataExplorerZipCode zc ON SUBSTRING(cmt.ClaimantZip,1,5) = SUBSTRING(zc.zipcode,1,5)																
	LEFT JOIN rpt.ProviderDataExplorerZipCodeMSAvCBSA msa ON SUBSTRING(cmt.ClaimantZip,1,5)=msa.MSAZipCode
	LEFT JOIN rpt.ProviderDataExplorerZipCodeMSAvCBSA cb ON SUBSTRING(cmt.ClaimantZip,1,5)=cb.CBSAZipCode 
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



IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderAnalyticsRptUpdateBillLine') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderAnalyticsRptUpdateBillLine

GO 

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerRptUpdateBillLine') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerRptUpdateBillLine

GO 

CREATE PROCEDURE dbo.ProviderDataExplorerRptUpdateBillLine(
@SourceDatabaseName VARCHAR(50),
@SnapshotAsOf AS DATETIME,
@IsIncrementalLoad INT,
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
		@WhereClauseException VARCHAR(MAX),
		@WhereClauseCategory VARCHAR(MAX),
		@WhereClauseOldCode VARCHAR(MAX),
		@RunFromOdsPostingGroupAuditId INT;

-- Get OdsPostingGroupAuditId from ETLAudit table for Incremental Load
SET @RunFromOdsPostingGroupAuditId = dbo.GetMaxRunFromOdsPostingGroupAuditId(@ProcessName,@AuditFor,@ReportId)

SET @WhereClauseException =
	  CHAR(13)+CHAR(10)+'WHERE  bl.Category = @ODSPAPRCategory   AND cdq.ExceptionFlag = 1'	  
	+ CHAR(13)+CHAR(10)+CHAR(9) + ' AND bl.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))
	+ CHAR(13)+CHAR(10)+CHAR(9) + CASE WHEN @IsIncrementalLoad = 1 THEN ' AND bl.OdsPostingGroupAuditID > '+CAST(@RunFromOdsPostingGroupAuditId AS VARCHAR(50)) ELSE '' END	
	+ CHAR(13)+CHAR(10)+CHAR(9)

SET @WhereClauseCategory =
	  CHAR(13)+CHAR(10)+'WHERE  bl.Category = @ODSPAPRCategory AND cdq.Category IN (''Historical'',''Mitchell'')'
	+ CHAR(13)+CHAR(10)+CHAR(9) + ' AND bl.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))
	+ CHAR(13)+CHAR(10)+CHAR(9) + CASE WHEN @IsIncrementalLoad = 1 THEN ' AND bl.OdsPostingGroupAuditID > '+CAST(@RunFromOdsPostingGroupAuditId AS VARCHAR(50)) ELSE '' END	
	+ CHAR(13)+CHAR(10)+CHAR(9)
	 
SET @WhereClauseOldCode =
	  CHAR(13)+CHAR(10)+'WHERE  bl.Category = @ODSPAPRCategory '
	+ CHAR(13)+CHAR(10)+CHAR(9) + ' AND bl.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))
	+ CHAR(13)+CHAR(10)+CHAR(9) + CASE WHEN @IsIncrementalLoad = 1 THEN ' AND bl.OdsPostingGroupAuditID > '+CAST(@RunFromOdsPostingGroupAuditId AS VARCHAR(50)) ELSE '' END	
	+ CHAR(13)+CHAR(10)+CHAR(9)

SET @SQLScript = 
 '
	DECLARE @ODSPAPRCategory VARCHAR(50)
	SELECT @ODSPAPRCategory = ParameterValue FROM adm.ReportParameters WHERE ReportId=9 AND ParameterName=''ODSPAPRCategory'';

	/* Make ExceptionFlag is 1 where Invalid or Alternative Procedure Codes - Exclude */
	 UPDATE bl 
		SET bl.ExceptionFlag = 1,
			bl.ExceptionComments = ''Invalid or Alternative Procedure Codes - Exclude''
		FROM dbo.ProviderDataExplorerBillLine bl
		INNER JOIN rpt.ProviderDataExplorerPRCodeDataQuality cdq ON cdq.Code = bl.Code 
		'+@WhereClauseException +'; 

/*  update category and subcategory in bill lines */
UPDATE bl
	SET 
	bl.Category = cdq.Category,
	bl.SubCategory = cdq.SubCategory
FROM dbo.ProviderDataExplorerBillLine bl
INNER JOIN rpt.ProviderDataExplorerPRCodeDataQuality cdq ON cdq.Code = bl.Code 
'+@WhereClauseCategory +';


/*Set Old procedrue code mapped to new procedure codes.*/
UPDATE bl
SET
	bl.CodeType = cm.CodeType,
	bl.Category = cm.Category,
	bl.SubCategory = cm.SubCategory
 FROM dbo.ProviderDataExplorerBillLine bl 
INNER JOIN rpt.ProviderDataExplorerPRCodeDataQuality cdq ON cdq.Code = bl.Code 
												AND ISNULL(cdq.MappedCode,'''') <> '''' 
												AND ISNULL(cdq.MappedCode,'''') <> ''RC''
INNER JOIN rpt.ProviderDataExplorerCodeHierarchy cm ON cdq.MappedCode BETWEEN cm.CodeStart AND cm.CodeEnd 
														AND cm.CodeType IN (''CPT'',''HCPCS'',''CDT'')
 '+@WhereClauseOldCode+';

  
 /* Exclude Bills based on the CustomerBillExclusion list.*/

 UPDATE bl
        SET ExceptionFlag = 1,
			ExceptionComments = ''Bill excluded based on the CustomerBillExclusion list''
FROM dbo.ProviderDataExplorerBillLine bl 
JOIN stg.CustomerBillExclusionTemp t ON bl.OdsCustomerId = t.OdsCustomerId 
										   AND bl.BillId = t.BillIdNo ;
 
  IF OBJECT_ID(''stg.CustomerBillExclusionTemp'',''U'') IS NOT NULL					
	DROP TABLE stg.CustomerBillExclusionTemp;	
		 
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


IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderAnalyticsRptUpdateClaimantHeader') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderAnalyticsRptUpdateClaimantHeader
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerRptUpdateClaimantHeader') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerRptUpdateClaimantHeader
GO

CREATE PROCEDURE  dbo.ProviderDataExplorerRptUpdateClaimantHeader(
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
/*Update max min Dos tenture days*/

UPDATE ch
  SET 
      MinimumDateofService = dr.MinimumDateofService, 
      MaximumDateofService = dr.MaximumDateofService, 
      DOSTenureInDays = dr.DOSTenureInDays
FROM dbo.ProviderDataExplorerClaimantHeader ch
     JOIN
(
    SELECT ch.OdsCustomerId, 
           ch.ClaimantHeaderId, 
           MIN(bl.DateofService) MinimumDateofService, 
           MAX(bl.DateofService) MaximumDateofService, 
           DATEDIFF(d, MIN(bl.DateofService), MAX(bl.DateofService)) DOSTenureInDays

 FROM dbo.ProviderDataExplorerClaimantHeader ch  
INNER JOIN dbo.ProviderDataExplorerBillHeader bh ON ch.OdsCustomerId = bh.OdsCustomerId
													AND ch.ClaimantHeaderId = bh.ClaimantHeaderId
INNER JOIN dbo.ProviderDataExplorerBillLine bl ON bl.OdsCustomerId = bh.OdsCustomerId
													AND bl.BillId = bh.BillId 
													AND bl.ExceptionFlag = 0 '
												     
+@WhereClause+ '

    GROUP BY ch.OdsCustomerId, 
            -- ch.OdsPostingGroupAuditId, 
             ch.ClaimantHeaderId
) dr ON ch.OdsCustomerId = dr.OdsCustomerId       
        AND ch.ClaimantHeaderId = dr.ClaimantHeaderId;


/*Update the Derived_CV_Type from Bill Hdr level into ProviderDataExplorerClaimantHeader level.*/

UPDATE ch
	  SET 
      ch.DerivedCVType = COALESCE(bh.CVType, ch.CoverageType, ch.CVCode)
FROM dbo.ProviderDataExplorerClaimantHeader ch 
     LEFT JOIN dbo.ProviderDataExplorerBillHeader bh  ON bh.ClaimantHeaderId = ch.ClaimantHeaderId
                                   AND bh.OdsCustomerId = ch.OdsCustomerId	 '
+@WhereClause+ '

UPDATE ch
	  SET 
      ch.DerivedCVDesc = COALESCE(bh.CVTypeDescription, ch.CoverageTypeDescription, ch.CVCodeDesciption)
FROM dbo.ProviderDataExplorerClaimantHeader ch 
     LEFT JOIN dbo.ProviderDataExplorerBillHeader bh ON bh.ClaimantHeaderId = ch.ClaimantHeaderId
                                   AND bh.OdsCustomerId = ch.OdsCustomerId	 '
+@WhereClause 

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







IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderAnalyticsUpdateBillLine') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderAnalyticsUpdateBillLine

GO 

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerUpdateBillLine') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerUpdateBillLine

GO 
CREATE PROCEDURE dbo.ProviderDataExplorerUpdateBillLine(
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
		@WhereClause VARCHAR(MAX),	    
		@RunFromOdsPostingGroupAuditId INT;

-- Get OdsPostingGroupAuditId from ETLAudit table for Incremental Load
SET @RunFromOdsPostingGroupAuditId = dbo.GetMaxRunFromOdsPostingGroupAuditId(@ProcessName,@AuditFor,@ReportId)

SET @WhereClause =
	  CHAR(13)+CHAR(10)+'WHERE ex.ReportID = '+CAST(@ReportId AS VARCHAR(3)) 
	+ CHAR(13)+CHAR(10)+CHAR(9) + 'AND cus.CustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))
	---+ CHAR(13)+CHAR(10)+CHAR(9) + CASE WHEN @IsIncrementalLoad = 1 THEN ' AND ex.OdsPostingGroupAuditID > '+CAST(@RunFromOdsPostingGroupAuditId AS VARCHAR(50)) ELSE '' END	
	+ CHAR(13)+CHAR(10)+CHAR(9)

SET @SQLScript = CAST('' AS VARCHAR(MAX))+
 '
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

 IF EXISTS (SELECT Name FROM sys.indexes  WHERE Name = ''IDXPACHUpdateClaimantHeader'' 
    AND object_id = OBJECT_ID(''stg.ProviderDataExplorerClaimantHeader''))
  BEGIN
    DROP INDEX IDXPACHUpdateClaimantHeader ON stg.ProviderDataExplorerClaimantHeader;
  END
CREATE INDEX IDXPACHUpdateClaimantHeader ON stg.ProviderDataExplorerClaimantHeader (OdsCustomerId,ClaimantHdrIdNo);



IF EXISTS (SELECT Name FROM sys.indexes  WHERE Name = ''IDXPACHUpdateBillHeader'' 
    AND object_id = OBJECT_ID(''stg.ProviderDataExplorerBillHeader''))
  BEGIN
    DROP INDEX IDXPACHUpdateBillHeader ON stg.ProviderDataExplorerBillHeader;
  END
CREATE INDEX IDXPACHUpdateBillHeader ON stg.ProviderDataExplorerBillHeader (OdsCustomerId,ClaimantHdrIdNo,BillIdNo);


/*	Set ExceptionFlag as 1 with records having condition date_of_service is less than date_loss */
UPDATE bl 
	SET
	bl.ExceptionFlag = 1,
	ExceptionComments=''Date of service is less than date loss''	
FROM stg.ProviderDataExplorerBillLine bl
	     INNER JOIN stg.ProviderDataExplorerBillHeader bh ON bl.BillIdNo = bh.BillIdNo 
												AND bl.OdsCustomerId = bh.OdsCustomerId 												
		 INNER JOIN stg.ProviderDataExplorerClaimantHeader ch ON bh.ClaimantHdrIdNo = ch.ClaimantHdrIdNo 
											    AND bh.OdsCustomerId = ch.OdsCustomerId											   
												  
		 WHERE bl.DTSVC < ch.DateLoss  

/*	set exception_flag as 1 with records having condition Allowed amount is higher than charged amount. */
	
UPDATE stg.ProviderDataExplorerBillLine 
SET 
	ExceptionFlag=1,
	ExceptionComments=''Allowed amount is higher than charged amount.'' 

WHERE ISNULL(Allowed,0) > ISNULL(Charged,0);


/*	Set exception_flag as 1 where Duplicate records where identified with endnote as 4. */

IF OBJECT_ID(''tempdb..#DuplicateBillLines'') IS NOT NULL					
	DROP TABLE #DuplicateBillLines;

SELECT  ISNULL(Be.OdsCustomerId,bo.OdsCustomerId ) AS OdsCustomerId,
		ISNULL(Be.BillIDNo,bo.BillIDNo) as BillIdNo, 
		Isnull(be.LINE_NO,bo.Line_No) as Line_No
		
INTO #DuplicateBillLines
FROM '+@SourceDatabaseName+'.dbo.Bills_Pharm_Endnotes BE
FULL OUTER JOIN '+@SourceDatabaseName+'.dbo.Bills_Pharm_OverrideEndNotes BO ON Be.OdsCustomerId = BO.OdsCustomerId 
														AND BE.BillIDNo = BO.BillIDNo 
														AND BE.LINE_NO = BO.LINE_NO
WHERE BE.odscustomerid = '+ CONVERT(VARCHAR(10),@OdsCustomerId) +'
		AND (BO.OverrideEndNote = 4 OR (be.EndNote = 4 AND  BO.OverrideEndNote IS NULl))
		
UNION

  SELECT ISNULL(Be.OdsCustomerId,bo.OdsCustomerId ) AS OdsCustomerId,
		 ISNULL(Be.BillIDNo,bo.BillIDNo) AS BillIdNo, 
		 Isnull(be.LINE_NO,bo.Line_No) AS Line_No

FROM '+@SourceDatabaseName+'.dbo.Bills_EndNotes BE
FULL OUTER JOIN '+@SourceDatabaseName+'.dbo.Bills_OverrideEndNotes BO ON BE.OdsCustomerId = BO.OdsCustomerId 
																AND BE.BillIDNo = BO.BillIDNo 
																AND BE.LINE_NO = BO.LINE_NO
WHERE BE.OdsCustomerId = '+ CONVERT(VARCHAR(10),@OdsCustomerId)+' 
		AND (BO.OverrideEndNote = 4 OR (be.EndNote = 4 AND  BO.OverrideEndNotE IS NULL))

UNION

SELECT ISNULL(Be.OdsCustomerId,bo.OdsCustomerId ) AS OdsCustomerId,
		 ISNULL(Be.BillIDNo,bo.BillIDNo) AS BillIdNo, 
		 Isnull(be.LineNumber,bo.Line_No) AS Line_No

FROM stg.ProviderDataExplorerBillLine BE
Inner JOIN '+@SourceDatabaseName+'.dbo.Bills_OverrideEndNotes BO ON BE.OdsCustomerId = BO.OdsCustomerId 
																AND BE.BillIDNo = BO.BillIDNo 
																AND BE.LineNumber = BO.LINE_NO
WHERE BO.OdsCustomerId = '+ CONVERT(VARCHAR(10),@OdsCustomerId)+' 
		AND BO.OverrideEndNote = 4

UNION

  SELECT ISNULL(Be.OdsCustomerId,bo.OdsCustomerId ) AS OdsCustomerId,
		 ISNULL(Be.BillIDNo,bo.BillIDNo) AS BillIdNo, 
		 Isnull(be.LineNumber,bo.Line_No) AS Line_No

FROM stg.ProviderDataExplorerBillLine BE
Inner JOIN '+@SourceDatabaseName+'.dbo.Bills_Pharm_OverrideEndNotes BO ON BE.OdsCustomerId = BO.OdsCustomerId 
																AND BE.BillIDNo = BO.BillIDNo 
																AND BE.LineNumber = BO.LINE_NO
WHERE BO.OdsCustomerId = '+ CONVERT(VARCHAR(10),@OdsCustomerId)+' 
		AND BO.OverrideEndNote = 4


UPDATE b
SET 
	ExceptionFlag = 1,
	ExceptionComments  = ''Duplicate records identified with endnote as 4.''				
FROM stg.ProviderDataExplorerBillLine B 
INNER JOIN #DuplicateBillLines BE ON BE.BillIDNo = B.BillIdNo
								 AND BE.LINE_NO = B.LineNumber
		                         AND BE.OdsCustomerId = B.OdsCustomerId


		
/* Every claim first Date_of_Service should be last 24 months*/

IF OBJECT_ID(''tempdb..#DTSVC'') IS NOT NULL
         DROP TABLE #DTSVC;
  
BEGIN
	
IF OBJECT_ID(''tempdb..#DTSVC_Bills'') IS NOT NULL					
	DROP TABLE #DTSVC_Bills;			
	
CREATE TABLE #DTSVC_Bills
	(
	OdsCustomerId INT NOT NULL,	
	ClaimIDNo INT NOT NULL,
	BillIdNo INT NOT NULL,
	BillLineNo INT NOT NULL,
	DTSVC DATETIME

	CONSTRAINT PK_ProviderDataExplorerClaimsInScope PRIMARY KEY
			(						
				OdsCustomerId,
				ClaimIDNo,
				BillIdNo,
				BillLineNo
			)
		
	);

	INSERT INTO #DTSVC_Bills
	SELECT  ch.OdsCustomerId,
	        ch.ClaimIdNo,				
			b.BillIDNo,
			b.LINE_NO,
			b.DT_SVC
	FROM stg.ProviderDataExplorerClaimantHeader ch  
              INNER JOIN stg.ProviderDataExplorerBillHeader Bh ON ch.OdsCustomerId = bh.OdsCustomerId 	
														 AND ch.ClaimantHdrIdNo = bh.ClaimantHdrIdNo
			  INNER JOIN '+@SourceDatabaseName+'.dbo.BILLS b ON bh.OdsCustomerId = b.OdsCustomerId
																		 AND bh.BillIDNo = b.BillIDNo
																		 AND b.OdsCustomerId = '+ CONVERT(VARCHAR(10),@OdsCustomerId) +'
	

	IF EXISTS (SELECT Name FROM tempdb.sys.indexes  WHERE Name=''IDX_DTSVC_Bills_DT_SVC'' 
		  AND OBJECT_ID = OBJECT_ID(''tempdb..#DTSVC_Bills''))
		BEGIN
		  DROP INDEX IDX_DTSVC_Bills_DT_SVC ON #DTSVC_Bills;
		END
	CREATE INDEX IDX_DTSVC_Bills_DT_SVC ON #DTSVC_Bills(DTSVC);	
	
	SELECT 
		  C.OdsCustomerId,
		  C.ClaimIDNo
		  ,MIN(c.DTSVC ) MinDtsvc
		 INTO  #DTSVC
		From  #DTSVC_Bills c 
			  
	GROUP BY 						
			C.OdsCustomerId,
			C.ClaimIDNo;
END


IF OBJECT_ID(''tempdb..#DateOfService'') IS NOT NULL
           DROP TABLE #DateOfService ;
BEGIN
	SELECT 
		ch.OdsCustomerId,
		ch.ClaimIdNo,
		MIN(CAST(bl.DTSVC AS DATE)) MinDateOfService 
	INTO #DateOfService
	FROM
		 stg.ProviderDataExplorerBillLine bl 
	     INNER JOIN stg.ProviderDataExplorerBillHeader bh ON bl.BillIdNo = bh.BillIdNo 
												AND bl.OdsCustomerId = bh.OdsCustomerId 												
		 INNER JOIN stg.ProviderDataExplorerClaimantHeader ch ON bh.ClaimantHdrIdNo = ch.ClaimantHdrIdNo 
											    AND bh.OdsCustomerId = ch.OdsCustomerId
											    

GROUP BY 
		ch.OdsCustomerId,
		ch.ClaimIDNo;
END

/* take records which do not match from the above two temp tables */
IF OBJECT_ID(''tempdb..#ClaimLevelDataofService'') IS NOT NULL
        DROP TABLE #ClaimLevelDataofService;
BEGIN
SELECT 
		S.OdsCustomerId,
		S.ClaimIDNo,
		D.MinDtsvc,
		S.MinDateOfService 
	INTO #ClaimLevelDataofService  
FROM #DTSVC D INNER JOIN #DateOfService S ON D.OdsCustomerId = S.OdsCustomerId 
										AND D.ClaimIDNo = S.ClaimIDNo
										WHERE D.MinDtsvc <> S.MinDateOfService
					
END


UPDATE bl 
    SET
ExceptionFlag = 1,
ExceptionComments = ''Claim''''s with first date of sevice is < 24 months.''

FROM
	 stg.ProviderDataExplorerBillLine bl 
	     INNER JOIN stg.ProviderDataExplorerBillHeader bh ON bl.BillIdNo = bh.BillIdNo 
												AND bl.OdsCustomerId = bh.OdsCustomerId 												
		 INNER JOIN stg.ProviderDataExplorerClaimantHeader ch ON bh.ClaimantHdrIdNo = ch.ClaimantHdrIdNo 
											    AND bh.OdsCustomerId = ch.OdsCustomerId											    
    JOIN  #ClaimLevelDataofService D ON  D.ClaimIDNo = ch.ClaimIDNo 
												AND D.OdsCustomerId = ch.OdsCustomerId ;



IF OBJECT_ID(''stg.CustomerBillExclusionTemp'',''U'') IS NOT NULL					
	DROP TABLE stg.CustomerBillExclusionTemp;	

CREATE TABLE stg.CustomerBillExclusionTemp( 
			OdsCustomerId  INT NOT NULL,
			BillIdNo INT NOT NULL
			);

INSERT INTO stg.CustomerBillExclusionTemp
SELECT cus.CustomerId
	   ,ex.BillIdNo 	  
FROM '+@SourceDatabaseName+'.dbo.CustomerBillExclusion ex 
INNER JOIN '+@SourceDatabaseName+'.adm.Customer cus ON ex.Customer =cus.CustomerDatabase  
 '+@WhereClause + ' 
 
		   
/*Bundling Unbundling Script*/

UPDATE B 
  SET 
      B.BundlingFlag = -1

FROM stg.ProviderDataExplorerBillLine B 
WHERE EXISTS(
      SELECT 1  
	  FROM '+@SourceDatabaseName+'.dbo.BILLS_Endnotes BE 
	  WHERE BE.BillIDNo = B.BillIdNo
		AND BE.LINE_NO = B.LineNumber
		AND BE.OdsCustomerId = B.OdsCustomerId		
		AND BE.EndNote IN(10)
		AND BE.OdsCustomerId = '+ CONVERT(VARCHAR(10),@OdsCustomerId) +'
		)


UPDATE B
  SET 
      B.BundlingFlag = -2
FROM stg.ProviderDataExplorerBillLine B 
WHERE EXISTS(
      SELECT 1  
	  FROM '+@SourceDatabaseName+'.dbo.BILLS_Endnotes BE 
	  WHERE BE.BillIDNo = B.BillIdNo
		AND BE.LINE_NO = B.LineNumber
		AND BE.OdsCustomerId = B.OdsCustomerId		
		AND BE.EndNote IN(35)
		AND BE.OdsCustomerId = '+ CONVERT(VARCHAR(10),@OdsCustomerId) +'
		)

IF OBJECT_ID(''tempdb..#BillLineArchive'') IS NOT NULL
         DROP TABLE #BillLineArchive;
BEGIN
        
SELECT *
INTO #BillLineArchive
FROM stg.ProviderDataExplorerBillLine B 
WHERE BundlingFlag IN(-1, -2);

DELETE FROM stg.ProviderDataExplorerBillLine
WHERE BundlingFlag IN(-1, -2);

END


INSERT INTO stg.ProviderDataExplorerBillLine
SELECT 
		a.OdsPostingGroupAuditId,
		a.OdsCustomerId,
		a.BillIdNo,
		a.LineNumber,
		a.OverRide,
		a.DTSVC,
		a.PRCCD,
		a.Units,
		b.c,
		a.Allowed,
		a.Analyzed,
		a.RefLineNo,
		a.POSRevCode,
		ISNULL(b.c,0) - ISNULL(a.ALLOWED,0)  Adjustment, 
		a.FormType,
		a.CodeType,
		a.Code,
		a.ProviderZipOfService,
		a.BillLineType,
		a.ExceptionFlag,
		a.ExceptionComments,
		1 AS BundlingFlag,
		a.CodeDescription,
		a.CodeCategory,
		a.CodeSubCategory,
		a.IsCodeNumeric,
		a.SubFormType,
		a.BillInjuryDescription,	
		a.Modifier,
		a.EndNote,
		a.RunDate
		
       FROM #BillLineArchive a 
            INNER JOIN
       (
           SELECT bl.BillIdNo, 
                  bl.LineNumber, 
                  bl.OdsCustomerId,                  
                  SUM(isnull(ul.charged,0)) c
           FROM #BillLineArchive bl 
                LEFT JOIN #BillLineArchive ul ON ul.BillIdNo = bl.BillIdNo
                                                                     AND ul.RefLineNo = bl.LineNumber
                                                                     AND ul.BundlingFlag = -1
																	 AND ul.OdsCustomerId = bl.OdsCustomerId                                                                   
                                                                     
           WHERE bl.BundlingFlag = -2
           GROUP BY bl.BillIdNo, 
                    bl.LineNumber, 
                    bl.OdsCustomerId                   
       ) b ON a.BillIdNo = b.BillIdNo
              AND a.LineNumber = b.LineNumber
              AND a.OdsCustomerId = b.OdsCustomerId;


/*	Set exception_flag as 1 where Benefits exhausted records were identified with endnote as 202. Using BILLS_Endnotes, Bills_OverrideEndNotes,
	Bills_Pharm_Endnotes and Bills_Pharm_OverrideEndNotes tables */
		
UPDATE b
SET 
	ExceptionFlag = 1,
	ExceptionComments  = ''Benefits exhausted records identified with endnote as 202.''				
FROM stg.ProviderDataExplorerBillLine B 
WHERE EXISTS(
      SELECT 1  
	  FROM '+@SourceDatabaseName+'.dbo.BILLS_Endnotes BE 
	  WHERE BE.BillIDNo = B.BillIdNo
		AND BE.LINE_NO = B.LineNumber
		AND BE.OdsCustomerId = B.OdsCustomerId
		AND BE.EndNote = 202
		AND BE.OdsCustomerId = '+ CONVERT(VARCHAR(10),@OdsCustomerId) +'
		)

	
UPDATE b
SET 
	ExceptionFlag = 1,
	ExceptionComments  = ''Benefits exhausted records identified with endnote as 202.''			
FROM stg.ProviderDataExplorerBillLine B 
WHERE EXISTS(
      SELECT 1  
	  FROM '+@SourceDatabaseName+'.dbo.Bills_OverrideEndNotes BE 
	  WHERE BE.BillIDNo = B.BillIdNo
		AND BE.LINE_NO = B.LineNumber
		AND BE.OdsCustomerId = B.OdsCustomerId
		AND BE.OverrideEndNote = 202
		AND BE.OdsCustomerId = '+ CONVERT(VARCHAR(10),@OdsCustomerId) +'
		)

UPDATE b
SET 
	ExceptionFlag = 1,
	ExceptionComments  = ''Benefits exhausted records identified with endnote as 202.''			
FROM stg.ProviderDataExplorerBillLine B 
WHERE EXISTS(
      SELECT 1  
	  FROM '+@SourceDatabaseName+'.dbo.Bills_Pharm_Endnotes BE 
	  WHERE BE.BillIDNo = B.BillIdNo
		AND BE.LINE_NO = B.LineNumber
		AND BE.OdsCustomerId = B.OdsCustomerId
		AND BE.EndNote = 202
		AND BE.OdsCustomerId = '+ CONVERT(VARCHAR(10),@OdsCustomerId) +'
		)

UPDATE b
SET 
	ExceptionFlag = 1,
	ExceptionComments  = ''Benefits exhausted records identified with endnote as 202.''			
FROM stg.ProviderDataExplorerBillLine B 
WHERE EXISTS(
      SELECT 1  
	  FROM '+@SourceDatabaseName+'.dbo.Bills_Pharm_OverrideEndNotes BE 
	  WHERE BE.BillIDNo = B.BillIdNo
		AND BE.LINE_NO = B.LineNumber
		AND BE.OdsCustomerId = B.OdsCustomerId
		AND BE.OverrideEndNote = 202
		AND BE.OdsCustomerId = '+ CONVERT(VARCHAR(10),@OdsCustomerId) +'
		
		)


/* Add EndNote details in BillLine TABLE 
 Endnotes: found in multiple tables:
-BILLS_Endnotes.EndNote
-BILLS_CTG_Endnotes.Endnote
-Bills_OverrideEndnotes.OverrideEndNote
-Bills_Pharm_CTG_Endnotes.EndNote
-Bills_Pharm_Endnotes.EndNote
-Bills_Pharm_OverrideEndnotes.OverrideEndNote

We will fetch end note from individual tables into temporary table with multiple endNotes as comma separated values.
Then we will update our stg table by concatenating end noteds from all temporary tables.

If endnote is from BILLS_CTG_Endnotes or Bills_Pharm_CTG_Endnotes then prepend "C" to the endnote
If endnote is from Bills_OverideEndnotes or Bills_Pharm_OverrideEndnotes then prepend "X" to the endnote

 */

	-- Step 1 get EndNotes FROM BILLS_Endnotes

IF OBJECT_ID(''tempdb..#ben'') IS NOT NULL
	DROP TABLE #ben

	SELECT
		   b.OdsCustomerId
		   ,b.BillIDNo
		   ,LINE_NO
		   ,m.EndNote
	INTO #ben 
	FROM '+@SourceDatabaseName+'.src.BILLS_Endnotes m
	INNER JOIN stg.ProviderDataExplorerBillLine b ON m.OdsCustomerId = b.OdsCustomerId 
													AND b.BillIdNo=m.BillIDNo 
													AND b.LineNumber=m.LINE_NO
	WHERE b.OdsCustomerId='+ CONVERT(VARCHAR(10),@OdsCustomerId) +'


IF EXISTS(SELECT name 
			FROM tempdb.sys.indexes 
			WHERE name = N''IX_ben_BillIdNo_LineNo'' 
			AND OBJECT_ID = OBJECT_ID(''tempdb..#ben'')
		)
	DROP INDEX IX_ben_BillIdNo_LineNo ON #ben

	CREATE NONCLUSTERED INDEX IX_ben_BillIdNo_LineNo ON #ben(BillIdNo,Line_No)

-- Concatenate multiple endNote for same Line as comma separate values  

IF OBJECT_ID(''tempdb..#BillEndNotes'') IS NOT NULL
	DROP TABLE #BillEndNotes

	SELECT
		   OdsCustomerId
		   ,BillIDNo
		   ,LINE_NO
		   ,EndNotes = STUFF((
						  SELECT '','' + CAST(md.EndNote AS VARCHAR)
						  FROM #ben md
						  WHERE m.BillIDNo = md.BillIDNo
								AND m.LINE_NO = md.LINE_NO
						  FOR XML PATH(''''), TYPE).value(''.'', ''NVARCHAR(MAX)''), 1, 1, '''')
	INTO #BillEndNotes
	FROM #ben m


	-- Step 2 get EndNotes FROM BILLS_CTG_Endnotes

IF OBJECT_ID(''tempdb..#bcen'') IS NOT NULL
	DROP TABLE #bcen

	SELECT
		   b.OdsCustomerId
		   ,b.BillIDNo
		   ,LINE_NO
		   ,m.EndNote
	INTO #bcen 
	FROM '+@SourceDatabaseName+'.src.BILLS_CTG_Endnotes m
	INNER JOIN stg.ProviderDataExplorerBillLine b ON m.OdsCustomerId = b.OdsCustomerId 
													AND b.BillIdNo=m.BillIDNo 
													AND b.LineNumber=m.LINE_NO
	WHERE b.OdsCustomerId='+ CONVERT(VARCHAR(10),@OdsCustomerId) +'


IF EXISTS(SELECT name 
			FROM tempdb.sys.indexes 
			WHERE name = N''IX_bcen_BillIdNo_LineNo'' 
				AND OBJECT_ID = OBJECT_ID(''tempdb..#bcen'')
		)
	DROP INDEX IX_bcen_BillIdNo_LineNo ON #bcen

	CREATE NONCLUSTERED INDEX IX_bcen_BillIdNo_LineNo ON #bcen(BillIdNo,Line_No)

-- Concatenate multiple endNote for same Line as comma separate values and prepend C to every EndNote

IF OBJECT_ID(''tempdb..#BillCtgEndNotes'') IS NOT NULL
	DROP TABLE #BillCtgEndNotes

	SELECT
		   OdsCustomerId
		   ,BillIDNo
		   ,LINE_NO
		   ,EndNotes = STUFF((
			  SELECT '',C'' + CAST(md.EndNote AS VARCHAR)
			  FROM #bcen md
			  WHERE m.BillIDNo = md.BillIDNo
					AND m.LINE_NO = md.LINE_NO
			  FOR XML PATH(''''), TYPE).value(''.'', ''NVARCHAR(MAX)''), 1, 1, '''')
	INTO #BillCtgEndNotes
	FROM #bcen m


	-- Step 3 get EndNotes FROM Bills_OverrideEndnotes

IF OBJECT_ID(''tempdb..#boen'') IS NOT NULL
	DROP TABLE #boen

	SELECT
		   b.OdsCustomerId
		   ,b.BillIDNo
		   ,LINE_NO
		   ,m.OverrideEndNote
	INTO #boen 
	FROM '+@SourceDatabaseName+'.src.Bills_OverrideEndnotes m
	INNER JOIN stg.ProviderDataExplorerBillLine b ON m.OdsCustomerId = b.OdsCustomerId 
												AND b.BillIdNo=m.BillIDNo 
												AND b.LineNumber=m.LINE_NO
	WHERE b.OdsCustomerId='+ CONVERT(VARCHAR(10),@OdsCustomerId) +'


IF EXISTS(SELECT name 
			FROM tempdb.sys.indexes 
			WHERE name = N''IX_boen_BillIdNo_LineNo'' 
				AND OBJECT_ID = OBJECT_ID(''tempdb..#boen'')
		)
	DROP INDEX IX_boen_BillIdNo_LineNo ON #boen

	CREATE NONCLUSTERED INDEX IX_boen_BillIdNo_LineNo ON #boen(BillIdNo,Line_No)

-- Concatenate multiple endNote for same Line as comma separate values and prepend X to every EndNote

IF OBJECT_ID(''tempdb..#BillOverrideEndNotes'') IS NOT NULL
	DROP TABLE #BillOverrideEndNotes

	SELECT
		   OdsCustomerId
		   ,BillIDNo
		   ,LINE_NO
		   ,EndNotes = STUFF((
			  SELECT '',X'' + CAST(md.OverrideEndNote AS VARCHAR)
			  FROM #boen md
			  WHERE m.BillIDNo = md.BillIDNo
					AND m.LINE_NO = md.LINE_NO
			  FOR XML PATH(''''), TYPE).value(''.'', ''NVARCHAR(MAX)''), 1, 1, '''')
	INTO #BillOverrideEndNotes
	FROM #boen m

	--Step 4  get EndNotes FROM Bills_Pharm_Endnotes

	IF OBJECT_ID(''tempdb..#bpen'') IS NOT NULL
	DROP TABLE #bpen

	SELECT
		   b.OdsCustomerId
		   ,b.BillIDNo
		   ,LINE_NO
		   ,m.EndNote
	INTO #bpen 
	FROM '+@SourceDatabaseName+'.src.Bills_Pharm_Endnotes m
	INNER JOIN stg.ProviderDataExplorerBillLine b ON m.OdsCustomerId = b.OdsCustomerId 
													AND b.BillIdNo=m.BillIDNo 
													AND b.LineNumber=m.LINE_NO
	WHERE b.OdsCustomerId='+ CONVERT(VARCHAR(10),@OdsCustomerId) +'


IF EXISTS(SELECT name 
			FROM tempdb.sys.indexes 
			WHERE name = N''IX_bpen_BillIdNo_LineNo'' 
				AND OBJECT_ID = OBJECT_ID(''tempdb..#bpen'')
		)
	DROP INDEX IX_bpen_BillIdNo_LineNo ON #bpen

	CREATE NONCLUSTERED INDEX IX_bpen_BillIdNo_LineNo ON #bpen(BillIdNo,Line_No)

-- Concatenate multiple endNote for same Line as comma separate values 

IF OBJECT_ID(''tempdb..#BillPharmaEndNotes'') IS NOT NULL
	DROP TABLE #BillPharmaEndNotes

	SELECT
		   OdsCustomerId
		   ,BillIDNo
		   ,LINE_NO
		   ,EndNotes = STUFF((
			  SELECT '','' + CAST(md.EndNote AS VARCHAR)
			  FROM #bpen md
			  WHERE m.BillIDNo = md.BillIDNo
					AND m.LINE_NO = md.LINE_NO
			  FOR XML PATH(''''), TYPE).value(''.'', ''NVARCHAR(MAX)''), 1, 1, '''')
	INTO #BillPharmaEndNotes
	FROM #bpen m


	-- Step 5 get EndNotes FROM Bills_Pharm_CTG_Endnotes

IF OBJECT_ID(''tempdb..#bpcen'') IS NOT NULL
	DROP TABLE #bpcen

	SELECT
		   b.OdsCustomerId
		   ,b.BillIDNo
		   ,LINE_NO
		   ,m.EndNote
	INTO #bpcen 
	FROM '+@SourceDatabaseName+'.src.Bills_Pharm_CTG_Endnotes m
	INNER JOIN stg.ProviderDataExplorerBillLine b ON m.OdsCustomerId = b.OdsCustomerId 
													AND b.BillIdNo=m.BillIDNo 
													AND b.LineNumber=m.LINE_NO
	WHERE b.OdsCustomerId='+ CONVERT(VARCHAR(10),@OdsCustomerId) +'


IF EXISTS(SELECT name 
			FROM tempdb.sys.indexes 
			WHERE name = N''IX_bpcen_BillIdNo_LineNo'' 
				AND OBJECT_ID = OBJECT_ID(''tempdb..#bpcen'')
		)
	DROP INDEX IX_bpcen_BillIdNo_LineNo ON #bpcen

	CREATE NONCLUSTERED INDEX IX_bpcen_BillIdNo_LineNo ON #bpcen(BillIdNo,Line_No)

-- Concatenate multiple endNote for same Line as comma separate values and prepend C to every EndNote

IF OBJECT_ID(''tempdb..#BillPharmaCtgEndNotes'') IS NOT NULL
	DROP TABLE #BillPharmaCtgEndNotes

	SELECT
		   OdsCustomerId
		   ,BillIDNo
		   ,LINE_NO
		   ,EndNotes = STUFF((
			  SELECT '',C'' + CAST(md.EndNote AS VARCHAR)
			  FROM #bpcen md
			  WHERE m.BillIDNo = md.BillIDNo
					AND m.LINE_NO = md.LINE_NO
			  FOR XML PATH(''''), TYPE).value(''.'', ''NVARCHAR(MAX)''), 1, 1, '''')
	INTO #BillPharmaCtgEndNotes
	FROM #bpcen m


	-- Step 6 get EndNotes FROM Bills_Pharm_OverrideEndnotes

	IF OBJECT_ID(''tempdb..#bpoen'') IS NOT NULL
	DROP TABLE #bpoen

	SELECT
		   b.OdsCustomerId
		   ,b.BillIDNo
		   ,LINE_NO
		   ,m.OverrideEndNote
	INTO #bpoen 
	FROM '+@SourceDatabaseName+'.src.Bills_Pharm_OverrideEndnotes m
	INNER JOIN stg.ProviderDataExplorerBillLine b ON m.OdsCustomerId = b.OdsCustomerId 
													AND b.BillIdNo=m.BillIDNo 
													AND b.LineNumber=m.LINE_NO
	WHERE b.OdsCustomerId='+ CONVERT(VARCHAR(10),@OdsCustomerId) +'


IF EXISTS(SELECT name 
			FROM tempdb.sys.indexes 
			WHERE name = N''IX_bpoen_BillIdNo_LineNo'' 
				AND OBJECT_ID = OBJECT_ID(''tempdb..#bpoen'')
		)
	DROP INDEX IX_bpoen_BillIdNo_LineNo ON #bpoen

	CREATE NONCLUSTERED INDEX IX_bpoen_BillIdNo_LineNo ON #bpoen(BillIdNo,Line_No)

-- Concatenate multiple endNote for same Line as comma separate values and prepend X to every EndNote

IF OBJECT_ID(''tempdb..#BillPharmaOverrideEndNotes'') IS NOT NULL
	DROP TABLE #BillPharmaOverrideEndNotes

	SELECT
		   OdsCustomerId
		   ,BillIDNo
		   ,LINE_NO
		   ,EndNotes = STUFF((
			  SELECT '',X'' + CAST(md.OverrideEndNote AS VARCHAR)
			  FROM #bpoen md
			  WHERE m.BillIDNo = md.BillIDNo
					AND m.LINE_NO = md.LINE_NO
			  FOR XML PATH(''''), TYPE).value(''.'', ''NVARCHAR(MAX)''), 1, 1, '''')
	INTO #BillPharmaOverrideEndNotes
	FROM #bpoen m

--Concatenate all EndNote from different tables as comma separated.

	UPDATE b
	SET b.EndNote = ISNULL(be.EndNotes ,'''')
					+ISNULL('',''+bce.EndNotes ,'''')
					+ISNULL('',''+boe.EndNotes ,'''')
					+ISNULL('',''+bpe.EndNotes ,'''')
					+ISNULL('',''+bpce.EndNotes,'''')
					+ISNULL('',''+bpoe.EndNotes,'''')
	FROM stg.ProviderDataExplorerBillLine b
	LEFT JOIN #BillEndNotes be ON b.OdsCustomerId=be.OdsCustomerId 
								AND b.BillIdNo=be.BillIDNo
								AND b.LineNumber = be.LINE_NO
	LEFT JOIN #BillCtgEndNotes bce ON b.OdsCustomerId=bce.OdsCustomerId 
								AND b.BillIdNo=bce.BillIDNo
								AND b.LineNumber = bce.LINE_NO
	LEFT JOIN #BillOverrideEndNotes boe ON b.OdsCustomerId=boe.OdsCustomerId 
								AND b.BillIdNo=boe.BillIDNo
								AND b.LineNumber = boe.LINE_NO
	LEFT JOIN #BillPharmaEndNotes bpe ON b.OdsCustomerId=bpe.OdsCustomerId 
								AND b.BillIdNo=bpe.BillIDNo
								AND b.LineNumber = bpe.LINE_NO
	LEFT JOIN #BillPharmaCtgEndNotes bpce ON b.OdsCustomerId=bpce.OdsCustomerId 
								AND b.BillIdNo=bpce.BillIDNo
								AND b.LineNumber = bpce.LINE_NO
	LEFT JOIN #BillPharmaOverrideEndNotes bpoe ON b.OdsCustomerId=bpoe.OdsCustomerId 
								AND b.BillIdNo=bpoe.BillIDNo
								AND b.LineNumber = bpoe.LINE_NO

-- If first table do not have any EndNote, then remove leading comma

	UPDATE b
	SET EndNote = RIGHT(EndNote,len(endnote)-1)
	FROM stg.ProviderDataExplorerBillLine b 
	WHERE OdsCustomerId='+ CONVERT(VARCHAR(10),@OdsCustomerId) +' 
		AND EndNote LIKE '',%''


/* Exclude bill lines with feature date of service. Using Adm.ReportParameters.EndDate.*/
DECLARE @ODSPAEndDate DATETIME
SELECT @ODSPAEndDate = ParameterValue FROM  adm.ReportParameters WHERE ReportId = '+ CONVERT(VARCHAR(10),@ReportId) +'  
			AND ParameterName = ''ODSPAEndDate''

UPDATE b
	SET ExceptionFlag = 1,
		ExceptionComments =''Exclude Bill Lines with future date of service.''
FROM stg.ProviderDataExplorerBillLine b 
	WHERE OdsCustomerId ='+ CONVERT(VARCHAR(10),@OdsCustomerId) +' 
		AND DTSVC > @ODSPAEndDate

		 
		 
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

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderAnalyticsUpdateProviderClusterName') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderAnalyticsUpdateProviderClusterName
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerUpdateProviderClusterName') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerUpdateProviderClusterName
GO

CREATE PROCEDURE dbo.ProviderDataExplorerUpdateProviderClusterName(
@SourceDatabaseName VARCHAR(50),
@Debug BIT,
@ReportId INT
)
AS
BEGIN

DECLARE @OdsPostingGroupAuditId INT = 0,
		@ProcessName VARCHAR(50),
		@OdsCustomerId INT = 0,
		@AuditFor VARCHAR(100);


-- Track the Audit for Customer
SET @AuditFor = 'OdsCustomerId : '+CAST(0 AS VARCHAR(3));

-- Get the Process Name
SET @ProcessName = ( SELECT OBJECT_NAME(@@PROCID) );


-- Tracking Process start in ETL Audit
EXEC dbo.ProviderDataExplorerEtlAuditStart @AuditFor,@ProcessName,@OdsPostingGroupAuditId,@ReportId;

DECLARE @SQLScript VARCHAR(MAX);				

SET @SQLScript = CAST('' as VARCHAR(MAX)) + '

------------------STEP:1

IF OBJECT_ID(''tempdb..#ProviderClusterName'') IS NOT NULL 
		DROP TABLE #ProviderClusterName;

-- Mitigate Blank Cluster Names based on all customers Which occure the maximum number.

SELECT 
CASE WHEN LEN(LTRIM(RTRIM(ISNULL(a.ProviderClusterKey,'''')))) > 0 THEN

     CASE WHEN a.ProviderType = ''G'' THEN
                CASE WHEN LEN(LTRIM(RTRIM(b.PvdGroup))) > 0 THEN LTRIM(RTRIM(UPPER(b.PvdGroup))) 
				     ELSE LTRIM(RTRIM(UPPER(b.PvdFirstName))) + '' '' + LTRIM(RTRIM(UPPER(b.PvdLastName)))
                END 
          ELSE
                CASE WHEN LEN(LTRIM(RTRIM(b.PvdFirstName))) > 0 THEN  LTRIM(RTRIM(UPPER(b.PvdFirstName))) + '' '' + LTRIM(RTRIM(UPPER(b.PvdLastName))) 
					 ELSE LTRIM(RTRIM(UPPER(b.PvdGroup)))
                END       

          END

 ELSE
              ''Unclustered''

END AS ProviderClusterName
, a.ProviderClusterKey
, COUNT(1) AS RecCnt

INTO #ProviderClusterName
FROM '+@SourceDatabaseName+'.dbo.ProviderCluster AS a
INNER JOIN '+@SourceDatabaseName+'.dbo.PROVIDER AS b ON a.OrgOdsCustomerId = b.OdsCustomerId													
												  AND a.PvdIDNo = b.PvdIDNo
GROUP BY
CASE WHEN LEN(LTRIM(RTRIM(ISNULL(a.ProviderClusterKey,'''')))) > 0 THEN

     CASE WHEN a.ProviderType = ''G'' THEN
                CASE WHEN LEN(LTRIM(RTRIM(b.PvdGroup))) > 0 THEN LTRIM(RTRIM(UPPER(b.PvdGroup))) 
				     ELSE LTRIM(RTRIM(UPPER(b.PvdFirstName))) + '' '' + LTRIM(RTRIM(UPPER(b.PvdLastName)))
                END 
          ELSE
                CASE WHEN LEN(LTRIM(RTRIM(b.PvdFirstName))) > 0 THEN  LTRIM(RTRIM(UPPER(b.PvdFirstName))) + '' '' + LTRIM(RTRIM(UPPER(b.PvdLastName))) 
					 ELSE LTRIM(RTRIM(UPPER(b.PvdGroup)))
                END       

          END

 ELSE
               ''Unclustered''
END 
		, a.ProviderClusterKey
 ;
 

IF OBJECT_ID(''tempdb..#CalculateProviderCluster'') IS NOT NULL 
		DROP TABLE #CalculateProviderCluster
 
;WITH MaxProviderCluster AS (
SELECT ProviderClusterName,
		ProviderClusterKey,
		RecCnt,
		ROW_NUMBER() OVER(PARTITION BY ProviderClusterKey ORDER BY  RecCnt DESC, ProviderClusterName) AS RowNumber  
	FROM  #ProviderClusterName 
 
 )
 SELECT 
		p.ProviderClusterName,
		m.ProviderClusterKey
 INTO #CalculateProviderCluster 
 FROM MaxProviderCluster m  
 INNER JOIN #ProviderClusterName p ON m.ProviderClusterKey = p.ProviderClusterKey 
								  AND p.ProviderClusterName = m.ProviderClusterName
								  AND p.RecCnt = m.RecCnt 
 WHERE m.RowNumber = 1
 
 
 ------------------------------STEP :2 /* Load provider with adderss , tin and npi details based on ClusterID level. */
 
IF OBJECT_ID(''tempdb..#ProviderName'') IS NOT NULL 
		DROP TABLE #ProviderName;

SELECT 
CASE WHEN LEN(LTRIM(RTRIM(ISNULL(a.ProviderClusterKey,'''')))) > 0 THEN

    CASE WHEN a.ProviderType = ''G'' THEN
                CASE WHEN LEN(LTRIM(RTRIM(b.PvdGroup))) > 0 THEN LTRIM(RTRIM(UPPER(b.PvdGroup))) 
				     ELSE LTRIM(RTRIM(UPPER(b.PvdFirstName))) + '' '' + LTRIM(RTRIM(UPPER(b.PvdLastName)))
                END 
          ELSE
                CASE WHEN LEN(LTRIM(RTRIM(b.PvdFirstName))) > 0 THEN  LTRIM(RTRIM(UPPER(b.PvdFirstName))) + '' '' + LTRIM(RTRIM(UPPER(b.PvdLastName))) 
					 ELSE LTRIM(RTRIM(UPPER(b.PvdGroup)))
                END 

          END

 ELSE
              Null

END AS ProviderName
,LTRIM(RTRIM(UPPER(ISNULL(b.PvdState,''''))))  State
,LTRIM(RTRIM(UPPER(ISNULL(b.PvdAddr1,''''))))  Address
,LTRIM(RTRIM(LEFT(ISNULL(b.PvdZip,''''),5))) Zip
,ISNULL(LTRIM(RTRIM(b.PvdTIN)),'''') Tin
,ISNULL(LTRIM(RTRIM(b.PvdNPINo)),'''') NPI
, a.ProviderClusterKey

INTO #ProviderName
FROM '+@SourceDatabaseName+'.dbo.ProviderCluster AS a
INNER JOIN '+@SourceDatabaseName+'.dbo.PROVIDER AS b ON a.OrgOdsCustomerId = b.OdsCustomerId
										 	AND a.PvdIDNo = b.PvdIDNo ;

 
 ---------STEP 4 Get the most frequently occured address , tin and npi

  IF OBJECT_ID(''tempdb..#MaxRankDetails'') IS NOT NULL 
		DROP TABLE #MaxRankDetails;
 
;WITH MaxClusterName AS (
				SELECT  				
				Providerclusterkey 
				,State 
				,Zip
				,Address
				,Tin
				,NPI
				,DENSE_RANK() OVER(PARTITION BY Providerclusterkey ORDER BY Providerclusterkey,State,Zip,Address) Rnk    
			FROM #ProviderName 
 
 ),
RnkRownumber AS(
			SELECT 				
				m.Providerclusterkey 
				,m.State 
				,m.Zip
				,m.Address
				,m.Tin
				,m.NPI
				,m.Rnk				
				,ROW_NUMBER() OVER(PARTITION BY Rnk,Providerclusterkey ORDER BY Providerclusterkey) RowNumber
				,ROW_NUMBER() OVER(PARTITION BY Tin,Providerclusterkey ORDER BY Providerclusterkey,Tin ) TinRnk 
				,CASE WHEN LEN(LTRIM(RTRIM(ISNULL(NPI,'''') ))) > 0 THEN  ROW_NUMBER() OVER(PARTITION BY Npi,Providerclusterkey ORDER BY Providerclusterkey,Npi ) ELSE '''' END  NpiRnk 
			FROM MaxClusterName m  
              ) SELECT * INTO #MaxRankDetails FROM RnkRownumber ; 
  

------Find most frequently occurred adress(state , zip , address) within the clusterid


 IF OBJECT_ID(''tempdb..#ProviderClusterAddress'') IS NOT NULL 
		DROP TABLE #ProviderClusterAddress;
		
;WITH MaxRowNumber AS(
			 SELECT 
					  Providerclusterkey
					  ,MAX(RowNumber) MaxCnt									  
				FROM #MaxRankDetails
				GROUP BY Providerclusterkey
				)
			 SELECT
					A.Providerclusterkey ,
					MAX( b.State) State ,
					MAX( b.Zip) Zip, 
					MAX( b.Address) Address 
			 INTO #ProviderClusterAddress
			 FROM #MaxRankDetails b  
			 INNER JOIN  MaxRowNumber A ON A.ProviderClusterKey = b.ProviderClusterKey 					 
									               AND A.MaxCnt = b.RowNumber
			GROUP BY 
					  A.Providerclusterkey 

					  
------Find most frequently occurred Tin within the clusterid

 IF OBJECT_ID(''tempdb..#ProviderClusterTin'') IS NOT NULL 
		DROP TABLE #ProviderClusterTin;
		
;WITH MaxTin AS(
				SELECT
					  Providerclusterkey
					  ,MAX(TinRnk) MaxTin									  
				FROM #MaxRankDetails
				GROUP BY Providerclusterkey
				)
		 SELECT
				A.Providerclusterkey ,
				MAX( b.Tin) Tin 
		 INTO #ProviderClusterTin
		 FROM #MaxRankDetails b  
		 INNER JOIN  MaxTin A ON A.ProviderClusterKey = b.ProviderClusterKey 						
								         AND A.MaxTin = b.TinRnk
		GROUP BY  A.Providerclusterkey 


------Find most frequently occurred NPI within the clusterid

 IF OBJECT_ID(''tempdb..#ProviderClusterNPI'') IS NOT NULL 
		DROP TABLE #ProviderClusterNPI;
		
 ;WITH MaxNPI AS(
				SELECT Providerclusterkey
					  ,MAX(NpiRnk) MaxNpi									  
				FROM #MaxRankDetails
				GROUP BY Providerclusterkey
				)
				SELECT				
					A.Providerclusterkey ,
					MAX( b.Npi) NPI 
			    INTO #ProviderClusterNPI
 FROM #MaxRankDetails b  
 INNER JOIN  MaxNPI A ON A.ProviderClusterKey = b.ProviderClusterKey 						  
						         AND A.MaxNpi = b.NpiRnk
  GROUP BY  A.Providerclusterkey 

-----Update ProviderClusterName with New providerClusterName.
UPDATE P 
	SET 
		p.ProviderClusterName = Pc.ProviderClusterName +'' | ''+ State +'' | ''+Zip+'' | ''+Address+'' | ''+Tin+'' | ''+NPI 
 FROM dbo.ProviderDataExplorerProvider p 
 INNER JOIN #CalculateProviderCluster pc ON P.ProviderClusterId = pc.ProviderClusterKey 
 INNER JOIN #ProviderClusterAddress A ON Pc.ProviderClusterKey = A.ProviderClusterKey
 INNER JOIN #ProviderClusterTin B ON A.ProviderClusterKey = B.ProviderClusterKey
 INNER JOIN #ProviderClusterNPI C ON B.ProviderClusterKey = C.ProviderClusterKey ;



  UPDATE 
        dbo.ProviderDataExplorerProvider 
        SET 
		ProviderClusterName = ''Unclustered''		
	WHERE LEN(LTRIM(RTRIM(ISNULL(ProviderClusterId,'''')))) = 0 ;

	'
-- Script generates when debug mode is on 
IF (@Debug = 1)
BEGIN
	PRINT @AuditFor;	
	PRINT @ProcessName;
	PRINT(@SQLScript);

END

EXEC(@SQLScript);

-- Tracking Process end in ETL Audit
EXEC dbo.ProviderDataExplorerEtlAuditEnd @AuditFor,@ProcessName,@OdsPostingGroupAuditId,@ReportId;

END

GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.SelfServePerformanceReport_Operations_Output') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SelfServePerformanceReport_Operations_Output
GO

CREATE PROCEDURE dbo.SelfServePerformanceReport_Operations_Output(
@SourceDatabaseName VARCHAR(50)='AcsOds',
@StartDate AS DATETIME,
@EndDate AS DATETIME,
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 0,
@TargetDatabaseName VARCHAR(50) = 'ReportDB')
AS
BEGIN
--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOdsFK',@RunType INT = 0,@if_Date AS DATETIME = GETDATE(), @OdsCustomerID INT = 19 , @TargetDatabaseName VARCHAR(50) = 'ReportDB_FK',@StartDate AS DATETIME = '20190201',@EndDate AS DATETIME = '20200229'

DECLARE @SQLScript VARCHAR(MAX);

SET @SQLScript = '
DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;

'+CASE WHEN @OdsCustomerID <> 0 THEN 
'DELETE FROM '+@TargetDatabaseName+'.dbo.SelfServePerformanceReport_Operations
WHERE OdsCustomerId = '+CAST(@OdsCustomerID as VARCHAR(5))+';' ELSE 

'TRUNCATE TABLE '+@TargetDatabaseName+'.dbo.SelfServePerformanceReport_Operations;' END+'

IF OBJECT_ID(''tempdb..#MitchellCompleteDateClaimants'') IS NOT NULL DROP TABLE #MitchellCompleteDateClaimants;
-- Get MitchellCompleteDate Claimants
SELECT DISTINCT OdsCustomerId, CmtIdNo 
			 ,CASE  WHEN UDFIdNo = ''-3'' THEN UDFValueDate END AS ''1stNurseCompleteDate''
			 ,CASE  WHEN UDFIdNo = ''-4'' THEN UDFValueDate END AS ''2ndNurseCompleteDate''
			 ,CASE  WHEN UDFIdNo = ''-5'' THEN UDFValueDate END AS ''3rdNurseCompleteDate''
INTO #MitchellCompleteDateClaimants
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'UDFClaimant' ELSE'if_UDFClaimant(@RunPostingGroupAuditId)' END+'
WHERE UDFIdNo  IN (''-3'',''-4'',''-5'') AND UDFValueDate <> ''1899-12-30 00:00:00.000'' '+
CASE WHEN @OdsCustomerId <> 0 THEN CHAR(13)+CHAR(10)+CHAR(9)+'AND OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +'

IF OBJECT_ID(''tempdb..#MitchellRecievedeDate'') IS NOT NULL DROP TABLE #MitchellRecievedeDate;
-- Get MitchellRecievedDate 
SELECT DISTINCT OdsCustomerId, BillIdNo 
			 ,CASE  WHEN UDFIdNo = ''-1'' THEN UDFValueDate END AS ''MitchellReceivedDate''
INTO #MitchellRecievedeDate
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'UDFBill' ELSE'if_UDFBill(@RunPostingGroupAuditId)' END+'
WHERE UDFIdNo  IN (''-1'') '+
CASE WHEN @OdsCustomerId <> 0 THEN CHAR(13)+CHAR(10)+CHAR(9)+'AND OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +'

-- Get Bills Sent and Recieved Dates 
IF OBJECT_ID(''tempdb..#EventLog'') IS NOT NULL DROP TABLE #EventLog
SELECT   OdsCustomerId
		,BillIdNo
		,CASE WHEN EventId = 11 THEN LogDate END AS ''BillsSentToPPODate''
        ,CASE WHEN EventId = 10 THEN LogDate END AS ''BillsReceivedFromPPODate''
INTO #EventLog
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'ProviderNetworkEventLog' ELSE'if_ProviderNetworkEventLog(@RunPostingGroupAuditId)' END+'
WHERE EventId IN (10,11)'+
CASE WHEN @OdsCustomerId <> 0 THEN CHAR(13)+CHAR(10)+CHAR(9)+'AND OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +'
	
-- Get Bill Committed Date
IF OBJECT_ID(''tempdb..#Bill_History'') IS NOT NULL DROP TABLE #Bill_History
SELECT bhs.OdsCustomerId
	,bhs.billIDNo
	,max(bhs.DateCommitted) as DateCommitted 
INTO #Bill_History
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Bill_History' ELSE 'if_Bill_History(@RunPostingGroupAuditId)' END+ ' bhs
'+CASE WHEN @OdsCustomerId <> 0 THEN 'WHERE bhs.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +' 
GROUP BY bhs.OdsCustomerId
	,bhs.billIDNo; 

-- Get BillIdNo 
IF OBJECT_ID(''tempdb..#BILL_HDR'') IS NOT NULL DROP TABLE #BILL_HDR
SELECT DISTINCT
	 BH.OdsCustomerId
	,BH.BillIDNo
	,BH.CreateDate
	,BH.CMT_HDR_IDNo
	,bhs.DateCommitted 
	,CASE WHEN BH.DateRcv = ''1899-12-30 00:00:00.000'' THEN NULL ELSE  BH.DateRcv END AS DateRcv
	,CASE WHEN BH.Flags & 4096 = 4096 THEN ''UB-04''  ELSE ''CMS-1500''  END AS BillType
INTO #BILL_HDR
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BILL_HDR' ELSE 'if_BILL_HDR(@RunPostingGroupAuditId)' END +' BH
LEFT OUTER JOIN #Bill_History bhs ON BH.OdsCustomerId = bhs.OdsCustomerId 
	AND BH.BillIDNo = bhs.BillIDNo 
WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN 'BH.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) + ' AND ' ELSE '' END +'
        CONVERT(VARCHAR(10),BH.CreateDate,112) BETWEEN '''+CONVERT(VARCHAR(10),@StartDate,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+'''


-- Insert the result to the Output table
INSERT INTO dbo.SelfServePerformanceReport_Operations(
	   OdsCustomerId
      ,Company
	  ,OfficeName
      ,SOJ
      ,BillID
	  ,BillCreateDate
      ,BillCommitDate
	  ,CarrierReceivedDate
	  ,MitchellReceivedDate
      ,BillLine
      ,OverrideDateTime
      ,UserId
      ,AdjustorId
      ,OfficeIdNo
      ,BillType
      ,[1stNurseCompleteDate]
      ,[2ndNurseCompleteDate]
      ,[3rdNurseCompleteDate]
	  ,BillsSentToPPODate
      ,BillsReceivedFromPPODate
)
SELECT DISTINCT 
		 BH.OdsCustomerId                 
		,ISNULL(CO.CompanyName, ''NA'')
		,ISNULL(O.OfcName , ''NA'') 
		,CM.CmtStateOfJurisdiction     
		,BH.BillIDNo
		,BH.CreateDate
		,BH.DateCommitted 
		,BH.DateRcv
		,CASE WHEN MRD.MitchellReceivedDate = ''1899-12-30 00:00:00.000'' THEN NULL ELSE MRD.MitchellReceivedDate END AS MitchellReceivedDate            					
		,B.LINE_NO                      
		,BO.DateSaved
		,BO.UserId
		,AD.lAdjIdNo					
		,AD.OfficeIdNo						
		,BH.BillType
		,MCD.[1stNurseCompleteDate]
		,MCD.[2ndNurseCompleteDate]
		,MCD.[3rdNurseCompleteDate]
		,E.BillsSentToPPODate
		,E.BillsReceivedFromPPODate

FROM #BILL_HDR BH  
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CMT_HDR' ELSE'if_CMT_HDR(@RunPostingGroupAuditId)' END+' CH 
	ON BH.OdsCustomerId = CH.OdsCustomerId
	AND BH.CMT_HDR_IDNo = CH.CMT_HDR_IDNo
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CLAIMANT' ELSE'if_CLAIMANT(@RunPostingGroupAuditId)' END+' CM 
	ON CH.OdsCustomerId = CM.OdsCustomerId
	AND CH.CmtIDNo = CM.CmtIDNo 
INNER JOIN (SELECT
				 OdsCustomerId 
				,BillIDNo
				,LINE_NO_DISP
				,LINE_NO
				,1 AS LineType
			FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BILLS' ELSE'if_BILLS(@RunPostingGroupAuditId)' END+' 
			WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN 'OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ' ELSE '' END +'CHARGED IS NOT NULL
			UNION 
			SELECT 
				 OdsCustomerId
				,BillIDNo
				,LINE_NO_DISP
				,LINE_NO
				,2 AS LineType
			FROM  '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BILLS_Pharm' ELSE'if_BILLS_Pharm(@RunPostingGroupAuditId)' END+'
			WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN 'OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ' ELSE '' END +'CHARGED IS NOT NULL
			) AS B
	ON BH.OdsCustomerId = B.OdsCustomerId
	AND BH.BillIDNo = B.BillIDNo
LEFT OUTER JOIN #MitchellCompleteDateClaimants MCD  
	ON CM.OdsCustomerId = MCD.OdsCustomerId
	AND CM.CmtIDNo = MCD.CmtIDNo
LEFT OUTER JOIN #MitchellRecievedeDate MRD
	ON MRD.OdsCustomerId = BH.OdsCustomerId
	AND MRD.BillIDNo = BH.BillIDNo
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BillsOverride' ELSE'if_BillsOverride(@RunPostingGroupAuditId)' END+' BO
	ON BO.OdsCustomerId = B.OdsCustomerId
	AND BO.BillIDNo = B.BillIDNo
	AND BO.Line_NO = B.LINE_NO
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Adjustor' ELSE'if_Adjustor(@RunPostingGroupAuditId)' END+' AD
	ON AD.OdsCustomerId = BO.OdsCustomerId
	AND AD.UserId = BO.UserId
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'prf_Office' ELSE'if_prf_Office(@RunPostingGroupAuditId)' END+' O
	ON O.OdsCustomerId = AD.OdsCustomerId
	AND O.OfficeID = AD.OfficeIdNo
	AND O.OfcName NOT LIKE ''%TEST%''
	AND O.OfcName NOT LIKE ''%TRAIN%''
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'prf_COMPANY' ELSE'if_prf_COMPANY(@RunPostingGroupAuditId)' END+' CO 
	ON CO.OdsCustomerId = O.OdsCustomerId
	AND CO.CompanyId = O.CompanyId
	AND CO.CompanyName NOT LIKE ''%TEST%''
	AND CO.CompanyName NOT LIKE ''%TRAIN%''
LEFT OUTER JOIN   #EventLog E 
	ON BH.OdsCustomerId = E.OdsCustomerId 
	AND BH.BillIDNo = E.BillIDNo 		
'

EXEC(@SQLScript);


END


GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.SelfServePerformanceReport_Savings_Adjustments') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SelfServePerformanceReport_Savings_Adjustments
GO


CREATE PROCEDURE dbo.SelfServePerformanceReport_Savings_Adjustments(
@SourceDatabaseName VARCHAR(50)='AcsOdsFK',
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerID INT = 0)
AS
BEGIN

---DECLARE @SourceDatabaseName VARCHAR(50)='AcsOdsFK',@RunType INT = 0,@if_Date AS DATETIME = GETDATE(),@OdsCustomerID INT = 19
DECLARE  @SQLScript VARCHAR(MAX);

SET @SQLScript = '
DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;

'+CHAR(13)+CHAR(10)+
-- Clean up stsging table for adjustments
CASE WHEN @OdsCustomerID <> 0 THEN 'DELETE FROM stg.SelfServePerformanceReport_Savings_Adjustments WHERE OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(5))+';'
ELSE 'TRUNCATE TABLE stg.SelfServePerformanceReport_Savings_Adjustments;' END +'

-- Insert Adjustments data into staging table
;WITH cte_Rsn_Override AS ( 
SELECT OdsCustomerId,
	   ReasonNumber,
       ShortDesc,
       LongDesc
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Rsn_Override' ELSE 'if_Rsn_Override(@RunPostingGroupAuditId)' END+'
UNION ALL
SELECT CustomerId,
	0,
    ''No endnote given'',
    ''No endnote given''
FROM '+@SourceDatabaseName+'.adm.Customer
WHERE IsActive = 1),

-- Adjustment360OverrideEndNoteSubCategory
cte_Adjustment360OverrideEndNoteSubCategory AS(
SELECT OdsCustomerId,
	   ReasonNumber,
       SubCategoryId
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Adjustment360OverrideEndNoteSubCategory' ELSE 'if_Adjustment360OverrideEndNoteSubCategory(@RunPostingGroupAuditId)' END+'
UNION ALL
SELECT CustomerId,
	0,
    6
FROM '+@SourceDatabaseName+'.adm.Customer
WHERE IsActive = 1),

-- Let''s grab the latest description UB_APC_DICT
cte_UB_APC_DICT AS(
SELECT  OdsCustomerId,
		APC,
        MAX(EndDate) AS EndDate
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'UB_APC_DICT' ELSE 'if_UB_APC_DICT(@RunPostingGroupAuditId)' END+' rs
GROUP BY APC,OdsCustomerId),

-- Get Endnote and Descriptions
cte_EndNoteDescriptions AS (
SELECT  rs.OdsCustomerId,
		rs.ReasonNumber AS Endnote,
        rs.ShortDesc AS ShortDescription,
        rs.LongDesc AS LongDescription,
        1 AS EndnoteTypeId,
        sc.SubCategoryId AS Adjustment360SubCategoryId
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'rsn_REASONS' ELSE 'if_rsn_REASONS(@RunPostingGroupAuditId)' END+' rs 
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Adjustment360EndNoteSubCategory' ELSE 'if_Adjustment360EndNoteSubCategory(@RunPostingGroupAuditId)' END+' sc
ON rs.OdsCustomerId = sc.OdsCustomerId AND rs.ReasonNumber = sc.ReasonNumber 
UNION ALL
SELECT  OdsCustomerId,
		rs.RuleID,
        rs.EndnoteShort,
        rs.EndnoteLong,
        2 AS EndNoteTypeId, 
        15 AS SubCategoryId
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'SENTRY_RULE_ACTION_HEADER' ELSE 'if_SENTRY_RULE_ACTION_HEADER(@RunPostingGroupAuditId)' END+' rs
--UNION ALL
--SELECT rs.OdsCustomerId
--		 rs.Endnote,
--       rs.ShortDesc,
--       rs.LongDesc,
--       3 AS EndNoteTypeId, 
--       7 AS SubCategoryId
--FROM dbo.CTG_Endnotes rs
UNION ALL
SELECT  rs.OdsCustomerId,
		rs.ReasonNumber,
        rs.ShortDesc,
        rs.LongDesc,
        4 AS EndNoteTypeId, 
        sc.SubCategoryId
FROM  cte_Rsn_Override rs
LEFT OUTER JOIN  cte_Adjustment360OverrideEndNoteSubCategory sc
ON rs.OdsCustomerId = sc.OdsCustomerId AND rs.ReasonNumber = sc.ReasonNumber
UNION ALL
SELECT  rs.OdsCustomerId,
		rs.APC,
        rs.Description,
        rs.Description,
        5 AS EndNoteTypeId, 
        sc.SubCategoryId
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'UB_APC_DICT' ELSE 'if_UB_APC_DICT(@RunPostingGroupAuditId)' END+' rs
INNER JOIN cte_UB_APC_DICT rs1
ON rs.OdsCustomerId = rs1.OdsCustomerId AND rs1.APC = rs.APC
    AND rs1.EndDate = rs.EndDate
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Adjustment360ApcEndNoteSubCategory' ELSE 'if_Adjustment360ApcEndNoteSubCategory(@RunPostingGroupAuditId)' END+' sc
ON rs.OdsCustomerId = sc.OdsCustomerId 
AND rs.APC = sc.ReasonNumber 

---UNION ALL
--SELECT rs.OdsCustomerId,
--		 rs.ReasonNumber,
--       rs.ShortDesc,
--       rs.LongDesc,
--       6 AS EndNoteTypeId, 
--       sc.SubCategoryId
--FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Rsn_Reasons_3rdParty' ELSE 'if_Rsn_Reasons_3rdParty(@RunPostingGroupAuditId)' END+' rs
--LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Adjustment3603rdPartyEndNoteSubCategory' ELSE 'if_Adjustment3603rdPartyEndNoteSubCategory(@RunPostingGroupAuditId)' END+' sc
--ON rs.OdsCustomerId = sc.OdsCustomerId AND rs.ReasonNumber = sc.ReasonNumber 
    
)

SELECT DISTINCT I.OdsCustomerId
	,I.billID
	,I.billline
	,I.linetype
	,CASE WHEN AC.Name IS NULL  AND A.Adjustment > 0  THEN ''Uncategorized''  ELSE  AC.Name END AS ReductionType
	,CASE WHEN A3S.Name IS NULL AND A.Adjustment > 0  THEN ''Uncategorized''  ELSE A3S.Name END AS AdjSubCatName
	,A.Adjustment 

INTO #selfservePerformance_Adjustments
FROM stg.SelfServePerformanceReport_Savings_Data I
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BillAdjustment' ELSE 'if_BillAdjustment(@RunPostingGroupAuditId)' END+' A
ON I.OdsCustomerId = A.OdsCustomerId
	AND I.billID = A.BillIdNo
	AND I.Billline = A.LineNumber
LEFT OUTER JOIN   cte_EndNoteDescriptions R
ON  A.OdsCustomerId = R.OdsCustomerId
	AND A.EndNote = R.Endnote
	AND A.EndNoteTypeId = R.EndnoteTypeId
-- Let''s create our AdjustmentSubCategory lookup. 
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Adjustment360SubCategory' ELSE 'if_Adjustment360SubCategory(@RunPostingGroupAuditId)' END+' A3S
    ON R.OdsCustomerId = A3S.OdsCustomerId
	AND R.Adjustment360SubCategoryId = A3S.Adjustment360SubCategoryId
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Adjustment360Category' ELSE 'if_Adjustment360Category(@RunPostingGroupAuditId)' END+' AC
    ON A3S.OdsCustomerId = AC.OdsCustomerId
	AND A3S.Adjustment360CategoryId = AC.Adjustment360CategoryId
'+
CASE WHEN @OdsCustomerID <> 0 THEN 
CHAR(13)+CHAR(10)+'WHERE I.OdsCustomerId = '+CAST(@OdsCustomerID AS VARCHAR(5)) ELSE '' END +';

INSERT INTO stg.SelfServePerformanceReport_Savings_Adjustments(
	   OdsCustomerId
      ,billIDNo
      ,line_no
      ,line_type
	  ,ReductionType
	  ,AdjSubCatName
      ,Adjustment
      ,RunDate)
SELECT 
	 OdsCustomerId
	,billID
	,BillLine
	,linetype
	,ReductionType
	,AdjSubCatName
	,Adjustment
	,GETDATE() AS RunDate
FROM #selfservePerformance_Adjustments I
 '

EXEC (@SQLScript)


END
GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.SelfServePerformanceReport_Savings_Data') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SelfServePerformanceReport_Savings_Data
GO

CREATE PROCEDURE dbo.SelfServePerformanceReport_Savings_Data
(
@SourceDatabaseName VARCHAR(50)='AcsOds',
@StartDate AS DATETIME ,
@EndDate AS DATETIME,
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@ReportId INT = 1,
@OdsCustomerId INT = 0
)
AS

BEGIN
 --DECLARE @SourceDatabaseName VARCHAR(50)='AcsOdsFK',@StartDate AS DATETIME = '20190201',@EndDate AS DATETIME = '20200229'
 --,@if_Date AS DATETIME = GETDATE(),@OdsCustomerId INT = 19,@RunType INT = 0;

DECLARE  @SQLScript VARCHAR(MAX)
SET @SQLScript = CAST ('' AS VARCHAR(MAX)) + '

DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;

TRUNCATE TABLE stg.SelfServePerformanceReport_Savings_Data;

-- Get the DX For Body Part
IF OBJECT_ID(''tempdb..#Diagnosis'') IS NOT NULL DROP TABLE #Diagnosis;  /*Get Diagnosis Code*/
SELECT OdsCustomerId,BillIDNo,DX
INTO #Diagnosis
FROM (
SELECT C.OdsCustomerId
	,C.BillIDNo
	,C.DX
	, ROW_NUMBER() Over (Partition By OdsCustomerId,BillIDNo ORDER By SeqNum asc) Rnk
FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CMT_DX' ELSE 'if_CMT_DX(@RunPostingGroupAuditId)' END + ' C
'+CASE WHEN @OdsCustomerId <> 0 THEN 'WHERE C.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +' 
)X WHERE Rnk = 1;

-- Get MitchellCompleteDate Claimants
IF OBJECT_ID(''tempdb..#MitchellCompleteDateClaimants'') IS NOT NULL DROP TABLE #MitchellCompleteDateClaimants
SELECT   OdsCustomerId
		,CmtIdNo
		,CASE WHEN Max(UDFValueDate) = ''1899-12-30 00:00:00.000'' THEN NULL ELSE Max(UDFValueDate) END AS MitchellCmptDate
INTO #MitchellCompleteDateClaimants
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'UDFClaimant' ELSE'if_UDFClaimant(@RunPostingGroupAuditId)' END+'
WHERE UDFIdNo  IN (''-3'',''-4'',''5'')'+
CASE WHEN @OdsCustomerId <> 0 THEN CHAR(13)+CHAR(10)+CHAR(9)+'AND OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +'
GROUP BY OdsCustomerId
		,CmtIdNo

-- Get Bill Committed Date
IF OBJECT_ID(''tempdb..#Bill_History'') IS NOT NULL DROP TABLE #Bill_History
SELECT bhs.OdsCustomerId
	,bhs.billIDNo
	,max(bhs.DateCommitted) as DateCommitted 
INTO #Bill_History
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Bill_History' ELSE 'if_Bill_History(@RunPostingGroupAuditId)' END+ ' bhs
WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN ' bhs.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))ELSE '' END+'
GROUP BY bhs.OdsCustomerId
	,bhs.billIDNo; 

-- Get BillIdNo
IF OBJECT_ID(''tempdb..#BILL_HDR'') IS NOT NULL DROP TABLE #BILL_HDR
SELECT DISTINCT
	 BH.OdsCustomerId
	,BH.BillIDNo
	,BH.CMT_HDR_IDNo
	,bhs.DateCommitted 
	,BH.CreateDate
	,CASE WHEN BH.Flags & 4096 > 0 THEN ''UB-04''  ELSE ''CMS-1500''  END AS Form_Type
	,ISNULL(d.DX,-1) AS DiagnosisCode
	,BH.CV_Type
	,C.CustomerName
INTO #BILL_HDR
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BILL_HDR' ELSE 'if_BILL_HDR(@RunPostingGroupAuditId)' END +' BH
INNER JOIN '+@SourceDatabaseName+'.adm.Customer C
ON C.CustomerId = BH.OdsCustomerId
LEFT OUTER JOIN #Bill_History bhs ON BH.OdsCustomerId = bhs.OdsCustomerId 
	AND BH.BillIDNo = bhs.BillIDNo 
LEFT OUTER JOIN #Diagnosis d ON BH.OdsCustomerId = d.OdsCustomerId
	AND BH.BillIDNo = d.BillIDNo 
WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN 'BH.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) + ' AND ' ELSE '' END +'
        CONVERT(VARCHAR(10),BH.CreateDate,112) BETWEEN '''+CONVERT(VARCHAR(10),@StartDate,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+'''
AND BH.Flags & 16 = 0

CREATE NONCLUSTERED INDEX idx_BillIDNo ON #BILL_HDR(OdsCustomerId,BillIDNo) 

-- Get the latest ProcCode Desc
IF OBJECT_ID(''tempdb..#ProCodeDesc'') IS NOT NULL DROP TABLE #ProCodeDesc
SELECT OdsCustomerId,PRC_CD, PRC_DESC
INTO #ProCodeDesc
FROM (
SELECT CP.OdsCustomerId
	,CP.PRC_CD
	,CP.PRC_DESC
	,ROW_NUMBER() Over (Partition By OdsCustomerId,PRC_CD ORDER By Startdate desc) Rnk
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'cpt_PRC_DICT' ELSE 'if_BILL_HDR(@RunPostingGroupAuditId)' END +' CP
WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN ' CP.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))ELSE '' END+'
)X WHERE Rnk = 1

--Get Provider Data into temp table
IF OBJECT_ID(''tempdb..#Provider'') IS NOT NULL DROP TABLE #Provider; 
SELECT DISTINCT 
	 OdsCustomerId
	,PvdIDNo
	,PvdTIN
INTO #Provider
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'PROVIDER' ELSE 'if_BILL_HDR(@RunPostingGroupAuditId)' END +' P
WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN ' P.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))ELSE '' END+'

CREATE NONCLUSTERED INDEX idx_Prov ON #Provider(OdsCustomerId,PvdIDNo) INCLUDE ([PvdTIN]);

 --Get ExpectedrecoverDate & Duration
IF OBJECT_ID(''tempdb..#Erd'') IS NOT NULL DROP TABLE #Erd;
SELECT DISTINCT OdsCustomerId
	,CmtIDNo
	,ISNULL(Duration,0)*7 AS  ExpectedRecoveryDuration
INTO #Erd
FROM (
SELECT cdx.OdsCustomerId
	,CH.CmtIDNo
	,cdx.BillIDNo
	,dx.DiagnosisCode
	,ISNULL(dx.Duration,0) Duration
	,I.InjuryNaturePriority
	,ROW_NUMBER() OVER (PARTITION BY cdx.OdsCustomerId,ch.CmtIDNo ORDER BY ISNULL(dx.Duration,0) desc,InjuryNaturePriority desc) rnk 
FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CMT_DX' ELSE 'if_CMT_DX(@RunPostingGroupAuditId)' END + ' cdx  
INNER JOIN #BILL_HDR BH
     ON  BH.OdsCustomerID = cdx.OdsCustomerID
	AND BH.BillIDNo = cdx.BillIDNo
INNER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CMT_HDR' ELSE 'if_CMT_HDR(@RunPostingGroupAuditId)' END + ' CH
ON CH.OdsCustomerID = BH.OdsCustomerID 
    AND BH.CMT_HDR_IDNo = CH.CMT_HDR_IDNo
LEFT OUTER JOIN (
     SELECT 
	    OdsCustomerID,
		ICD9 AS DiagnosisCode,
		Duration,
		9 AS IcdVersion
	FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'cpt_DX_DICT' ELSE 'if_cpt_DX_DICT(@RunPostingGroupAuditId)' END +  
	CASE WHEN @OdsCustomerId <> 0 THEN ' WHERE OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3))  ELSE '' END + '  
	UNION ALL
	SELECT 
	    OdsCustomerID,
		DiagnosisCode,
		Duration,
		10 AS IcdVersion
     FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'Icd10DiagnosisVersion' ELSE 'if_Icd10DiagnosisVersion(@RunPostingGroupAuditId)' END + 
    CASE WHEN @OdsCustomerId <> 0 THEN ' WHERE OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3))  ELSE '' END + ' 

 )dx    ON  dx.OdsCustomerID = cdx.ODSCustomerID
    AND dx.DiagnosisCode = cdx.dx
    AND dx.IcdVersion = cdx.IcdVersion  
LEFT OUTER JOIN (   SELECT OdsCustomerId, DiagnosisCode, IcdVersion, InjuryNatureId
		    FROM (
		    SELECT OdsCustomerId
				, DiagnosisCode
				, IcdVersion
				, InjuryNatureId
				,ROW_NUMBER() OVER (PARTITION BY OdsCustomerId, DiagnosisCode, IcdVersion ORDER BY EndDate DESC) rnk
		      FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'IcdDiagnosisCodeDictionary' ELSE 'if_IcdDiagnosisCodeDictionary(@RunPostingGroupAuditId)' END + 
                     CASE WHEN @OdsCustomerId <> 0 THEN ' WHERE OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3))  ELSE '' END + '
 		) X WHERE rnk = 1) dict
    ON dx.OdsCustomerId = dict.OdsCustomerId
    AND dx.DiagnosisCode = dict.DiagnosisCode
    AND dx.IcdVersion = dict.IcdVersion
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'InjuryNature' ELSE 'if_InjuryNature(@RunPostingGroupAuditId)' END + ' I 
    ON dict.OdsCustomerId = I.OdsCustomerId
    AND dict.InjuryNatureId = I.InjuryNatureId
) X WHERE rnk = 1

CREATE NONCLUSTERED INDEX nidx_CustIdCmtIDNo ON  #Erd
(OdsCustomerId,CmtIDNo) INCLUDE (ExpectedRecoveryDuration)

-- Insert result to the Stg table
INSERT INTO  stg.SelfServePerformanceReport_Savings_Data(
     	OdsCustomerId
       ,CustomerName
       ,Company
       ,Office
       ,SOJ
       ,ClaimCoverageType
       ,BillCoverageType
       ,FormType
       ,ClaimID
       ,ClaimantID
       ,ProviderTIN
       ,BillID
       ,BillCreateDate
       ,BillCommitDate
       ,MitchellCompleteDate
       ,ClaimCreateDate
       ,ClaimDateofLoss
       ,ExpectedRecoveryDate
       ,BillLine
	   ,LineType
       ,ProcedureCode
       ,ProcedureCodeDescription
       ,ProcedureCodeMajorGroup
       ,BodyPart
       ,ProviderCharges
       ,TotalAllowed
       ,TotalUnits
       ,ExpectedRecoveryDuration
 )
SELECT
		 BH.OdsCustomerId                
		,BH.CustomerName 
		,ISNULL(CO.CompanyName, ''NA'') 
		,ISNULL(O.OfcName, ''NA'')     
		,CM.CmtStateOfJurisdiction      
		,CL.CV_Code                     
		,BH.CV_type                     
		,BH.Form_Type					
		,CL.ClaimIDNo                  
		,CM.CmtIDNo                     
		,P.PvdTIN                       
		,BH.BillIDNo										
		,bh.CreateDate                  
		,BH.DateCommitted
		,MCD.MitchellCmptDate   
		,CL.CreateDate                  
		,CL.DateLoss                    
		,DATEADD(day,dx.ExpectedRecoveryDuration,CL.DateLoss) 
		,B.LINE_NO                     
		,B.LineType
		,B.PRC_CD                       
		,PRCT.PRC_DESC                  
		,PCG.MajorCategory              
		,NCb.Description                 
		,B.CHARGED                     
		,B.ALLOWED                     
		,b.UNITS                       
		,dx.ExpectedRecoveryDuration

FROM #BILL_HDR BH
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CMT_HDR' ELSE'if_CMT_HDR(@RunPostingGroupAuditId)' END+' CH 
	ON BH.OdsCustomerId = CH.OdsCustomerId
	AND BH.CMT_HDR_IDNo = CH.CMT_HDR_IDNo
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CLAIMANT' ELSE'if_CLAIMANT(@RunPostingGroupAuditId)' END+' CM 
	ON CH.OdsCustomerId = CM.OdsCustomerId
	AND CH.CmtIDNo = CM.CmtIDNo 
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CLAIMS' ELSE'if_CLAIMS(@RunPostingGroupAuditId)' END+' CL 
	ON  CM.OdsCustomerId = CL.OdsCustomerId
	AND CM.ClaimIDNo  = CL.ClaimIDNo
	AND CL.ClaimNo NOT LIKE ''%TEST%''
	AND(CL.OdsCustomerId NOT IN (70,71) OR CL.Status <> ''C'')'+'
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'prf_COMPANY' ELSE'if_prf_COMPANY(@RunPostingGroupAuditId)' END+' CO 
	ON CO.OdsCustomerId = CL.OdsCustomerId
	AND CO.CompanyID = CL.CompanyID
	AND CO.CompanyName NOT LIKE ''%TEST%''
	AND CO.CompanyName NOT LIKE ''%TRAIN%''	
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'prf_Office' ELSE'if_prf_Office(@RunPostingGroupAuditId)' END+' O
	ON O.OdsCustomerId = CL.OdsCustomerId
	AND O.OfficeID = CL.OfficeIndex
	AND O.OfcName NOT LIKE ''%TEST%''
	AND O.OfcName NOT LIKE ''%TRAIN%''
LEFT OUTER JOIN #MitchellCompleteDateClaimants MCD
	ON CM.OdsCustomerId = MCD.OdsCustomerId
	AND CM.CmtIDNo = MCD.CmtIDNo
INNER JOIN (SELECT
				 OdsCustomerId 
				,BillIDNo
				,LINE_NO_DISP
				,LINE_NO
				,PRC_CD
				,ISNULL(CHARGED, 0) CHARGED
				,ISNULL(PreApportionedAmount ,ALLOWED) ALLOWED 
				,ISNULL(UNITS, 0) UNITS
				,1 AS LineType
			FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BILLS' ELSE'if_BILLS(@RunPostingGroupAuditId)' END+' 
			WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN 'OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ' ELSE '' END +'CHARGED IS NOT NULL
			UNION 
			SELECT 
				 OdsCustomerId
				,BillIDNo
				,LINE_NO_DISP
				,LINE_NO
				,NDC
				,ISNULL(CHARGED, 0) CHARGED
				,ISNULL(PreApportionedAmount ,ALLOWED) ALLOWED 
				,ISNULL(UNITS, 0) UNITS
				,2 AS LineType
			FROM  '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BILLS_Pharm' ELSE'if_BILLS_Pharm(@RunPostingGroupAuditId)' END+'
			WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN 'OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ' ELSE '' END +'CHARGED IS NOT NULL
			) AS B
	ON BH.OdsCustomerId = B.OdsCustomerId
	AND BH.BillIDNo = B.BillIDNo
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'ProcedureCodeGroup' ELSE'if_ProviderSpecialtyToProvType(@RunPostingGroupAuditId)' END+' PCG
ON PCG.ProcedureCode = B.PRC_CD
	AND PCG.OdsCustomerId = B.OdsCustomerId	
LEFT OUTER JOIN #ProCodeDesc PRCT
ON PRCT.PRC_CD = B.PRC_CD
	AND PRCT.OdsCustomerId = B.OdsCustomerId
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'IcdDiagnosisCodeDictionaryBodyPart' ELSE'if_ProviderSpecialtyToProvType(@RunPostingGroupAuditId)' END+' ICD
ON bh.OdsCustomerId =ICD.OdsCustomerId 
	AND BH.DiagnosisCode =  ICD.DiagnosisCode
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'NcciBodyPart' ELSE'if_ProviderSpecialtyToProvType(@RunPostingGroupAuditId)' END+' NCB
ON ICD.OdsCustomerId = NCB.OdsCustomerId
	AND ICD.NcciBodyPartId = NCB.NcciBodyPartId
LEFT OUTER JOIN #Provider P
ON  P.OdsCustomerId = CH.OdsCustomerId
	AND P.PvdIDNo = CH.PvdIDNo 
LEFT OUTER JOIN #Erd dx
ON  dx.OdsCustomerID = CM.ODSCustomerID
    AND dx.CmtIDNo = CM.CmtIDNo '

EXEC (@SQLScript);


END





GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.SelfServePerformanceReport_Savings_Output') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SelfServePerformanceReport_Savings_Output
GO


CREATE PROCEDURE dbo.SelfServePerformanceReport_Savings_Output(
@SourceDatabaseName VARCHAR(50)='AcsOds',
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerID INT = 0,
@TargetDatabaseName VARCHAR(50) = 'ReportDB')
AS
BEGIN
	--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOdsFK',@RunType INT = 0,@if_Date AS DATETIME = GETDATE(), @OdsCustomerID INT = 19 , @TargetDatabaseName VARCHAR(50) = 'ReportDB_FK'

DECLARE @SQLScript VARCHAR(MAX);

SET @SQLScript = '
DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;

'+CASE WHEN @OdsCustomerID <> 0 THEN 
'DELETE FROM '+@TargetDatabaseName+'.dbo.SelfServePerformanceReport_Savings
WHERE OdsCustomerId = '+CAST(@OdsCustomerID as VARCHAR(5))+';' ELSE 

'TRUNCATE TABLE '+@TargetDatabaseName+'.dbo.SelfServePerformanceReport_Savings;' END+'

-- Get Latest date bill was sent to PPO
IF OBJECT_ID(''tempdb..#PrePPOBillInfoTemp'') IS NOT NULL DROP TABLE #PrePPOBillInfoTemp
SELECT DISTINCT 
		 S.OdsCustomerId
		,E.billIDNo 
		,E.line_no
		,CASE WHEN E.Endnotes = ''4'' THEN 1
				  ELSE 0 END       AS DuplicateLine
INTO #PrePPOBillInfoTemp
FROM stg.SelfServePerformanceReport_Savings_Data S
INNER JOIN rpt.PrePPOBillInfo_Endnotes E
	ON S.OdsCustomerId = E.OdsCustomerId
	AND S.BillId = E.billIDNo
	AND S.BillLine = E.line_no
	AND S.LineType = E.linetype

IF OBJECT_ID(''tempdb..#PrePPOBillInfo'') IS NOT NULL DROP TABLE #PrePPOBillInfo
SELECT 
	 OdsCustomerId
	,billIDNo
	,SUM(DuplicateLine) AS DuplicateLineFlag
	,COUNT(DISTINCT line_no)     AS LineCount
INTO #PrePPOBillInfo
FROM #PrePPOBillInfoTemp 
GROUP BY OdsCustomerId
		,billIDNo


-- Insert the result to the Output table
INSERT INTO dbo.SelfServePerformanceReport_Savings(
	    OdsCustomerId
       ,CustomerName
       ,Company
       ,Office
       ,SOJ
       ,ClaimCoverageType
       ,BillCoverageType
       ,FormType
       ,ClaimID
       ,ClaimantID
       ,ProviderTIN
       ,BillID
       ,BillCreateDate
       ,BillCommitDate
       ,MitchellCompleteDate
       ,ClaimCreateDate
       ,ClaimDateofLoss
       ,ExpectedRecoveryDate
       ,BillLine
	   ,ProcedureCode
       ,ProcedureCodeDescription
       ,ProcedureCodeMajorGroup
       ,BodyPart
       ,ReductionType
	   ,AdjSubCatName
       ,DuplicateBillFlag
       ,DuplicateLineFlag
       ,Adjustment
       ,ProviderCharges
       ,TotalAllowed
       ,TotalUnits
       ,ExpectedRecoveryDuration
)
SELECT 
        S.OdsCustomerId
       ,CustomerName
       ,Company
       ,Office
       ,SOJ
       ,ClaimCoverageType
       ,BillCoverageType
       ,FormType
       ,ClaimID
       ,ClaimantID
       ,ProviderTIN
       ,BillID
       ,BillCreateDate
       ,BillCommitDate
       ,MitchellCompleteDate
       ,ClaimCreateDate
       ,ClaimDateofLoss
       ,ExpectedRecoveryDate
       ,BillLine
	   ,ProcedureCode
       ,ProcedureCodeDescription
       ,ProcedureCodeMajorGroup
       ,BodyPart
       ,ADJ.ReductionType
	   ,ADJ.AdjSubCatName
	   ,ISNULL(CASE WHEN DuplicateLineFlag = 0 THEN 0 WHEN DuplicateLineFlag > 0 AND  DuplicateLineFlag < P.LineCount  THEN 1 WHEN  P.LineCount = DuplicateLineFlag THEN 2 END ,0) AS DuplicateBillFlag
	   ,ISNULL(M.DuplicateLine,0) AS DuplicateLineFlag
       ,ISNULL(ADJ.Adjustment, 0) AS Adjustment 
       ,ProviderCharges
       ,TotalAllowed
       ,TotalUnits
	   ,ExpectedRecoveryDuration

FROM stg.SelfServePerformanceReport_Savings_Data S
LEFT OUTER JOIN #PrePPOBillInfoTemp M
	ON S.OdsCustomerId = M.OdsCustomerId
	AND S.BillId = M.billIDNo
	AND S.BillLine = M.line_no
LEFT OUTER JOIN #PrePPOBillInfo P
	ON S.OdsCustomerId = P.OdsCustomerId
	AND S.BillId = P.billIDNo
LEFT OUTER JOIN stg.SelfServePerformanceReport_Savings_Adjustments ADJ
	ON S.OdsCustomerId = ADJ.OdsCustomerId
	AND S.BillId = ADJ.billIDNo
	AND S.BillLine = ADJ.line_no
'

EXEC(@SQLScript); 

END

GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.VPN_Monitoring_GreenwichData') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.VPN_Monitoring_GreenwichData
GO

CREATE PROCEDURE dbo.VPN_Monitoring_GreenwichData (
@SourceDatabaseName VARCHAR(50) = 'AcsOds',
@TargetDatabaseName VARCHAR(50) = 'ReportDB')
AS
BEGIN
-- VPN_Monitoring_NetworkCredits_Output 

DECLARE @SQLQuery VARCHAR(MAX) = 
'DELETE FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkCredits_Output 
WHERE Customer = ''Greenwich'';
INSERT INTO '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkCredits_Output 
SELECT 0 
      ,''Greenwich'' Customer
      ,Period 
      ,SOJ 
      ,CV_Type 
      ,BillType 
      ,Network 
      ,''Company1'' Company
      ,''Office1'' Office
      ,ActivityFlagDesc 
      ,CreditReasonDesc 
      ,AVG(Credits) Credits
      ,GETDATE()
FROM  '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkCredits_Output 
WHERE Customer IN ( ''FBFS'', ''Sentry'', ''BristolWest'',''OneBeacon'')
GROUP BY Period 
      ,SOJ 
      ,CV_Type 
      ,BillType 
      ,Network 
      ,ActivityFlagDesc 
      ,CreditReasonDesc; 
      
-- VPN_Monitoring_NetworkRepricedSubmitted_Output
DELETE FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output
WHERE Customer = ''Greenwich'';
INSERT INTO '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output
SELECT StartOfMonth
      ,0
      ,''Greenwich'' Customer
      ,SOJ
      ,NetworkName
      ,BillType
      ,ReportYear
      ,ReportMonth
      ,CV_Type
      ,''Company1'' Company
      ,''Office1'' Office
      ,AVG(BillsCount)
      ,AVG(BillsRepriced)
      ,AVG(ProviderCharges)
      ,AVG(BRAllowable)
      ,AVG(InNetworkCharges)
      ,AVG(InNetworkAmountAllowed)
      ,AVG(Savings)
      ,AVG(Credits)
      ,AVG(NetSavings)
	  ,ReportTypeId
      ,GETDATE()
FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output
WHERE Customer IN ( ''FBFS'', ''Sentry'', ''BristolWest'',''OneBeacon'')
GROUP BY StartOfMonth
      ,SOJ
      ,NetworkName
      ,BillType
      ,ReportYear
      ,ReportMonth
      ,CV_Type
	  ,ReportTypeId;

-- VPN_Monitoring_NetworkUniqueSubmitted_Output  
DELETE FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output
WHERE Customer = ''Greenwich'';    
INSERT INTO '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output
SELECT StartOfMonth
      ,0
      ,''Greenwich'' Customer
      ,ReportYear
      ,ReportMonth
      ,SOJ
      ,BillType
      ,CV_Type
      ,''Company1'' Company
      ,''Office1'' Office
      ,AVG(InNetworkCharges)
      ,AVG(InNetworkAmountAllowed)
      ,AVG(Savings)
      ,AVG(Credits)
      ,AVG(NetSavings)
      ,AVG(BillsCount)
      ,AVG(BillsRePriced)
      ,AVG(ProviderCharges)
      ,AVG(BRAllowable)
	  ,ReportTypeId
      ,GETDATE()
FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output
WHERE Customer IN ( ''FBFS'', ''Sentry'', ''BristolWest'',''OneBeacon'')
GROUP BY StartOfMonth
      ,SOJ
      ,BillType
      ,ReportYear
      ,ReportMonth
      ,CV_Type
	  ,ReportTypeId

-- VPN_Monitoring_TAT_Output
DELETE FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_TAT_Output
WHERE Client = ''Greenwich''; 
INSERT INTO '+@TargetDatabaseName+'.dbo.VPN_Monitoring_TAT_Output
SELECT 0
	  ,StartOfMonth
      ,''Greenwich'' Customer
      ,BillIdNo
      ,ClaimIdNo
      ,SOJ
      ,NetworkId
      ,NetworkName
      ,SentDate
      ,ReceivedDate
      ,AVG(HoursLockedToVPN)
      ,AVG(TATInHours)
      ,AVG(TAT)
      ,BillCreateDate
      ,ParNonPar
      ,SubNetwork
      ,AVG(AmtCharged)
      ,BillType
      ,CASE WHEN AVG(TAT) < 24 THEN ''24''
            WHEN AVG(TAT) >= 24  AND AVG(TAT) < 48 THEN ''48''
            WHEN AVG(TAT) >= 48  AND AVG(TAT) < 72 THEN ''72''
            WHEN AVG(TAT) >= 72  AND AVG(TAT) < 96 THEN ''96''
            WHEN AVG(TAT) >= 96  AND AVG(TAT) < 120 THEN ''120''
            ELSE ''Over120''    END AS Bucket
      ,CASE WHEN AVG(AmtCharged) < 5000 THEN ''Less Than 5000''
            WHEN AVG(AmtCharged) >= 5000  AND AVG(AmtCharged) < 10000 THEN ''Less Than 10000''
            WHEN AVG(AmtCharged) >= 10000 AND AVG(AmtCharged) < 20000 THEN ''Less Than 20000''
            WHEN AVG(AmtCharged) >= 20000 AND AVG(AmtCharged) < 30000 THEN ''Less Than 30000''
            WHEN AVG(AmtCharged) >= 30000 AND AVG(AmtCharged) < 40000 THEN ''Less Than 40000''
            WHEN AVG(AmtCharged) >= 40000 AND AVG(AmtCharged) < 50000 THEN ''Less Than 50000''
            ELSE ''Over 50000'' END AS ValueBucket
      ,GETDATE()
FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_TAT_Output
WHERE Client IN ( ''FBFS'', ''Sentry'', ''BristolWest'',''OneBeacon'')
GROUP BY  StartOfMonth
      ,BillIdNo
      ,ClaimIdNo
      ,SOJ
      ,NetworkId
      ,NetworkName
      ,SentDate
      ,ReceivedDate
      ,BillCreateDate
      ,ParNonPar
      ,SubNetwork
      ,BillType;'

EXEC (@SQLQuery)
END

GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.VPN_Monitoring_NetworkRepricedCredits') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.VPN_Monitoring_NetworkRepricedCredits
GO

CREATE PROCEDURE dbo.VPN_Monitoring_NetworkRepricedCredits(    
@SourceDatabaseName VARCHAR(50)='AcsOds',
@StartDate AS DATETIME,
@EndDate AS DATETIME,
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 0,
@TargetDatabaseName VARCHAR(50) = 'ReportDB')
AS
BEGIN

--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@StartDate AS DATETIME = '20160301',@EndDate AS DATETIME = '20160701',@RunType INT = 0,@if_Date AS DATETIME = NULL,@ReportType INT = 2,@OdsCustomerId INT = 0;

DECLARE @SQLScript VARCHAR(MAX)
  

SET @SQLScript =  CAST('' AS VARCHAR(MAX))  + '
DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;

'+CASE WHEN @OdsCustomerID <> 0 THEN 
'DELETE FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkCredits_Output
WHERE OdsCustomerId = '+CAST(@OdsCustomerID as VARCHAR(5))+' AND Period BETWEEN '''+CONVERT(VARCHAR(10),@StartDate,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+''';' ELSE 

'DELETE FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkCredits_Output
WHERE Period BETWEEN '''+CONVERT(VARCHAR(10),@StartDate,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+''';'  END+'
										
IF OBJECT_ID(''tempdb..#Vpn_Billing_History'') IS NOT NULL DROP TABLE #Vpn_Billing_History;
SELECT VBH.BillIdNo
	,VBH.Line_No
	,VBH.Period
	,VBH.OdsCustomerId
	,VBH.TransactionID 
	,VBH.SOJ
	,VBH.Network
	,VBH.ActivityFlag
	,VBH.BillableFlag
	,VBH.TransactionDate
	,VBH.RepriceDate
	,VBH.SubmittedToFinance
	,VBH.IsInitialLoad
	,VBH.ProviderCharges
	,VBH.DPAllowed
	,VBH.VPNAllowed
	,VBH.Savings
	,VBH.Credits
	,VBH.NetSavings
	,VBH.CompanyCode
	,VBH.VpnId

INTO #Vpn_Billing_History 
FROM ' + @SourceDatabaseName +'.dbo.' + CASE WHEN @RunType = 0 THEN 'Vpn_Billing_History' ELSE 'if_Vpn_Billing_History(@RunPostingGroupAuditId)' END + ' VBH
INNER JOIN ' +@SourceDatabaseName + '.adm.Customer C ON VBH.OdsCustomerId = C.CustomerId
LEFT OUTER JOIN ' +@SourceDatabaseName + '.dbo.' + CASE WHEN @RunType = 0 THEN 'VPNBillableFlags' ELSE 'if_VPNBillableFlags(@RunPostingGroupAuditId)' END + ' BF
	ON  C.EbtCompCode  = BF.CompanyCode
	AND VBH.SOJ  = CASE WHEN BF.SOJ = ''ZZ'' THEN VBH.SOJ ELSE BF.SOJ END 
	AND VBH.VpnId = CASE WHEN BF.NetworkID = -1 THEN VBH.VpnId ELSE BF.NetworkID END 
	AND VBH.ActivityFlag = BF.ActivityFlag
WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN ' VBH.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ' ELSE '' END + 'CONVERT(VARCHAR(10),VBH.Period,112)  BETWEEN ''' +CONVERT(VARCHAR(10),@StartDate,112)+ ''' AND ''' +CONVERT(VARCHAR(10),@EndDate,112)+ '''
	AND BF.CompanyCode IS NULL
	AND VBH.BillableFlag = ''Y'';

IF OBJECT_ID(''tempdb..#VPNResults_Monthly_Credits'') IS NOT NULL DROP TABLE #VPNResults_Monthly_Credits;
;WITH cte_EndnotesPerLine AS (
SELECT 
     VBH.OdsCustomerId
	,VBH.BillIdNo
	,VBH.Line_No
	,COUNT(DISTINCT BOE.OverrideEndNote) Records

FROM #Vpn_Billing_History VBH
INNER JOIN ' +@SourceDatabaseName+ '.dbo.' + CASE WHEN @RunType = 0 THEN 'Bills_OverrideEndNotes' ELSE 'if_Bills_OverrideEndNotes(@RunPostingGroupAuditId)' END + ' BOE 
	ON  VBH.OdsCustomerId = BOE.OdsCustomerId AND VBH.BillIdNo = BOE.BillIdNo	AND VBH.Line_No = BOE.Line_No
INNER JOIN ' +@SourceDatabaseName+ '.dbo.' + CASE WHEN @RunType = 0 THEN 'rsn_Override' ELSE 'if_rsn_Override(@RunPostingGroupAuditId)' END + ' RO 
	ON  VBH.OdsCustomerId = RO.OdsCustomerId AND RO.ReasonNumber = BOE.OverrideEndNote	AND RO.CategoryIdNo <> 3 /* where CategoryIdNo <> 3 */ 
GROUP BY VBH.OdsCustomerId ,VBH.BillIdNo ,VBH.Line_No)
	
,cte_OverrideEndNote AS (
SELECT DISTINCT 
     BOE.OdsCustomerId
	,BOE.BillIDNo
	,BOE.Line_No
	,BOE.OverrideEndNote
	,RO.ShortDesc
	,C.CreditReasonDesc
FROM ' +@SourceDatabaseName+ '.dbo.' + CASE WHEN @RunType = 0 THEN 'Bills_OverrideEndNotes' ELSE 'if_Bills_OverrideEndNotes(@RunPostingGroupAuditId)' END +' BOE
INNER JOIN ' +@SourceDatabaseName+ '.dbo.' + CASE WHEN @RunType = 0 THEN 'rsn_Override' ELSE 'if_rsn_Override(@RunPostingGroupAuditId)' END + ' RO
	ON RO.OdsCustomerId = BOE.OdsCustomerId	AND RO.ReasonNumber = BOE.OverrideEndNote
LEFT OUTER JOIN ' +@SourceDatabaseName+ '.dbo.' + CASE WHEN @RunType = 0 THEN 'CreditReasonOverrideENMap' ELSE 'if_CreditReasonOverrideENMap(@RunPostingGroupAuditId)' END + ' CE 
	ON CE.OdsCustomerId = BOE.OdsCustomerId	AND CE.OverrideEndnoteId = BOE.OverrideEndNote
LEFT OUTER JOIN ' +@SourceDatabaseName+ '.dbo.' + CASE WHEN @RunType = 0 THEN 'CreditReason' ELSE 'if_CreditReason(@RunPostingGroupAuditId)' END +' C 
	ON C.OdsCustomerId = CE.OdsCustomerId AND C.CreditReasonId = CE.CreditReasonId
WHERE ' +CASE WHEN @OdsCustomerId <> 0 THEN ' BOE.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ' ELSE '' END + ' RO.CategoryIdNo <> 3	)	

SELECT 
	 C.CustomerName AS Customer
	,VBH.OdsCustomerId
	,VBH.Period
	,COALESCE(BOE.OverrideEndNote, 0) AS OverrideEndNote
	,VBH.ActivityFlag
	,VBH.BillableFlag
	,VBH.Network
	,VBH.BillIdNo
	,VBH.Line_No
	,VBH.NetSavings
	,CASE WHEN VBH.SOJ = '''' THEN ''UN'' ELSE ISNULL(VBH.SOJ,''UN'') END SOJ
	,VBH.VpnId
	,AF.AF_ShortDesc AS ActivityFlagDesc  
	,CASE WHEN VBH.ActivityFlag IN (''C'',''D'',''P'',''R'',''V'') THEN 1 ELSE 0 END AS Credit
	,CASE WHEN COALESCE(EL.Records, 0) = 0 THEN (CASE WHEN VBH.ActivityFlag IN (''S'',''M'') OR (VBH.ActivityFlag = ''C'' AND VBH.Savings > 0) THEN VBH.ProviderCharges END)	ELSE ((CASE WHEN VBH.ActivityFlag IN (''S'',''M'') OR (VBH.ActivityFlag = ''C'' AND VBH.Savings > 0) THEN VBH.ProviderCharges ELSE 0 END) / EL.Records)	END AS AdjProviderCharges
	,CASE WHEN COALESCE(EL.Records, 0) = 0 THEN (CASE WHEN VBH.ActivityFlag IN (''S'',''M'') OR (VBH.ActivityFlag = ''C'' AND VBH.Savings > 0) THEN VBH.DPAllowed END)	ELSE ((CASE WHEN VBH.ActivityFlag IN (''S'',''M'') OR (VBH.ActivityFlag = ''C'' AND VBH.Savings > 0) THEN VBH.DPAllowed ELSE 0 END)/ EL.Records)	END AS AdjDPAllowed
	,CASE WHEN COALESCE(EL.Records, 0) = 0 THEN (CASE WHEN VBH.ActivityFlag IN (''S'',''M'') OR (VBH.ActivityFlag = ''C'' AND VBH.Savings > 0) THEN VBH.VPNAllowed END) ELSE ((CASE WHEN VBH.ActivityFlag IN (''S'',''M'') OR (VBH.ActivityFlag = ''C'' AND VBH.Savings > 0) THEN VBH.VPNAllowed ELSE 0 END) / EL.Records)	END AS AdjVPNAllowed
	,CASE WHEN COALESCE(EL.Records, 0) = 0 THEN (CASE WHEN VBH.ActivityFlag IN (''S'',''M'') OR (VBH.ActivityFlag = ''C'' AND VBH.Savings > 0) THEN VBH.Savings END) ELSE ((CASE WHEN VBH.ActivityFlag IN (''S'',''M'') OR (VBH.ActivityFlag = ''C'' AND VBH.Savings > 0) THEN VBH.Savings ELSE 0 END) / EL.Records) END AS AdjSavings
	,CASE WHEN COALESCE(EL.Records, 0) = 0 THEN (CASE WHEN VBH.ActivityFlag IN (''C'',''D'',''P'',''R'',''V'') THEN VBH.Credits END) ELSE ((CASE WHEN VBH.ActivityFlag IN (''C'',''D'',''P'',''R'',''V'') THEN VBH.Credits ELSE 0 END) / EL.Records) END AS AdjCredits
	,CASE WHEN COALESCE(EL.Records, 0) = 0 THEN VBH.NetSavings ELSE (VBH.NetSavings / EL.Records)	END AS AdjNetSavings
	,CASE WHEN BH.Flags & 4096 > 0 THEN ''UB-04'' ELSE ''CMS-1500''  END BillType
	,COALESCE(EL.Records, 0) AS Records
	,BOE.ShortDesc
	,CASE WHEN BOE.CreditReasonDesc IS NULL THEN AF.AF_DESCRIPTION  ELSE BOE.CreditReasonDesc END CreditReasonDesc  /*If a BillLine has 0 Records i.e. 0 OverrideEndNotes Then Use this Case statement to populate CeditReasonDesc*/
	,COALESCE(BH.CV_type,CMNT.CoverageType,CLM.CV_Code,''NA'') CV_Type
	,ISNULL(CPNY.CompanyName, ''Unknown'') Company
	,ISNULL(OFC.OfcName, ''Unknown'') Office
	,GETDATE() AS Rundate
INTO #VPNResults_Monthly_Credits
FROM #Vpn_Billing_History VBH 
INNER JOIN ' +@SourceDatabaseName + '.adm.Customer C 
		ON VBH.OdsCustomerId = C.CustomerId 
LEFT OUTER JOIN ' +@SourceDatabaseName +'.dbo.VPNActivityFlag AF
	ON AF.ACTIVITY_FLAG = VBH.ActivityFlag
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BILL_HDR' ELSE 'if_BILL_HDR(@RunPostingGroupAuditId)' END+'  BH
	ON  BH.OdsCustomerId = VBH.OdsCustomerId AND BH.BillIDNo = VBH.BillIdNo
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CMT_HDR' ELSE 'if_CMT_HDR(@RunPostingGroupAuditId)' END+' CH 
	ON CH.OdsCustomerId = BH.OdsCustomerId    AND CH.CMT_HDR_IDNo = BH.CMT_HDR_IDNo
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CLAIMANT' ELSE 'if_CLAIMANT(@RunPostingGroupAuditId)' END+' CMNT 
	ON CMNT.OdsCustomerId = CH.OdsCustomerId  AND CMNT.CmtIDNo = CH.CmtIDNo
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CLAIMS' ELSE 'if_CLAIMS(@RunPostingGroupAuditId)' END+' CLM
	ON CLM.OdsCustomerId = CMNT.OdsCustomerId AND CLM.ClaimIDNo = CMNT.ClaimIDNo
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'prf_Office' ELSE 'if_prf_Office(@RunPostingGroupAuditId)' END+' OFC			  
	ON OFC.OdsCustomerId = CLM.OdsCustomerId  AND OFC.CompanyId = CLM.CompanyID
	AND OFC.OfficeId = CLM.OfficeIndex
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'prf_COMPANY' ELSE 'if_prf_COMPANY(@RunPostingGroupAuditId)' END+' CPNY  
	ON CPNY.OdsCustomerId = OFC.OdsCustomerId AND CPNY.CompanyId = OFC.CompanyId
LEFT OUTER JOIN cte_EndnotesPerLine EL 
	ON  EL.OdsCustomerId = VBH.OdsCustomerId	
	AND EL.BillIdNo = VBH.BillIdNo	
	AND EL.Line_No = VBH.Line_No
LEFT OUTER JOIN cte_OverrideEndNote BOE 
	ON  BOE.OdsCustomerId = VBH.OdsCustomerId	
	AND BOE.BillIDNo = VBH.BillIdNo	
	AND BOE.Line_No = VBH.Line_No;


--Populate VPNResults_Monthly_Credits Table
INSERT INTO '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkCredits_Output
SELECT OdsCustomerId
	,Customer
	,Period
	,SOJ
	,CV_Type
	,BillType
	,Network
	,Company
	,Office
	,ActivityFlagDesc
	,CreditReasonDesc
	,SUM(AdjCredits) Credits
	,GETDATE() AS Rundate
FROM #VPNResults_Monthly_Credits
GROUP BY OdsCustomerId
	,Customer
	,Period
	,SOJ
	,CV_Type
	,BillType
	,Network
	,Company
	,Office
	,ActivityFlagDesc
	,CreditReasonDesc

TRUNCATE TABLE stg.VPN_Monitoring_NetworkRepriced;

--Rollup Network Credits and NetSavings
INSERT INTO stg.VPN_Monitoring_NetworkRepriced
SELECT VBH.Period AS StartOfMonth
	,YEAR(VBH.Period) AS ReportYear
	,MONTH(VBH.Period) AS ReportMonth
	,VBH.OdsCustomerId
	,VBH.SOJ
	,VBH.Network
	,VBH.BillType
	,VBH.CV_Type
	,VBH.Company
	,VBH.Office
	,SUM(VBH.AdjProviderCharges) InNetworkCharges
	,SUM(VBH.AdjDPAllowed) InNetworkAmountAllowed
	,SUM(VBH.AdjSavings) Savings
	,SUM(VBH.AdjVPNAllowed) VPNAllowed
	,SUM(VBH.AdjCredits) Credits
	,SUM(VBH.AdjNetSavings) AS NetSavings
	,GETDATE()
FROM #VPNResults_Monthly_Credits VBH
GROUP BY VBH.Period
	,VBH.Period
	,YEAR(VBH.Period)
	,MONTH(VBH.Period)
	,VBH.OdsCustomerId
	,VBH.SOJ
	,VBH.Network
	,VBH.BillType
	,VBH.CV_Type
	,VBH.Company
	,VBH.Office;'

EXEC(@SQLScript);

END

GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.VPN_Monitoring_NetworkRepricedSubmitted') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.VPN_Monitoring_NetworkRepricedSubmitted
GO

CREATE PROCEDURE dbo.VPN_Monitoring_NetworkRepricedSubmitted(
@SourceDatabaseName VARCHAR(50)='AcsOds',
@StartDate AS DATETIME,
@EndDate AS DATETIME,
@if_Date AS DATETIME,
@OdsCustomerId INT,
@TargetDatabaseName VARCHAR(50)='ReportDB')
AS
BEGIN
--3.1
-- Combine Result from repriced and Submitted Monthly.

--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@StartDate AS DATETIME = '20160301',@EndDate AS DATETIME = '20160701',@RunType INT = 0,@if_Date AS DATETIME = NULL,@ReportType INT = 2,@OdsCustomerId INT = 48;

DECLARE @SQLScript VARCHAR(MAX)  

SET @SQLScript =  CAST('' AS VARCHAR(MAX))  + '
 DECLARE @StartOfMonth DATETIME = DATEADD(MONTH, DATEDIFF(MONTH, 0, '''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+'''), 0);

'+CASE WHEN @OdsCustomerID <> 0 THEN 
'DELETE FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output
WHERE OdsCustomerId = '+CAST(@OdsCustomerID as VARCHAR(5))+' AND StartOfMonth BETWEEN '''+CONVERT(VARCHAR(10),@StartDate,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+''' AND ReportTypeId = 1;' ELSE 

'DELETE FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output
WHERE (StartOfMonth BETWEEN '''+CONVERT(VARCHAR(10),@StartDate,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+''' AND ReportTypeId = 1);'  END+'

'+CASE WHEN @OdsCustomerID <> 0 THEN 
'DELETE FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output
WHERE OdsCustomerId = '+CAST(@OdsCustomerID as VARCHAR(5))+' AND StartOfMonth BETWEEN '''+CONVERT(VARCHAR(10),@StartDate,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+''' AND ReportTypeId = 1;' ELSE 

'DELETE FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output
WHERE StartOfMonth BETWEEN '''+CONVERT(VARCHAR(10),@StartDate,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+''' AND ReportTypeId = 1;'  END+'

INSERT INTO '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output
SELECT  ISNULL(VPNS.StartOfMonth ,VPNR.StartOfMonth) StartOfMonth,
		ISNULL(VPNS.OdsCustomerId ,VPNR.OdsCustomerId) OdsCustomerId,
        (SELECT CustomerName FROM '+@SourceDatabaseName+'.adm.Customer WHERE CustomerId = ISNULL(VPNS.OdsCustomerId ,VPNR.OdsCustomerId)) Customer,
        ISNULL(VPNS.SOJ ,VPNR.SOJ) SOJ,
        ISNULL(VPNS.NetworkName,VPNR.NetworkName) NetworkName,
        ISNULL(VPNS.BillType ,VPNR.BillType ) BillType,
        ISNULL(VPNS.ReportYear,VPNR.ReportYear) ReportYear,
        ISNULL(VPNS.ReportMonth,VPNR.ReportMonth) ReportMonth,
        ISNULL(VPNS.CV_Type,VPNR.CV_Type) CV_Type,
        ISNULL(VPNS.Company,VPNR.Company) Company,
        ISNULL(VPNS.Office,VPNR.Office) Office,
		ISNULL(VPNS.BillsCount, 0) AS BillsCount ,
        ISNULL(VPNS.BillsRePriced, 0) AS BillsRepriced ,
        ISNULL(VPNS.ProviderCharges, 0) AS ProviderCharges ,
        ISNULL(VPNS.BRAllowable, 0) AS BRAllowable ,
        ISNULL(VPNR.InNetworkCharges, 0) AS InNetworkCharges ,
        ISNULL(VPNR.InNetworkAmountAllowed, 0) AS InNetworkAmountAllowed ,
        ISNULL(VPNR.Savings, 0) AS Savings ,
        ISNULL(VPNR.Credits, 0) AS Credits ,
        ISNULL(VPNR.NetSavings, 0) AS NetSavings,
		1 AS ReportTypeId,
        GETDATE() AS RunDate

FROM stg.VPN_Monitoring_NetworkSubmitted VPNS
FULL OUTER JOIN stg.VPN_Monitoring_NetworkRepriced VPNR
ON VPNS.StartOfMonth = VPNR.StartOfMonth
    AND VPNS.OdsCustomerId = VPNR.OdsCustomerId
    AND VPNS.SOJ = VPNR.SOJ
    AND VPNS.NetworkName = VPNR.NetworkName
    AND VPNS.BillType = VPNR.BillType
    AND VPNS.CV_Type = VPNR.CV_Type
    AND VPNS.StartOfMonth = VPNR.StartOfMonth
    AND VPNS.Company = VPNR.Company
    AND VPNS.Office = VPNR.Office;'
        
EXEC(@SQLScript);     

--3.2 distinct bills sent
SET @SQLScript =  CAST('' AS VARCHAR(MAX))  + '
DECLARE @StartOfMonth DATETIME = DATEADD(MONTH, DATEDIFF(MONTH, 0, '''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+'''), 0);

;WITH cte_BillMaxCharges AS(
SELECT    StartOfMonth ,
        OdsCustomerId ,
        ReportYear ,
        ReportMonth ,
        SOJ ,
        BillType ,
        CV_Type ,
        Company ,
        Office ,
        BillIdNo ,
		CASE WHEN EventId = 11 THEN 1 WHEN EventId IN (10,16) AND ProcessInfo = 2 THEN 2 END EventType,
        MAX(ProviderCharges) AS ProviderCharges ,
        MAX(BRAllowable) AS BRAllowable
FROM  stg.VPN_Monitoring_ProviderNetworkEventLog_Filtered 

GROUP BY  StartOfMonth ,
        OdsCustomerId ,
        ReportYear ,
        ReportMonth ,
        SOJ ,
        BillType ,
        CV_Type ,
        Company ,
        Office ,
        BillIdNo,
		CASE WHEN EventId = 11 THEN 1 WHEN EventId IN (10,16) AND ProcessInfo = 2 THEN 2 END)
-- Rollup Data Above the Network Level
,cte_VPNResults_View_savings AS(
SELECT  StartOfMonth ,
        OdsCustomerId ,
        SOJ ,
        BillType ,
        CV_Type ,
        Company ,
        Office ,
        SUM(InNetworkCharges) AS InNetworkCharges ,
        SUM(InNetworkAmountAllowed) AS InNetworkAmountAllowed ,
        SUM(Savings) AS Savings ,
        SUM(Credits) AS Credits ,
        SUM(NetSavings) AS NetSavings

FROM    '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output
WHERE ReportTypeId = 1 OR (ReportTypeId = 2 and StartOfMonth < @StartOfMonth)
GROUP BY StartOfMonth ,
        OdsCustomerId ,
        SOJ ,
        BillType ,
        CV_Type ,
        Company ,
        Office)

INSERT INTO '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output 
SELECT  BMC.StartOfMonth ,
        BMC.OdsCustomerId ,
        (SELECT CustomerName FROM '+@SourceDatabaseName+'.adm.Customer WHERE CustomerId = BMC.OdsCustomerId) Customer,
        BMC.ReportYear ,
        BMC.ReportMonth ,
        BMC.SOJ ,
        BMC.BillType ,
        BMC.CV_Type ,
        BMC.Company ,
        BMC.Office ,
		SVGS.InNetworkCharges ,
        SVGS.InNetworkAmountAllowed ,
        SVGS.Savings ,
        SVGS.Credits ,
        SVGS.NetSavings,
        COUNT(DISTINCT CASE WHEN BMC.EventType = 1 THEN BMC.BillIdNo END) BillsCount ,
		COUNT(DISTINCT CASE WHEN BMC.EventType = 2 THEN BMC.BillIdNo END) BillsRePriced ,
        SUM(CASE WHEN BMC.EventType = 1 THEN BMC.ProviderCharges END) AS ProviderCharges ,
        SUM(CASE WHEN BMC.EventType = 1 THEN BMC.BRAllowable END) AS BRAllowable,
		1 AS ReportTypeId,
        GETDATE() AS RunDate

FROM cte_BillMaxCharges BMC
INNER JOIN cte_VPNResults_View_savings SVGS ON SVGS.StartOfMonth = BMC.StartOfMonth
    AND SVGS.OdsCustomerId = BMC.OdsCustomerId
    AND SVGS.SOJ = BMC.SOJ
    AND SVGS.BillType = BMC.BillType
    AND SVGS.CV_Type = BMC.CV_Type
    AND SVGS.Company = BMC.Company
    AND SVGS.Office = BMC.Office

GROUP BY BMC.StartOfMonth ,
        BMC.OdsCustomerId ,
        BMC.ReportYear ,
        BMC.ReportMonth ,
        BMC.SOJ ,
        BMC.BillType ,
        BMC.CV_Type ,
        BMC.Company ,
        BMC.Office,
		SVGS.InNetworkCharges ,
        SVGS.InNetworkAmountAllowed ,
        SVGS.Savings ,
        SVGS.Credits ,
        SVGS.NetSavings;'
        
EXEC(@SQLScript);     

END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.VPN_Monitoring_NetworkSubmitted') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.VPN_Monitoring_NetworkSubmitted
GO

CREATE PROCEDURE dbo.VPN_Monitoring_NetworkSubmitted(    
@SourceDatabaseName VARCHAR(50)='AcsOds',
@StartDate AS DATETIME,
@EndDate AS DATETIME,
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 0)
AS
BEGIN
--1.1 Initial Filter to get the date range we are interested in and filter Bill exclusion bills
--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@StartDate DATETIME = '2014-03-01 00:00:00.000' , @EndDate DATETIME = '2015-03-31 00:00:00.000',@RunType INT = 0,@if_Date AS DATETIME = GETDATE(),@OdsCustomerId INT = 2

--2.1 Raw Data Network Sends
DECLARE @SQLScript VARCHAR(MAX) = '
DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;

SELECT  PNEL.LogDate ,
        PNEL.EventId ,
        PNEL.BillIdNo ,
        PNEL.ProcessInfo ,
        PNEL.NetworkId,
		DATEADD(MONTH, DATEDIFF(MONTH, 0, PNEL.LogDate), 0) StartOfMonth,
        PNEL.OdsCustomerId,
        YEAR(PNEL.LogDate) ReportYear,
        MONTH(PNEL.LogDate) ReportMonth
        
INTO #ProviderNetworkEventLog_Filtered
FROM   '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'ProviderNetworkEventLog' ELSE 'if_ProviderNetworkEventLog(@RunPostingGroupAuditId)' END+' PNEL
INNER JOIN ' +@SourceDatabaseName + '.adm.Customer C
	ON PNEL.OdsCustomerId = C.CustomerId
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CustomerBillExclusion' ELSE 'if_CustomerBillExclusion(@RunPostingGroupAuditId)' END+' BX
	ON C.CustomerDatabase = BX.Customer
	AND BX.BIllIdNo = PNEL.BillIdNo
	AND BX.ReportID = 2
WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN ' PNEL.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ' ELSE '' END + ' PNEL.EventId IN ( 16, 11, 10 )
	AND CONVERT(VARCHAR(10),PNEL.LogDate,112) BETWEEN '''+CONVERT(VARCHAR(10),@StartDate,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+'''
	AND BX.BIllIdNo IS NULL;

TRUNCATE TABLE stg.VPN_Monitoring_ProviderNetworkEventLog_Filtered;
-- Raw Data
INSERT INTO stg.VPN_Monitoring_ProviderNetworkEventLog_Filtered
SELECT  PNELF.LogDate ,
        PNELF.EventId ,
        PNELF.BillIdNo ,
        PNELF.ProcessInfo ,
        PNELF.NetworkId,
		PNELF.StartOfMonth,
        PNELF.OdsCustomerId,
        PNELF.ReportYear,
        PNELF.ReportMonth,
		ISNULL(CLMT.CmtStateOfJurisdiction, ''NA'') SOJ,
        CASE WHEN  BH.[Flags] & 4096 > 0 THEN ''UB-04''   ELSE ''CMS-1500''  END  BillType,
        COALESCE(BH.CV_type,CLMT.CoverageType,CLM.CV_Code,''NA'') CV_Type,
        ISNULL(CPNY.CompanyName, ''NA'')  Company,
        ISNULL(OFC.OfcName, ''NA'') Office,
        ISNULL(BH.AmtCharged, 0) ProviderCharges,
        ISNULL(BH.PrePPOAllowed, 0) BRAllowable,
		VPN.NetworkName,
		BPN.NetworkName SubNetwork
		
FROM #ProviderNetworkEventLog_Filtered PNELF
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BILL_HDR' ELSE 'if_BILL_HDR(@RunPostingGroupAuditId)' END+' BH 
	ON BH.OdsCustomerId = PNELF.OdsCustomerId  AND BH.BillIDNo = PNELF.BillIdNo
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CMT_HDR' ELSE 'if_CMT_HDR(@RunPostingGroupAuditId)' END+' CH 
	ON CH.OdsCustomerId = BH.OdsCustomerId  AND CH.CMT_HDR_IDNo = BH.CMT_HDR_IDNo
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CLAIMANT' ELSE 'if_CLAIMANT(@RunPostingGroupAuditId)' END+' CLMT 
	ON CLMT.OdsCustomerId = CH.OdsCustomerId  AND CLMT.CmtIDNo = CH.CmtIDNo
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CLAIMS' ELSE 'if_CLAIMS(@RunPostingGroupAuditId)' END+' CLM 
	ON CLM.OdsCustomerId = CLMT.OdsCustomerId  AND CLM.ClaimIDNo = CLMT.ClaimIDNo
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'prf_Office' ELSE 'if_prf_Office(@RunPostingGroupAuditId)' END+' OFC 
	ON OFC.OdsCustomerId = CLM.OdsCustomerId  AND OFC.CompanyId = CLM.CompanyID
     AND OFC.OfficeId = CLM.OfficeIndex
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'prf_COMPANY' ELSE 'if_prf_COMPANY(@RunPostingGroupAuditId)' END+' CPNY 
	ON CPNY.OdsCustomerId = OFC.OdsCustomerId  AND CPNY.CompanyId = OFC.CompanyId
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Vpn' ELSE 'if_Vpn(@RunPostingGroupAuditId)' END+' VPN 
	ON VPN.OdsCustomerId = PNELF.OdsCustomerId  AND VPN.VpnId = PNELF.NetworkId
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BillsProviderNetwork' ELSE 'if_BillsProviderNetwork(@RunPostingGroupAuditId)' END+' BPN 
	ON BPN.OdsCustomerId = PNELF.OdsCustomerId  AND BPN.BillIdNo = PNELF.BillIdNo
	AND BPN.NetworkId = PNELF.NetworkId
	AND PNELF.EventId IN(10,16)
	AND PNELF.ProcessInfo = 2;

TRUNCATE TABLE stg.VPN_Monitoring_NetworkSubmitted;
--2.2 Find ALL bills repriced even if repriced a multiplicity of times
INSERT INTO stg.VPN_Monitoring_NetworkSubmitted
SELECT  PNELF.StartOfMonth ,
        PNELF.OdsCustomerId ,
        PNELF.ReportYear ,
        PNELF.ReportMonth ,
        PNELF.SOJ ,
        PNELF.NetworkName ,
        PNELF.BillType ,
        PNELF.CV_Type ,
        PNELF.Company ,
        PNELF.Office ,
        COUNT(DISTINCT CASE WHEN PNELF.EventId = 11 THEN PNELF.BillIdNo END) AS BillsCount ,
		COUNT(DISTINCT (CASE WHEN WEAH.WeekEndsAndHolidayId IS NOT NULL AND PNELF.EventId = 11 THEN billIDNo END)) + 0.0 AS BillsCount_WeekEnd,
		COUNT(DISTINCT (CASE WHEN WEAH.WeekEndsAndHolidayId IS NULL AND PNELF.EventId = 11 THEN  billIDNo END)) + 0.0 AS BillsCount_WeekDay,
		COUNT(DISTINCT CASE WHEN PNELF.EventId IN(10,16) AND PNELF.ProcessInfo = 2 THEN PNELF.BillIdNo END) AS BillsRePriced,
		COUNT(DISTINCT CASE WHEN WEAH.WeekEndsAndHolidayId IS NOT NULL AND PNELF.EventId IN(10,16) AND PNELF.ProcessInfo = 2 THEN PNELF.BillIdNo END) AS BillsRePriced_WeekEnd,
		COUNT(DISTINCT CASE WHEN WEAH.WeekEndsAndHolidayId IS NULL AND PNELF.EventId IN(10,16) AND PNELF.ProcessInfo = 2 THEN PNELF.BillIdNo END) AS BillsRePriced_WeekDay,
        SUM(CASE WHEN PNELF.EventId = 11 THEN PNELF.ProviderCharges ELSE 0 END) AS ProviderCharges ,
		SUM(CASE WHEN WEAH.WeekEndsAndHolidayId IS NOT NULL AND PNELF.EventId = 11 THEN PNELF.ProviderCharges ELSE 0 END) AS ProviderCharges_WeekEnd ,
		SUM(CASE WHEN WEAH.WeekEndsAndHolidayId IS NULL AND PNELF.EventId = 11 THEN PNELF.ProviderCharges ELSE 0 END) AS ProviderCharges_WeekDay ,
        SUM(CASE WHEN PNELF.EventId = 11 THEN PNELF.BRAllowable ELSE 0 END) AS BRAllowable ,
		SUM(CASE WHEN WEAH.WeekEndsAndHolidayId IS NOT NULL AND PNELF.EventId = 11 THEN PNELF.BRAllowable ELSE 0 END) AS BRAllowable_WeekEnd ,
		SUM(CASE WHEN WEAH.WeekEndsAndHolidayId IS NULL AND PNELF.EventId = 11 THEN PNELF.BRAllowable ELSE 0 END) AS BRAllowable_WeekDay

FROM  stg.VPN_Monitoring_ProviderNetworkEventLog_Filtered PNELF
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'WeekEndsAndHolidays' ELSE'if_WeekEndsAndHolidays(@RunPostingGroupAuditId)' END+' WEAH
		ON PNELF.OdsCustomerId = WEAH.OdsCustomerId
		AND CAST(PNELF.LogDate AS DATE) = CAST(WEAH.DayOfWeekDate AS DATE)
WHERE PNELF.EventId = 11 
OR (PNELF.EventId IN (10,16) AND PNELF.ProcessInfo = 2)

GROUP BY PNELF.StartOfMonth ,
        PNELF.OdsCustomerId ,
        PNELF.ReportYear ,
        PNELF.ReportMonth ,
        PNELF.SOJ ,
        PNELF.NetworkName ,
        PNELF.BillType ,
        PNELF.CV_Type ,
        PNELF.Company ,
        PNELF.Office;'
	
EXEC(@SQLScript);

END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.VPN_Monitoring_TAT') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.VPN_Monitoring_TAT
GO

CREATE PROCEDURE dbo.VPN_Monitoring_TAT(    
@SourceDatabaseName VARCHAR(50)='AcsOds',
@StartDate AS DATETIME,
@EndDate AS DATETIME,
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 0,
@TargetDatabaseName VARCHAR(50)='ReportDB')
AS
BEGIN
--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@StartDate DATETIME = '2014-03-01 00:00:00.000' , @EndDate DATETIME = '2015-03-31 00:00:00.000',@RunType INT = 0,@if_Date AS DATETIME = GETDATE()

DECLARE @SQLScript VARCHAR(MAX) = '
DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;

'+CASE WHEN @OdsCustomerID <> 0 THEN 
'DELETE FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_TAT_Output
WHERE OdsCustomerId = '+CAST(@OdsCustomerID as VARCHAR(5))+' AND StartOfMonth BETWEEN '''+CONVERT(VARCHAR(10),@StartDate,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+''';' ELSE 

'DELETE FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_TAT_Output
WHERE StartOfMonth BETWEEN '''+CONVERT(VARCHAR(10),@StartDate,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+''';'  END+'
										
;WITH cte_ProviderNetworkEventLog AS(
SELECT  PNEL1.OdsCustomerId ,
		PNEL1.BillIDNo ,
        PNEL1.ClaimIdNo ,
        PNEL1.NetworkId ,
        PNEL1.LogDate AS SentDate ,
        MIN(PNEL2.Logdate) AS ReceivedDate ,
        -- Count Number of weekend and Holidays between the send and recieve dates
        DATEDIFF(hh, PNEL1.LogDate, MIN(PNEL2.Logdate)) TATInHours, 
       (SELECT	COUNT(DISTINCT DayOfWeekDate) 
        FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'WeekEndsAndHolidays' ELSE 'if_WeekEndsAndHolidays(@RunPostingGroupAuditId)' END+ ' 
        WHERE dayofweekdate BETWEEN PNEL1.LogDate AND  MIN(PNEL2.Logdate)
			AND OdsCustomerId  = PNEL1.OdsCustomerId) TatWeekends, 
        DATEDIFF(hh, PNEL1.LogDate, MIN(PNEL2.Logdate)) - 24*(SELECT	COUNT(DISTINCT DayOfWeekDate) 
												   FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'WeekEndsAndHolidays' ELSE 'if_WeekEndsAndHolidays(@RunPostingGroupAuditId)' END+ ' 
												   WHERE dayofweekdate BETWEEN PNEL1.LogDate AND  MIN(PNEL2.Logdate)
													AND OdsCustomerId  = PNEL1.OdsCustomerId) TatWithoutWeekends,
        CASE WHEN PNEL2.ProcessInfo <> 2 THEN ''Non'' ELSE ''Par'' END AS ParNonPar ,
        ISNULL(BPN.NetworkName,'''') AS SubNetwork ,
        BH.CMT_HDR_IDNo,
        BH.CreateDate BillCreateDate ,
        BH.AmtCharged ,
        CASE WHEN BH.[flags] & 4096 > 0 THEN ''UB-04'' ELSE ''CMS-1500''
        END BillType

FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'ProviderNetworkEventLog' ELSE 'if_ProviderNetworkEventLog(@RunPostingGroupAuditId)' END+ ' PNEL1
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BILL_HDR' ELSE 'if_BILL_HDR(@RunPostingGroupAuditId)' END+' bh 
	ON BH.OdsCustomerId = PNEL1.OdsCustomerId
	AND BH.BillIDNo = PNEL1.BillIdNo
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BillsProviderNetwork' ELSE 'if_BillsProviderNetwork(@RunPostingGroupAuditId)' END+' bpn 
	ON BPN.OdsCustomerId = PNEL1.OdsCustomerId
	AND BPN.BillIdNo = PNEL1.BillIdNo
	AND BPN.NetworkId = PNEL1.NetworkId
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'ProviderNetworkEventLog' ELSE 'if_ProviderNetworkEventLog(@RunPostingGroupAuditId)' END+ ' PNEL2
	ON PNEL1.OdsCustomerId = PNEL2.OdsCustomerId
	AND PNEL1.BillIDNo = PNEL2.BillIDNo
    AND PNEL1.NetworkId = PNEL2.NetworkId
    AND PNEL2.EventID = 10 -- Bill Received From Provider Network
    AND PNEL1.LogDate <= PNEL2.LogDate -- LogDate less that receivedate

WHERE   '+CASE WHEN @OdsCustomerId <> 0 THEN ' PNEL1.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ' ELSE '' END + ' PNEL1.EventID = 11 -- Bill Sent To Provider Network
        AND PNEL1.LogDate BETWEEN '''+CONVERT(VARCHAR(10),@StartDate,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+'''
GROUP BY PNEL1.OdsCustomerId ,
		PNEL1.BillIDNo ,
        PNEL1.ClaimIdNo ,
        PNEL1.NetworkId ,
        BPN.NetworkName,
        PNEL1.LogDate ,
        CASE WHEN PNEL2.ProcessInfo <> 2 THEN ''Non''  ELSE ''Par''  END ,
        BH.CMT_HDR_IDNo,
        BH.CreateDate,
        BH.AmtCharged ,
        CASE WHEN BH.[flags] & 4096 > 0 THEN ''UB-04'' ELSE ''CMS-1500'' END)
         
-- Multiple receives per send?  Lets ignore everything but the last receive.       
,cte_Multiplereceives AS(
SELECT  OdsCustomerId,
		BillIDNo ,
		NetworkId ,
		SentDate ,
		COUNT(*) Total ,
		MIN(ReceivedDate) ReceivedDate
FROM cte_ProviderNetworkEventLog
GROUP BY OdsCustomerId,
		BillIDNo ,
		NetworkId ,
		SentDate
HAVING COUNT(*) > 1)

INSERT INTO '+@TargetDatabaseName+'.dbo.VPN_Monitoring_TAT_Output
SELECT  PNEL.OdsCustomerId,
		DATEADD(month, DATEDIFF(month, 0, PNEL.SentDate), 0) AS StartOfMonth ,
        C.CustomerName AS Customer ,
        PNEL.BillIdNo ,
        PNEL.ClaimIdNo ,
        CLMT.CmtStateOfJurisdiction AS SOJ ,
        PNEL.NetworkId ,
        VPN.NetworkName ,
        PNEL.SentDate ,
        PNEL.ReceivedDate ,
        CASE WHEN PNEL.ReceivedDate IS NULL THEN DATEDIFF(hh, PNEL.SentDate, GETDATE()) ELSE 0 END AS HoursLockedToVPN, 
        PNEL.TATInHours,
        PNEL.TatWithoutWeekends,
		PNEL.BillCreateDate ,
        PNEL.ParNonPar ,
        PNEL.SubNetwork ,
        PNEL.AmtCharged ,
        PNEL.BillType , 
        CASE WHEN PNEL.TatWithoutWeekends < 24 THEN ''24''
             WHEN PNEL.TatWithoutWeekends >= 24  AND PNEL.TatWithoutWeekends < 48 THEN ''48''
             WHEN PNEL.TatWithoutWeekends >= 48  AND PNEL.TatWithoutWeekends < 72 THEN ''72''
             WHEN PNEL.TatWithoutWeekends >= 72  AND PNEL.TatWithoutWeekends < 96 THEN ''96''
             WHEN PNEL.TatWithoutWeekends >= 96  AND PNEL.TatWithoutWeekends < 120 THEN ''120''
             ELSE ''Over120''    END AS Bucket,
        CASE WHEN PNEL.AmtCharged < 5000 THEN ''Less Than 5000''
             WHEN PNEL.AmtCharged >= 5000  AND PNEL.AmtCharged < 10000 THEN ''Less Than 10000''
             WHEN PNEL.AmtCharged >= 10000 AND PNEL.AmtCharged < 20000 THEN ''Less Than 20000''
             WHEN PNEL.AmtCharged >= 20000 AND PNEL.AmtCharged < 30000 THEN ''Less Than 30000''
             WHEN PNEL.AmtCharged >= 30000 AND PNEL.AmtCharged < 40000 THEN ''Less Than 40000''
             WHEN PNEL.AmtCharged >= 40000 AND PNEL.AmtCharged < 50000 THEN ''Less Than 50000''
             ELSE ''Over 50000'' END AS ValueBucket,
         GETDATE() AS RunDate

FROM cte_ProviderNetworkEventLog PNEL
INNER JOIN ' +@SourceDatabaseName + '.adm.Customer C
	ON PNEL.OdsCustomerId = C.CustomerId
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CMT_HDR' ELSE'if_CMT_HDR(@RunPostingGroupAuditId)' END+' CH 
	ON CH.OdsCustomerId = PNEL.OdsCustomerId
	AND CH.CMT_HDR_IDNo = PNEL.CMT_HDR_IDNo
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CLAIMANT' ELSE'if_CLAIMANT(@RunPostingGroupAuditId)' END+' CLMT 
	ON CLMT.OdsCustomerId = CH.OdsCustomerId
	AND CLMT.CmtIDNo = CH.CmtIDNo
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Vpn' ELSE'if_Vpn(@RunPostingGroupAuditId)' END+' VPN 
	ON PNEL.OdsCustomerId = VPN.OdsCustomerId
	AND PNEL.NetworkId = VPN.VpnId
LEFT OUTER JOIN cte_Multiplereceives MLR -- exclude later receives from multiple receives
	ON PNEL.OdsCustomerId = MLR.OdsCustomerId
	AND PNEL.BillIDNo = MLR.BillIDNo
	AND PNEL.NetworkId = MLR.NetworkId
	AND PNEL.SentDate = MLR.SentDate
	AND PNEL.ReceivedDate <> MLR.ReceivedDate

WHERE MLR.BillIDNo IS NULL-- exclude later receives from multiple receives
	AND PNEL.SentDate < PNEL.ReceivedDate'
	

EXEC(@SQLScript);

END
GO
