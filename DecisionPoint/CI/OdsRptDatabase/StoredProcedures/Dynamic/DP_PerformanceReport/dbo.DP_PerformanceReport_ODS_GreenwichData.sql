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
