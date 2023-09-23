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
