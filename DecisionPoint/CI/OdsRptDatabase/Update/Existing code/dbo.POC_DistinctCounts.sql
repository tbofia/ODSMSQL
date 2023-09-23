IF OBJECT_ID('dbo.DP_PerformanceReport', 'P') IS NOT NULL
    DROP PROCEDURE dbo.DP_PerformanceReport
GO

CREATE PROCEDURE dbo.DP_PerformanceReport(
	@Customer NVARCHAR(200) = 'Ace',
	@Year VARCHAR(4) = 'All',
	@Month VARCHAR(4) = 'All',
	@Company VARCHAR(50) = 'All',
	@Office VARCHAR(40) = 'All',
	@SOJ VARCHAR(4) = 'All',
	@Coverage VARCHAR(20) = 'All',
	@Form_Type VARCHAR(12) = 'All',
	@ReportTypeID INT = 1)
AS
BEGIN
-- Test Paramaters
-- DECLARE @Customer NVARCHAR(200) = 'Ace',	@Year VARCHAR(4) = 'All',	@Month VARCHAR(4) = 'All',	@Company VARCHAR(50) = 'All',	@Office VARCHAR(40) = 'All',	@SOJ VARCHAR(4) = 'All',	@Coverage VARCHAR(20) = 'All',	@Form_Type VARCHAR(12) = 'All',	@ReportTypeID INT = 1

-- 0.1 Filter Data Using Parameters
;WITH cte_DP_PerformanceReport_Filtered AS(
SELECT StartOfMonth
      ,Customer
      ,CASE WHEN @Year  <> 'All' THEN CAST(Year AS VARCHAR(4)) ELSE @Year END AS Year
      ,CASE WHEN @Month  <> 'All' THEN CAST(Month AS VARCHAR(4)) ELSE @Month END AS Month
      ,CASE WHEN @Company  <> 'All' THEN Company ELSE @Company END AS Company
      ,CASE WHEN @Office  <> 'All' THEN Office ELSE @Office END AS Office
      ,CASE WHEN @SOJ  <> 'All' THEN SOJ ELSE @SOJ END AS SOJ
      ,CASE WHEN @Coverage  <> 'All' THEN Coverage ELSE @Coverage END AS Coverage
      ,CASE WHEN @Form_Type  <> 'All' THEN Form_Type ELSE @Form_Type END AS Form_Type
      ,Claims_List
      ,Bill_List
      ,BillsWithOneOrMoreDuplicateLines_List
      ,PartialDuplicateBills_List
      ,DuplicateBills_List
      ,BenefitsExhausted_Bills_List
      ,Total_Lines
      ,Total_Units
      ,Total_Provider_Charges
      ,Total_Final_Allowed
      ,Total_Reductions
      ,Total_Bill_Review_Reductions
      ,Dup_Lines_Count
      ,Duplicate_Reductions
      ,BenefitsExhausted_Lines_Count
      ,BenefitsExhausted_Reductions
      ,Analyst_Reductions
      ,Fee_Schedule_Reductions
      ,Benchmark_Reductions
      ,CTG_Reductions
      ,VPN_Reductions
      ,Override_Impact
      ,ReportTypeID
      ,RunDate
      ,LastUpdate
 
  FROM dbo.DP_PerformanceReport_Output R1
  WHERE Customer = @Customer
	AND CAST(Year AS VARCHAR(4)) = CASE WHEN @Year  = 'All' THEN CAST(Year AS VARCHAR(4)) ELSE @Year END
	AND CAST(Month AS VARCHAR(4)) = CASE WHEN @Month  = 'All' THEN CAST(Month AS VARCHAR(4)) ELSE @Month END
	AND Company = CASE WHEN @Company  = 'All' THEN Company ELSE @Company END
	AND Office = CASE WHEN @Office  = 'All' THEN Office ELSE @Office END
	AND SOJ = CASE WHEN @SOJ  = 'All' THEN SOJ ELSE @SOJ END
	AND Coverage = CASE WHEN @Coverage  = 'All' THEN Coverage ELSE @Coverage END
	AND Form_Type = CASE WHEN @Form_Type  = 'All' THEN Form_Type ELSE @Form_Type END
	AND ReportTypeID = @ReportTypeID),

