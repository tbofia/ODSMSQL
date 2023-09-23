
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







