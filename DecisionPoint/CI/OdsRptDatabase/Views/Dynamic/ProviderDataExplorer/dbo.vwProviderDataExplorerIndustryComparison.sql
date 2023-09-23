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


