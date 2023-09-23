
IF OBJECT_ID('rpt.ProviderAnalyticsZipCodeMSAvCBSA', 'U') IS NOT NULL
DROP TABLE rpt.ProviderAnalyticsZipCodeMSAvCBSA

GO

IF OBJECT_ID('rpt.ProviderDataExplorerZipCodeMSAvCBSA','U') IS NULL
BEGIN
CREATE TABLE rpt.ProviderDataExplorerZipCodeMSAvCBSA(
  	MSAState VARCHAR(50) NULL,
	MSAZipCode VARCHAR(50) NOT NULL,
	MSALocality VARCHAR(50) NULL,
	MSACarrier VARCHAR(50) NULL,
	MSAUrbanBlankRuralRSuperRuralB VARCHAR(50) NULL,
	CBSAState VARCHAR(50) NULL,
	CBSAZipCode VARCHAR(50) NOT NULL,
	CBSACarrier VARCHAR(50) NULL,
	CBSALocality VARCHAR(50) NULL,
	CBSAUrbanBlankRuralRSuperRuralB VARCHAR(50) NULL
)
	ALTER TABLE rpt.ProviderDataExplorerZipCodeMSAvCBSA ADD 
	CONSTRAINT PK_ProviderDataExplorerZipCodeMSAvCBSA PRIMARY KEY CLUSTERED	
	(
		MSAZipCode,
		CBSAZipCode
	);
END
GO


