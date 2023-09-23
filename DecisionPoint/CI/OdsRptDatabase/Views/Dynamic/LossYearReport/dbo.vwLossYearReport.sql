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


