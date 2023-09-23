IF OBJECT_ID ('dbo.vwAdjustorWorkspaceServiceRequested', 'V') IS NOT NULL
DROP VIEW dbo.vwAdjustorWorkspaceServiceRequested;
GO
CREATE VIEW dbo.vwAdjustorWorkspaceServiceRequested
AS
SELECT DP.OdsCustomerId
      ,DP.Customer
      ,DP.Company
      ,DP.Office
      ,DP.SOJ
      ,DP.RequestedByUserName
      ,DP.DateTimeReceived
      ,DP.DemandClaimantId
      ,DP.DemandPackageId
      ,DP.Size
      ,DP.FileCount
      ,DP.PageCount
      ,SR.DemandPackageRequestedServiceId
      ,SR.DemandPackageRequestedServiceName
      ,SR.IsRush
      ,SR.IsSupplemental
      ,DP.RunDate
FROM dbo.AdjustorWorkspaceDemandPackage_Output DP
LEFT OUTER JOIN dbo.AdjustorWorkspaceServiceRequested_Output SR
ON DP.OdsCustomerId = SR.OdsCustomerId
AND DP.DemandPackageId = SR.DemandPackageId

GO
IF OBJECT_ID ('dbo.MASTER_COVERAGE_REPORT', 'V') IS NOT NULL
DROP VIEW dbo.MASTER_COVERAGE_REPORT;
GO

CREATE VIEW dbo.MASTER_COVERAGE_REPORT
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
  FROM dbo.DP_PerformanceReport_Output
  
  GO
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

IF OBJECT_ID ('dbo.vwDP_PerformanceReport_3rdParty', 'V') IS NOT NULL
DROP VIEW dbo.vwDP_PerformanceReport_3rdParty;
GO
CREATE VIEW dbo.vwDP_PerformanceReport_3rdParty
AS
SELECT ReportTypeID
	  ,CASE WHEN ReportTypeID = 1 THEN 'FirstBillCreateDate'
			WHEN ReportTypeID = 2 THEN 'DateOfLoss'
			WHEN ReportTypeID = 3 THEN 'ClaimantCreateDate'
			WHEN ReportTypeID = 4 THEN 'MitchellCompleteDate'
			WHEN ReportTypeID = 5 THEN 'LastBillCreateDate' END AS ReportName
--First Day of PostDateMonth defined
   	  ,CAST(
				CAST(DATEPART(MONTH,StartOfMonth) AS VARCHAR(2)) 
			+ '/'
			+ '01/'
			+ CAST(DATEPART(YEAR ,StartOfMonth) AS VARCHAR(4)) 
			AS DATE) as StartofMonth 
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
				CAST(DATEPART(MONTH,StartOfMonth) AS VARCHAR(2)) 
			+ '/'
			+ '01/'
			+ CAST(DATEPART(YEAR ,StartOfMonth) AS VARCHAR(4)) 
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
				CAST(DATEPART(MONTH,StartOfMonth) AS VARCHAR(2)) 
			+ '/'
			+ '01/'
			+ CAST(DATEPART(YEAR ,StartOfMonth) AS VARCHAR(4)) 
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
					CAST(DATEPART(MONTH,StartOfMonth) AS VARCHAR(2)) 
				+ '/'
				+ '01/'
				+ CAST(DATEPART(YEAR ,StartOfMonth) AS VARCHAR(4)) 
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
					CAST(DATEPART(MONTH,StartOfMonth) AS VARCHAR(2)) 
				+ '/'
				+ '01/'
				+ CAST(DATEPART(YEAR ,StartOfMonth) AS VARCHAR(4)) 
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
				CAST(DATEPART(MONTH,StartOfMonth) AS VARCHAR(2)) 
			+ '/'
			+ '01/'
			+ CAST(DATEPART(YEAR ,StartOfMonth) AS VARCHAR(4)) 
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
      ,RunDate
	  ,GETDATE() as ReportingDate
  FROM dbo.DP_PerformanceReport_3rdParty_Output
  GO
IF OBJECT_ID ('dbo.vwERDReport', 'V') IS NOT NULL
DROP VIEW dbo.vwERDReport
GO

