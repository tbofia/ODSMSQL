IF OBJECT_ID('adm.ReportCommand ', 'U') IS NOT NULL
DROP TABLE adm.ReportCommand
GO

IF OBJECT_ID('adm.Process ', 'U') IS NOT NULL
DROP TABLE adm.Process
GO

IF OBJECT_ID('adm.ReportJob ', 'U') IS NOT NULL
DROP TABLE adm.ReportJob
GO

IF OBJECT_ID('adm.ReportParameters ', 'U') IS NOT NULL
DROP TABLE adm.ReportParameters
GO

IF OBJECT_ID('rpt.ProviderDataExplorerCodeHierarchy ', 'U') IS NOT NULL
DROP TABLE rpt.ProviderDataExplorerCodeHierarchy
GO

IF OBJECT_ID('rpt.ProviderDataExplorerCodeMapping ', 'U') IS NOT NULL
DROP TABLE rpt.ProviderDataExplorerCodeMapping
GO

IF OBJECT_ID('rpt.ProviderDataExplorerEtlParameters ', 'U') IS NOT NULL
DROP TABLE rpt.ProviderDataExplorerEtlParameters
GO

IF OBJECT_ID('rpt.ProviderDataExplorerPRCodeDataQuality ', 'U') IS NOT NULL
DROP TABLE rpt.ProviderDataExplorerPRCodeDataQuality
GO

IF OBJECT_ID('rpt.ProviderDataExplorerZipCode ', 'U') IS NOT NULL
DROP TABLE rpt.ProviderDataExplorerZipCode
GO

IF OBJECT_ID('rpt.ProviderDataExplorerZipCodeMSAvCBSA ', 'U') IS NOT NULL
DROP TABLE rpt.ProviderDataExplorerZipCodeMSAvCBSA
GO

IF OBJECT_ID('rpt.CustomerReportSubscription', 'U') IS NOT NULL
DROP TABLE rpt.CustomerReportSubscription
GO
