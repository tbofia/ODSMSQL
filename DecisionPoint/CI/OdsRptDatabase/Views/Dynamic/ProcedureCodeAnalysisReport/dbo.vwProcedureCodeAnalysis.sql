
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