CREATE VIEW dbo.vwERDReport
AS
SELECT ReportName
	,CustomerName
	,ClaimIDNo
	,ClaimNo
	,ClaimantIDNo
	,CoverageType
	,CoverageTypeDesc
	,SOJ
	,County
	,AdjustorFirstName
	,AdjustorLastName
	,ClaimDateLoss
	,LastDateOfService
	,InjuryNatureId
	,InjuryNatureDesc
	,ERDDuration_Weeks
	,ERDDuration_Days
	,Company
	,Office
	,AllowedTreatmentDuration_Days
	,AllowedTreatmentDuration_Weeks
	,Charged
	,Allowed
	,ChargedAfterERD
	,AllowedAfterERD
	,RunDate
FROM dbo.ERDReport
WHERE ERDDuration_Weeks > 0


GO




IF OBJECT_ID ('dbo.vwIndustryComparison', 'V') IS NOT NULL
DROP VIEW dbo.vwIndustryComparison
GO

CREATE VIEW dbo.vwIndustryComparison
  AS 
  SELECT ReportName AS CvIReportName
      ,DisplayName
      ,CoverageType
      ,CoverageTypeDesc
      ,FormType
      ,[State]
      ,County
      ,[Year]
      ,[Quarter]
      ,Code
      ,[Desc]
      ,MajorGroup
      ,ProviderType
      ,ProviderType_Desc
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
  FROM dbo.IndustryComparison_Output WITH (NOLOCK)
  WHERE ISNULL(CODE,'-1') <> '' and CoverageType in ('AL','GL','PI','MP','UM','UN','WC')

GO







IF OBJECT_ID ('dbo.vwLossYearReport', 'V') IS NOT NULL
DROP VIEW dbo.vwLossYearReport
GO

CREATE VIEW dbo.vwLossYearReport
  AS
SELECT ReportName
      ,CustomerName
      ,CompanyName
      ,SOJ
      ,AgeGroup
      ,YOL
      ,Year
      ,Quarter
      ,DateQuarter
      ,FormType
      ,CoverageType
      ,CoverageTypeDesc
      ,ServiceGroup
	  ,RevenueGroup
      ,Gender
      ,OutlierCat
      ,ClaimantState
      ,ProviderState
      ,ProviderSpecialty
	  ,InjuryNatureId
	  ,InjuryNatureDesc
	  ,EncounterTypeId
	  ,EncounterTypeDesc
	  ,[Period]
      ,ClaimantCnt
      ,IndClaimantCnt
      ,DOSCnt
      ,IndDOSCnt
      ,UnitsCnt
      ,IndUnitsCnt
      ,Charged
      ,IndCharged
      ,Allowed
      ,IndAllowed
      ,IsAllowedGreaterThanZero
      ,Rundate AS CreateDate
  FROM ReportDB.dbo.LossYearReport


GO


 IF OBJECT_ID ('dbo.vwPPO_ActivityReport_MasterCoverage', 'V') IS NOT NULL
DROP VIEW dbo.vwPPO_ActivityReport_MasterCoverage;
GO
CREATE VIEW dbo.vwPPO_ActivityReport_MasterCoverage
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
      ,Total_Bills
      ,Total_Provider_Charges
      ,Total_Bill_Review_Reductions
      ,CASE WHEN StartOfMonth < (SELECT MAX(StartOfMonth) FROM dbo.PPO_ActivityReport_MasterCoverage_Output WHERE ReportTypeId = 2) THEN 2 ELSE ReportTypeId END AS ReportTypeId
      ,RunDate
  FROM dbo.PPO_ActivityReport_MasterCoverage_Output
  
  
GO

IF OBJECT_ID ('dbo.vwPPO_ActivityReport_NetworkRepricedSubmitted', 'V') IS NOT NULL
DROP VIEW dbo.vwPPO_ActivityReport_NetworkRepricedSubmitted;
GO

