IF OBJECT_ID ('dbo.vwProviderAnalysisReport', 'V') IS NOT NULL
DROP VIEW dbo.vwProviderAnalysisReport
GO

CREATE VIEW dbo.vwProviderAnalysisReport AS
SELECT 
Bl.ClientCode+'_'+Convert(varchar(100),Bl.BillSeq ) as BillId,
Bl.ClientCode+'_'+Convert(varchar(100),Bl.BillSeq )+'_'+Convert(varchar(100),Bl.LineSeq ) AS LineNumber,

bl.BillSeq,
bl.ClientCode,
bl.Lineseq, 
--bh.CVType, 
bl.BillLineType, 
bl.DateofService, 
bl.Charged, 
bl.Allowed, 
bl.Adjustment, 
bl.FormType,
bl.FormType AS DFFormType, 
bl.SubFormType,
bl.SubFormType AS DFSubFormType,
bl.ExceptionFlag,
bl.CodeType, 
bl.Code,
bl.Code AS DFCode, 
bl.CodeDescription, 
bl.Category,
bl.Category AS DFCategory, 
bl.SubCategory, 
bl.SubCategory AS DFSubCategory, 
bl.VisitType, 
bl.BillInjuryDescription,
ch.ClaimID,
ch.ClaimSysSubSet+'_'+Convert(varchar(100),ch.ClaimSeq ) as ClaimNo,

ch.ClaimSeq,
ch.ClaimSysSubSet,
ch.DOSTenureinDays AS ActualTenure,
ExpectedTenureInDays AS ExpectedTenureinDays,
ch.StateofJurisdiction,
ch.Jurisdiction,
ch.Jurisdiction AS DFJurisdiction,
ch.StateofJurisdiction AS DFStateofJurisdiction,
ch.CustomerName,
ch.InjuryDescription,
ch.InjuryDescription AS DFInjuryDescription,
ch.DerivedCVType,
ch.DerivedCVDesc,
ch.DerivedCVDesc AS DFCoverageLine,
ch.MSADesignation,
ch.MinimumDateofService,
ch.MaximumDateofService,
p.ProviderTIN,
p.ProviderName,
p.ProviderName AS DFProviderName,
p.ProviderClusterName,
p.ProviderClusterName AS DFProviderClusterName, 
--p.ClusterSpecialty,
p.ProviderZip,
p.ProviderSubSet+'_'+CONVERT(VARCHAR(100),p.ProviderSeq ) AS ProviderNo,
p.ProviderSeq,
p.ProviderSubSet,
p.OdsCustomerId,
p.Specialty

FROM 
dbo.ProviderAnalyticsClaim ch 
INNER JOIN dbo.ProviderAnalyticsBillLine bl 
ON ch.OdsCustomerId = bl.OdsCustomerId
AND ch.ClaimSeq = bl.ClaimSeq
AND ch.ClaimSysSubSet = bl.ClaimSysSubSet
INNER JOIN dbo.ProviderAnalyticsProvider p 
ON p.OdsCustomerId = bl.OdsCustomerId
AND p.ProviderSeq = bl.ProviderSeq
AND p.ProviderSubSet = bl.ProviderSubSet

WHERE 
	CONVERT(DATE,bl.DateofService) BETWEEN CONVERT(VARCHAR(25),DATEADD(MONTH,-24,DATEADD(MONTH, DATEDIFF(MONTH, -1 , GETDATE()) - 1, 0)),110) 	
	AND DATEADD(MONTH,DATEDIFF(MONTH,-1,GETDATE())-1,-1)

GO

IF OBJECT_ID ('dbo.vwProviderNetworkReportOutput', 'V') IS NOT NULL
DROP VIEW dbo.vwProviderNetworkReportOutput;
GO

CREATE VIEW dbo.vwProviderNetworkReportOutput
AS 
SELECT CustomerName
      ,ClientCode
      ,ClaimSysSubset
      ,ReportMonth
      ,ReportYear
      ,ProductCode
      ,ProductCodeDescription
      ,Jurisdiction
      ,JurisdictionDescription
      ,PPONetworkID
      ,PPONetworkName
      ,PlaceOfService
      ,POSDescription
      ,TypeOfBill
      ,TOBDescription
      ,PostDateMonth
      ,BillCount
      ,NetworkBillCount
	  ,TotalBillsRepriced
      ,BilledCharges
      ,NetWorkCharges
      ,SmartAdvisorAllowed
      ,TotalNetworkCharges
      ,SmartAdvisorAllowedInNetwork
      ,PPOReEvalCredits
      ,PPOReEvalSavings
      ,NetWorkAdjustment
      ,NetNetWorkAdjustment
      ,TotalPPOAllowed
      ,RunDate
	  ,GETDATE() AS ReportingDate
