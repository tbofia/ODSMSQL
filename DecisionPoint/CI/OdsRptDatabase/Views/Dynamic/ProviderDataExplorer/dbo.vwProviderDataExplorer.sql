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




									