CREATE VIEW dbo.vwPPO_ActivityReport_NetworkRepricedSubmitted
AS
SELECT StartOfMonth
      ,OdsCustomerId
      ,Customer
      ,SOJ
      ,NetworkName
      ,BillType
      ,ReportYear
      ,ReportMonth
      ,CV_Type
      ,Company
      ,Office
      ,BillsCount
      ,BillsRepriced
      ,ProviderCharges
      ,BRAllowable
      ,InNetworkCharges
      ,InNetworkAmountAllowed
      ,Savings
      ,Credits
      ,NetSavings
	  ,CASE WHEN StartOfMonth < (SELECT MAX(StartOfMonth) FROM dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output WHERE ReportTypeId = 2) THEN 2 ELSE ReportTypeId END AS ReportTypeId
      ,(SELECT TOP 1 DateTimeStamp FROM stg.VPN_Monitoring_NetworkRepriced T WHERE O.OdsCustomerId = T.OdsCustomerId) AS RunTime
      ,RunDate
 FROM dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output O

 GO
 IF OBJECT_ID ('dbo.vwPPO_ActivityReport_NetworkUniqueSubmitted', 'V') IS NOT NULL
DROP VIEW dbo.vwPPO_ActivityReport_NetworkUniqueSubmitted;
GO

CREATE VIEW dbo.vwPPO_ActivityReport_NetworkUniqueSubmitted
AS
SELECT StartOfMonth
      ,OdsCustomerId
      ,Customer
      ,ReportYear
      ,ReportMonth
      ,SOJ
      ,BillType
      ,CV_Type
      ,Company
      ,Office
      ,InNetworkCharges
      ,InNetworkAmountAllowed
      ,Savings
      ,Credits
      ,NetSavings
      ,BillsCount
      ,BillsRePriced
      ,ProviderCharges
      ,BRAllowable
	  ,CASE WHEN StartOfMonth < (SELECT MAX(StartOfMonth) FROM dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output WHERE ReportTypeId = 2) THEN 2 ELSE ReportTypeId END AS ReportTypeId
      ,(SELECT TOP 1 DateTimeStamp FROM stg.VPN_Monitoring_NetworkRepriced T WHERE O.OdsCustomerId = T.OdsCustomerId) AS RunTime
      ,RunDate
FROM dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output O

GO
  
IF OBJECT_ID ('dbo.vwProcedureCodeAnalysis', 'V') IS NOT NULL
DROP VIEW dbo.vwProcedureCodeAnalysis
GO

CREATE VIEW dbo.vwProcedureCodeAnalysis
AS 
SELECT [ReportName] AS [CvIReportName]
      ,[DisplayName]
      ,[Code]
      ,[Desc]
      ,[MajorGroup]
      ,[CoverageType]
      ,[CoverageTypeDesc]
      ,[FormType]
      ,[State]
      ,[County]
      ,[Company]
      ,[Office]
      ,[Year]
      ,[Quarter]
      ,[DateQuarter]
      ,[TotalCharged]
      ,[IndTotalCharged]
      ,[TotalAllowed]
      ,[IndTotalAllowed]
      ,[ClaimCnt]
      ,[IndClaimCnt]
      ,[ClaimantCnt]
      ,[IndClaimantCnt]
      ,[TotalReduction]
      ,[IndTotalReduction]
      ,[TotalBills]
      ,[IndTotalBills]
      ,[TotalLines]
      ,[IndTotalLines]
      ,[TotalUnits]
      ,[IndTotalUnits]
FROM dbo.ProcedureCodeAnalysis_Output WITH (NOLOCK)
WHERE ISNULL(CODE,'-1') <> '' and CoverageType in ('AL','GL','PI','MP','UM','UN','WC')
GO


IF OBJECT_ID ('dbo.vwProviderAnalysisReport', 'V') IS NOT NULL
DROP VIEW dbo.vwProviderAnalysisReport

IF OBJECT_ID ('dbo.vwProviderDataExplorer', 'V') IS NOT NULL
DROP VIEW dbo.vwProviderDataExplorer
GO