-- 0.2 Rollup data Using Parameters
-- Collapse Lists
cte_getdistinctlists AS(
SELECT StartOfMonth
	,Customer
	,Year
	,Month
	,Company
	,Office
	,SOJ
	,Coverage
	,Form_Type
	,dbo.GetDistinctList(STUFF((SELECT DISTINCT ', ' + CAST(Claims_List AS VARCHAR(MAX))
			FROM cte_DP_PerformanceReport_Filtered R2 
			WHERE R1.StartOfMonth = R2.StartOfMonth	AND R1.Customer = R2.Customer AND R1.Year = R2.Year	AND R1.Month = R2.Month	AND R1.Company = R2.Company	AND R1.Office = R2.Office AND R1.SOJ = R2.SOJ AND R1.Coverage = R2.Coverage AND R1.Form_Type  = R2.Form_Type FOR XML PATH('')), 1, 2, ''),',') AS Claims_List
	,dbo.GetDistinctList(STUFF((SELECT DISTINCT ', ' + CAST(Bill_List AS VARCHAR(MAX))
			FROM cte_DP_PerformanceReport_Filtered R2 
			WHERE R1.StartOfMonth = R2.StartOfMonth	AND R1.Customer = R2.Customer AND R1.Year = R2.Year	AND R1.Month = R2.Month	AND R1.Company = R2.Company	AND R1.Office = R2.Office AND R1.SOJ = R2.SOJ AND R1.Coverage = R2.Coverage AND R1.Form_Type  = R2.Form_Type FOR XML PATH('')), 1, 2, ''),',') AS Bill_List
	,dbo.GetDistinctList(STUFF((SELECT DISTINCT ', ' + CAST(BillsWithOneOrMoreDuplicateLines_List AS VARCHAR(MAX))
			FROM cte_DP_PerformanceReport_Filtered R2 
			WHERE R1.StartOfMonth = R2.StartOfMonth	AND R1.Customer = R2.Customer AND R1.Year = R2.Year	AND R1.Month = R2.Month	AND R1.Company = R2.Company	AND R1.Office = R2.Office AND R1.SOJ = R2.SOJ AND R1.Coverage = R2.Coverage AND R1.Form_Type  = R2.Form_Type FOR XML PATH('')), 1, 2, ''),',') AS BillsWithOneOrMoreDuplicateLines_List
	,dbo.GetDistinctList(STUFF((SELECT DISTINCT ', ' + CAST(PartialDuplicateBills_List AS VARCHAR(MAX))
			FROM cte_DP_PerformanceReport_Filtered R2 
			WHERE R1.StartOfMonth = R2.StartOfMonth	AND R1.Customer = R2.Customer AND R1.Year = R2.Year	AND R1.Month = R2.Month	AND R1.Company = R2.Company	AND R1.Office = R2.Office AND R1.SOJ = R2.SOJ AND R1.Coverage = R2.Coverage AND R1.Form_Type  = R2.Form_Type FOR XML PATH('')), 1, 2, ''),',') AS PartialDuplicateBills_List
	,dbo.GetDistinctList(STUFF((SELECT DISTINCT ', ' + CAST(DuplicateBills_List AS VARCHAR(MAX))
			FROM cte_DP_PerformanceReport_Filtered R2 
			WHERE R1.StartOfMonth = R2.StartOfMonth	AND R1.Customer = R2.Customer AND R1.Year = R2.Year	AND R1.Month = R2.Month	AND R1.Company = R2.Company	AND R1.Office = R2.Office AND R1.SOJ = R2.SOJ AND R1.Coverage = R2.Coverage AND R1.Form_Type  = R2.Form_Type FOR XML PATH('')), 1, 2, ''),',') AS DuplicateBills_List
	,dbo.GetDistinctList(STUFF((SELECT DISTINCT ', ' + CAST(BenefitsExhausted_Bills_List AS VARCHAR(MAX))
			FROM cte_DP_PerformanceReport_Filtered R2 
			WHERE R1.StartOfMonth = R2.StartOfMonth	AND R1.Customer = R2.Customer AND R1.Year = R2.Year	AND R1.Month = R2.Month	AND R1.Company = R2.Company	AND R1.Office = R2.Office AND R1.SOJ = R2.SOJ AND R1.Coverage = R2.Coverage AND R1.Form_Type  = R2.Form_Type FOR XML PATH('')), 1, 2, ''),',') AS BenefitsExhausted_Bills_List

FROM cte_DP_PerformanceReport_Filtered R1
GROUP BY StartOfMonth
      ,Customer
      ,Year
      ,Month
      ,Company
      ,Office
      ,SOJ
      ,Coverage
      ,Form_Type
),
-- Rollup Aggregates.
cte_DP_PerformanceReport_RolledUp AS(
SELECT StartOfMonth
      ,Customer
      ,Year
      ,Month
      ,Company
      ,Office
      ,SOJ
      ,Coverage
      ,Form_Type
      ,SUM(Total_Lines) AS Total_Lines
      ,SUM(Total_Units) AS Total_Units
      ,SUM(Total_Provider_Charges) AS Total_Provider_Charges
      ,SUM(Total_Final_Allowed) AS Total_Final_Allowed
      ,SUM(Total_Reductions) AS Total_Reductions
      ,SUM(Total_Bill_Review_Reductions) AS Total_Bill_Review_Reductions
      ,SUM(Dup_Lines_Count) AS Dup_Lines_Count
      ,SUM(Duplicate_Reductions) AS Duplicate_Reductions
      ,SUM(BenefitsExhausted_Lines_Count) AS BenefitsExhausted_Lines_Count
      ,SUM(BenefitsExhausted_Reductions) AS BenefitsExhausted_Reductions
      ,SUM(Analyst_Reductions) AS Analyst_Reductions
      ,SUM(Fee_Schedule_Reductions) AS Fee_Schedule_Reductions
      ,SUM(Benchmark_Reductions) AS Benchmark_Reductions
      ,SUM(CTG_Reductions) AS CTG_Reductions
      ,SUM(VPN_Reductions) AS VPN_Reductions
      ,SUM(Override_Impact) AS Override_Impact
      ,MAX(RunDate) RunDate
      ,MAX(LastUpdate) LastUpdate
 
  FROM cte_DP_PerformanceReport_Filtered R1
  GROUP BY StartOfMonth
      ,Customer
      ,Year
      ,Month
      ,Company
      ,Office
      ,SOJ
      ,Coverage
      ,Form_Type)
