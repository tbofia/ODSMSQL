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
