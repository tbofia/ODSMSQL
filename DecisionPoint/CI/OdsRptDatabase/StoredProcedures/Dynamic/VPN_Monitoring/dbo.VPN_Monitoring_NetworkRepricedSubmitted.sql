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
