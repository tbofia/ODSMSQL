IF OBJECT_ID ('dbo.vwMASTER_COVERAGE_REPORT', 'V') IS NOT NULL
DROP VIEW dbo.vwMASTER_COVERAGE_REPORT;
GO
CREATE VIEW dbo.vwMASTER_COVERAGE_REPORT
AS
SELECT StartOfMonth
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
      ,PartialDuplicateBills
      ,Dup_Lines_Count
      ,Duplicate_Reductions
      ,BenefitsExhausted_Bills_Count
      ,BenefitsExhausted_Lines_Count
      ,BenefitsExhausted_Reductions
      ,Analyst_Reductions
      ,Fee_Schedule_Reductions
      ,Benchmark_Reductions
      ,CTG_Reductions
      ,Total_Bill_Review_Reductions
      ,VPN_Reductions
      ,Override_Impact
      ,Total_Reductions
      ,Total_Final_Allowed
      ,DuplicateBillsCount
	  ,RunDate AS RunTime
      ,LastUpdate
      ,ReportTypeID
FROM dbo.DP_PerformanceReport_Output T
WHERE StartOfMonth < (SELECT DATEADD(MM,-1,EOMONTH(MAX(Job_StartDate))) FROM adm.ReportJobAudit WHERE ReportId = 1) 
  
  
GO