--First Day of PostDateMonth defined
   	  ,CAST(
				CAST(DATEPART(MONTH,PostDateMonth) AS VARCHAR(2)) 
			+ '/'
			+ '01/'
			+ CAST(DATEPART(YEAR ,PostDateMonth) AS VARCHAR(4)) 
			AS DATE) AS PostDateMonthFirstDay 

-- Reporting Month defined
	  ,CAST(
	         CAST(DATEPART(MONTH,DATEADD(MONTH,-1,GETDATE())) AS VARCHAR(2)) 
		   + '/'
		   + '01/'
	       + CAST(DATEPART(YEAR ,DATEADD(MONTH,-1,GETDATE())) AS VARCHAR(4)) 
		 AS DATE) AS ReportingMonthDefined

-- "First day of prior month" defined 
-- If it is January, the "Prior Month" would be November. This is because the "Reporting Month" is the last complete month (December).
	  ,CAST(
	         CAST(DATEPART(MONTH,DATEADD(MONTH,-2,GETDATE())) AS VARCHAR(2)) 
		   + '/'
		   + '01/'
	       + CAST(DATEPART(YEAR ,DATEADD(MONTH,-2,GETDATE())) AS VARCHAR(4)) 
		 AS DATE) AS PriorMonthDefined

-- Reporting Month Flagged (Last month with complete data) (last month essentially) 
,CASE 
	      WHEN 
		  CAST(
				CAST(DATEPART(MONTH,PostDateMonth) AS VARCHAR(2)) 
			+ '/'
			+ '01/'
			+ CAST(DATEPART(YEAR ,PostDateMonth) AS VARCHAR(4)) 
			AS DATE)
		       = 
		  CAST(
				CAST(DATEPART(MONTH,DATEADD(MONTH,-1,GETDATE())) AS VARCHAR(2)) 
			+ '/'
			+ '01/'
			+ CAST(DATEPART(YEAR ,DATEADD(MONTH,-1,GETDATE())) AS VARCHAR(4)) 
			AS DATE)
			 THEN 1
		ELSE NULL
	   END AS ReportingMonth


-- If "First Day of PostDateMonth" = "first day of prior month" then flag that as "Prior Month" 
	  ,CASE 
	      WHEN 
		  CAST(
				CAST(DATEPART(MONTH,PostDateMonth) AS VARCHAR(2)) 
			+ '/'
			+ '01/'
			+ CAST(DATEPART(YEAR ,PostDateMonth) AS VARCHAR(4)) 
			AS DATE)
		       = 
		  CAST(
				CAST(DATEPART(MONTH,DATEADD(MONTH,-2,GETDATE())) AS VARCHAR(2)) 
			+ '/'
			+ '01/'
			+ CAST(DATEPART(YEAR ,DATEADD(MONTH,-2,GETDATE())) AS VARCHAR(4)) 
			AS DATE)
			 THEN 1
		ELSE NULL
	   END AS PriorMonth

-- PRIOR 3 MONTHS   

-- Logic is as follows:
	-- If the first day of the post date month is between the first day of the "5th month prior to today" and the "Last Day of the 2th month prior to today", 
	-- then flag it as Prior3Months 
	-- "Last Day of the 2th month prior to today" is defined by subtracting one day from the first day of last month. 

-- First Day of the post date month 
 ,CASE 
    WHEN 
			CAST(
					CAST(DATEPART(MONTH,PostDateMonth) AS VARCHAR(2)) 
				+ '/'
				+ '01/'
				+ CAST(DATEPART(YEAR ,PostDateMonth) AS VARCHAR(4)) 
				AS DATE)
   BETWEEN 
 -- First Day of 5 months ago. 
				   CAST(
						  CAST(DATEPART(MONTH,DATEADD(MONTH,-5,GETDATE())) AS VARCHAR(2)) 
						+ '/'
						+ '01/'
						+ CAST(DATEPART(YEAR,DATEADD(MONTH,-5,GETDATE())) AS VARCHAR(4))
						AS DATE)
   AND 
 --Last Day of whatever month we were in 2 months ago 
              --Subtracting one day from the first day of last month
			     DATEADD(DAY,-1,
				  CAST(
						  CAST(DATEPART(MONTH,DATEADD(MONTH,-1,GETDATE())) AS VARCHAR(2)) 
						+ '/'
						+ '01/'
						+ CAST(DATEPART(YEAR,DATEADD(MONTH,-1,GETDATE())) AS VARCHAR(4))
						AS DATE) 
					  ) 
   THEN 1 
   ELSE NULL 
   END AS ThreeMonthsPrior