CREATE VIEW dbo.vwProviderDataExplorer AS
SELECT 
		bl.BillID,			
		bl.LineNumber,			
		bh.CVType,			
		bh.ProviderZipofService,	
		bh.TypeofBill,		
		bl.DateofService,		
		bl.Charged,			
		bl.Allowed,		
		bl.Adjustment,		
		bl.FormType,
		bl.FormType AS DFFormType,
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
		ISNULL(bl.Category,'')+'/'+ISNULL(bl.SubCategory,'') AS CategorySubCategory,		
		bl.VisitType,				
		bl.BillInjuryDescription,
		ch.ClaimantID,
		ch.DOSTenureinDays AS ActualTenure,
		ch.ExpectedTenureinDays,
		ch.ClaimantStateofJurisdiction,
		ch.ClaimantStateofJurisdiction AS DFClaimantStateofJurisdiction,
		ch.CustomerName,
		ch.InjuryDescription,
		ch.InjuryDescription AS DFInjuryDescription,
		ch.DerivedCVType,
		ch.DerivedCVDesc,
		ch.DerivedCVDesc AS DFCoverageLine,
		ch.MSADesignation,
		ch.ClaimNumber,
		ch.ClaimId,
		p.ProviderTIN,
		CASE WHEN ISNULL(p.ProviderName,'') = '' THEN 'NA' ELSE p.ProviderName END AS ProviderName,
		p.ProviderName AS DFProviderName,
		UPPER(p.ProviderClusterName) AS ProviderClusterName,
		UPPER(p.ProviderClusterName) AS DFProviderClusterName,
		p.Specialty,	
		p.ProviderZip,		
		ch.ClaimantHeaderId,
		ch.OdsCustomerId,
		bl.Modifier,
		bl.EndNote,
		bl.Units

FROM    
    dbo.ProviderDataExplorerClaimantHeader ch 
    INNER JOIN dbo.ProviderDataExplorerProvider p ON p.ProviderId = ch.ProviderId
										AND ch.OdsCustomerId = p.OdsCustomerId
	INNER JOIN dbo.ProviderDataExplorerBillHeader bh ON bh.ClaimantHeaderId = ch.ClaimantHeaderId
										AND bh.OdsCustomerId = ch.OdsCustomerId
	INNER JOIN dbo.ProviderDataExplorerBillLine bl ON bl.BillId = bh.BillId
										AND bl.OdsCustomerId = bh.OdsCustomerId
									
	WHERE 
	CONVERT(DATE,bl.DateofService) BETWEEN CONVERT(VARCHAR(25),DATEADD(MONTH,-24,DATEADD(MONTH, DATEDIFF(MONTH, -1 , GETDATE()) - 1, 0)),110) 	
	AND DATEADD(MONTH,DATEDIFF(MONTH,-1,GETDATE())-1,-1)

GO




									
IF OBJECT_ID ('dbo.vwProviderDataExplorerIndustryComparison', 'V') IS NOT NULL
DROP VIEW dbo.vwProviderDataExplorerIndustryComparison
GO

CREATE VIEW dbo.vwProviderDataExplorerIndustryComparison AS
SELECT   CustomerName
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
		,CustomerName As TitleName
		,'Customer' AS CustomerType
FROM dbo.ProviderDataExplorerIndustryCustomerOutput
UNION ALL
SELECT   'IndustryPool'
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
		,'' As TitleName
		,'Industry' AS CustomerType
FROM dbo.ProviderDataExplorerIndustryOutput


GO


IF OBJECT_ID ('dbo.vwSelfServePerformanceReport_Operations', 'V') IS NOT NULL
DROP VIEW dbo.vwSelfServePerformanceReport_Operations;
GO

CREATE VIEW dbo.vwSelfServePerformanceReport_Operations
AS 

SELECT    
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

FROM  dbo.SelfServePerformanceReport_Operations
GO


IF OBJECT_ID ('dbo.vwSelfServePerformanceReport_Savings', 'V') IS NOT NULL
DROP VIEW dbo.vwSelfServePerformanceReport_Savings;
GO

CREATE VIEW dbo.vwSelfServePerformanceReport_Savings
AS 

SELECT    
		OdsCustomerId,
		CustomerName,
		Company,
		Office, 
		SOJ,
		ClaimCoverageType,
		BillCoverageType,
		FormType, 
		ClaimID, 
		ClaimantID, 
		ProviderTIN,
		BillID,
		BillCreateDate,
		BillCommitDate, 
		MitchellCompleteDate, 
		ClaimCreateDate, 
		ClaimDateofLoss,
		ExpectedRecoveryDate, 
		BillLine, 
		ProcedureCode,
		ProcedureCodeDescription,
		ProcedureCodeMajorGroup,
		BodyPart, 
		ReductionType,
		AdjSubCatName,
		DuplicateBillFlag, 
		DuplicateLineFlag,
		Adjustment,
		ProviderCharges, 
		TotalAllowed,
		TotalUnits,
		ExpectedRecoveryDuration