SELECT 
	   R1.StartOfMonth
      ,R1.Customer
      ,R1.Year
      ,R1.Month
      ,R1.Company
      ,R1.Office
      ,R1.SOJ
      ,R1.Coverage
      ,R1.Form_Type
	  ,LEN(R2.Claims_List)-LEN(REPLACE(R2.Claims_List,',',''))+1 Total_Claims
      ,LEN(R2.Bill_List)-LEN(REPLACE(R2.Bill_List,',',''))+1 Total_Bills
      ,R1.Total_Lines
      ,R1.Total_Units
      ,R1.Total_Provider_Charges
      ,R1.Total_Final_Allowed
      ,R1.Total_Reductions
      ,R1.Total_Bill_Review_Reductions
      ,LEN(R2.BillsWithOneOrMoreDuplicateLines_list)-LEN(REPLACE(R2.BillsWithOneOrMoreDuplicateLines_list,',',''))+1 BillsWithOneOrMoreDuplicateLinesCount
      ,(LEN(R2.PartialDuplicateBills_List)-LEN(REPLACE(R2.PartialDuplicateBills_List,',',''))+1)-(LEN(R2.DuplicateBills_List)-LEN(REPLACE(R2.DuplicateBills_List,',',''))+1) PartialDuplicateBills
      ,LEN(R2.DuplicateBills_List)-LEN(REPLACE(R2.DuplicateBills_List,',',''))+1 DuplicateBillsCount
      ,R1.Dup_Lines_Count
      ,R1.Duplicate_Reductions
      ,LEN(R2.BenefitsExhausted_Bills_List)-LEN(REPLACE(R2.BenefitsExhausted_Bills_List,',',''))+1 BenefitsExhausted_Bills_Count
      ,R1.BenefitsExhausted_Lines_Count
      ,R1.BenefitsExhausted_Reductions
      ,R1.Analyst_Reductions
      ,R1.Fee_Schedule_Reductions
      ,R1.Benchmark_Reductions
      ,R1.CTG_Reductions
      ,R1.VPN_Reductions
      ,R1.Override_Impact 
      ,R1.RunDate
      ,R1.LastUpdate
FROM cte_DP_PerformanceReport_RolledUp R1
CROSS APPLY cte_getdistinctlists R2;
      
      
END
