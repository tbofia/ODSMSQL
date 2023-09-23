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