FROM  dbo.SelfServePerformanceReport_Savings
GO


IF OBJECT_ID ('dbo.vwVPN_Monitoring_NetworkCredits', 'V') IS NOT NULL
DROP VIEW dbo.vwVPN_Monitoring_NetworkCredits;
GO

CREATE VIEW dbo.vwVPN_Monitoring_NetworkCredits
AS
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
      ,Credits
      ,Rundate
 FROM dbo.VPN_Monitoring_NetworkCredits_Output 
 GO
 
 IF OBJECT_ID ('dbo.vwVPN_Monitoring_NetworkRepricedSubmitted', 'V') IS NOT NULL
DROP VIEW dbo.vwVPN_Monitoring_NetworkRepricedSubmitted;
GO

CREATE VIEW dbo.vwVPN_Monitoring_NetworkRepricedSubmitted
AS
SELECT StartOfMonth
      ,OdsCustomerId
      ,Customer
      ,SOJ
      ,NetworkName
      ,BillType
      ,ReportYear
      ,ReportMonth
      ,CV_Type
      ,Company
      ,Office
      ,BillsCount
      ,BillsRepriced
      ,ProviderCharges
      ,BRAllowable
      ,InNetworkCharges
      ,InNetworkAmountAllowed
      ,Savings
      ,Credits
      ,NetSavings
      ,(SELECT TOP 1 DateTimeStamp FROM stg.VPN_Monitoring_NetworkRepriced T WHERE O.OdsCustomerId = T.OdsCustomerId) AS RunTime
      ,RunDate
 FROM dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output O
 WHERE  StartOfMonth < (SELECT DATEADD(MM,-1,EOMONTH(MAX(Job_StartDate))) FROM adm.ReportJobAudit WHERE ReportId = 2 AND JobStatus = 1)
 

 GO
 IF OBJECT_ID ('dbo.vwVPN_Monitoring_NetworkUniqueSubmitted', 'V') IS NOT NULL
DROP VIEW dbo.vwVPN_Monitoring_NetworkUniqueSubmitted;
GO

CREATE VIEW dbo.vwVPN_Monitoring_NetworkUniqueSubmitted
AS
SELECT StartOfMonth
      ,OdsCustomerId
      ,Customer
      ,ReportYear
      ,ReportMonth
      ,SOJ
      ,BillType
      ,CV_Type
      ,Company
      ,Office
      ,InNetworkCharges
      ,InNetworkAmountAllowed
      ,Savings
      ,Credits
      ,NetSavings
      ,BillsCount
      ,BillsRePriced
      ,ProviderCharges
      ,BRAllowable
      ,(SELECT TOP 1 DateTimeStamp FROM stg.VPN_Monitoring_NetworkRepriced T WHERE O.OdsCustomerId = T.OdsCustomerId) AS RunTime
      ,RunDate
FROM dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output O
WHERE  StartOfMonth < (SELECT DATEADD(MM,-1,EOMONTH(MAX(Job_StartDate))) FROM adm.ReportJobAudit WHERE ReportId = 2 AND JobStatus = 1)

GO
  IF OBJECT_ID ('dbo.vwVPN_Monitoring_TAT', 'V') IS NOT NULL
DROP VIEW dbo.vwVPN_Monitoring_TAT;
GO

CREATE VIEW dbo.vwVPN_Monitoring_TAT
AS
SELECT StartOfMonth
      ,Client
      ,BillIdNo
      ,ClaimIdNo
      ,SOJ
      ,NetworkId
      ,NetworkName
      ,SentDate
      ,ReceivedDate
      ,HoursLockedToVPN
      ,TATInHours
      ,CASE WHEN TAT < 0 THEN 0 ELSE TAT END AS TAT
      ,BillCreateDate
      ,ParNonPar
      ,SubNetwork
      ,AmtCharged
      ,BillType
      ,Bucket
      ,ValueBucket
      ,(SELECT MAX(ReceivedDate) FROM dbo.VPN_Monitoring_TAT_Output T WHERE O.Client = T.Client) AS RunTime
      ,RunDate
  FROM dbo.VPN_Monitoring_TAT_Output O
  GO
  