-- PRIOR 12 MONTHS   

-- Logic is as follows:
	-- If the first day of the post date month is between the first day of the 13th month prior to today and the Last Day of Prior Month, 
	-- then flag it as Prior12Months 
	-- "Last Day of Prior Month" is defined by subtracting one day from the first day this month. 

-- First Day of the post date month 
 ,CASE 
    WHEN 
			CAST(
					CAST(DATEPART(MONTH,PostDateMonth) AS VARCHAR(2)) 
				+ '/'
				+ '01/'
				+ CAST(DATEPART(YEAR ,PostDateMonth) AS VARCHAR(4)) 
				AS DATE)
   BETWEEN 
 -- First Day of 13 months ago. 
				   CAST(
						  CAST(DATEPART(MONTH,DATEADD(MONTH,-14,GETDATE())) AS VARCHAR(2)) 
						+ '/'
						+ '01/'
						+ CAST(DATEPART(YEAR,DATEADD(MONTH,-14,GETDATE())) AS VARCHAR(4))
						AS DATE)
   AND 
 --Last Day of whatever month we were in 2 months ago 
              --Subtracting one day from the first day of last month
			    DATEADD(DAY,-1,
					  CAST(
							  CAST(DATEPART(MONTH,DATEADD(MONTH,-1,GETDATE())) AS VARCHAR(2)) 
							+ '/'
							+ '01/'
							+ CAST(DATEPART(YEAR,DATEADD(MONTH,-1,GETDATE())) AS VARCHAR(4))
							AS DATE) 
						  ) 
   THEN 1 
   ELSE NULL 
   END AS TwelveMonthsPrior

   -- Same Month Prior Year Defined
  ,CAST(
				CAST(DATEPART(MONTH,DATEADD(MONTH,-13,GETDATE())) AS VARCHAR(2)) 
			+ '/'
			+ '01/'
			+ CAST(DATEPART(YEAR ,DATEADD(MONTH,-13,GETDATE())) AS VARCHAR(4)) 
			AS DATE) as SameMonthPriorYearDefined 


-- Same Month Prior Year

 ,CASE 
	WHEN 
	-- Post Date Month
	CAST(
				CAST(DATEPART(MONTH,PostDateMonth) AS VARCHAR(2)) 
			+ '/'
			+ '01/'
			+ CAST(DATEPART(YEAR ,PostDateMonth) AS VARCHAR(4)) 
			AS DATE)  

			=

   		CAST(
				CAST(DATEPART(MONTH,DATEADD(MONTH,-13,GETDATE())) AS VARCHAR(2)) 
			+ '/'
			+ '01/'
			+ CAST(DATEPART(YEAR ,DATEADD(MONTH,-13,GETDATE())) AS VARCHAR(4)) 
			AS DATE)
		THEN 1 
		ELSE NULL 
	 END AS SameMonthPriorYear 


-- First Day of 5 months ago (Beginning of the Prior3Months Date Range) 
   ,  CAST(
			  CAST(DATEPART(MONTH,DATEADD(MONTH,-5,GETDATE())) AS VARCHAR(2)) 
			+ '/'
			+ '01/'
			+ CAST(DATEPART(YEAR,DATEADD(MONTH,-5,GETDATE())) AS VARCHAR(4))
			AS DATE) as ThreeMonthsPriorBegin

-- First Day of 14 months ago (Beginning of the Prior12Months Date Range) 
   ,  CAST(
			  CAST(DATEPART(MONTH,DATEADD(MONTH,-14,GETDATE())) AS VARCHAR(2)) 
			+ '/'
			+ '01/'
			+ CAST(DATEPART(YEAR,DATEADD(MONTH,-14,GETDATE())) AS VARCHAR(4))
			AS DATE) as TwelveMonthsPriorBegin

---- Last Day of the Prior Month (End of all the Period Groups) 
   , DATEADD(DAY,-1,
		  CAST(
				  CAST(DATEPART(MONTH,DATEADD(MONTH,-1,GETDATE())) AS VARCHAR(2)) 
				+ '/'
				+ '01/'
				+ CAST(DATEPART(YEAR,DATEADD(MONTH,-1,GETDATE())) AS VARCHAR(4))
				AS DATE) 
              ) as BaselinePeriodEndDate   
 
  FROM ReportDB.dbo.ProviderNetworkReportOutput;

GO
