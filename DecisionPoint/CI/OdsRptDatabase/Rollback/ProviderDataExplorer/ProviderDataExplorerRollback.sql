IF OBJECT_ID('dbo.ProviderDataExplorerBillHeader', 'U') IS NOT NULL
BEGIN
	-- Rollback the existing dbo.ProviderDataExplorerBillHeader table to dbo.ProviderAnalyticsBillHeader.
	EXEC sp_rename 'dbo.ProviderDataExplorerBillHeader.PK_ProviderDataExplorerBillHeader', 'PK_ProviderAnalyticsBillHeader', N'INDEX'
	EXEC sp_rename 'dbo.ProviderDataExplorerBillHeader', 'ProviderAnalyticsBillHeader'	
END

IF OBJECT_ID('dbo.ProviderDataExplorerBillLine', 'U') IS NOT NULL
BEGIN
	-- Rollbak the existing dbo.ProviderDataExplorerBillLine table to dbo.ProviderAnalyticsBillLine.
	EXEC sp_rename 'dbo.ProviderDataExplorerBillLine.PK_ProviderDataExplorerBillLine', 'PK_ProviderAnalyticsBillLine', N'INDEX'
	EXEC sp_rename 'dbo.ProviderDataExplorerBillLine', 'ProviderAnalyticsBillLine'	
END

IF OBJECT_ID('dbo.ProviderDataExplorerEtlAudit', 'U') IS NOT NULL
BEGIN
	-- Rollbak the existing dbo.ProviderDataExplorerEtlAudit table to dbo.ProviderAnalyticsEtlAudit.
	EXEC sp_rename 'dbo.ProviderDataExplorerEtlAudit.PK_ProviderDataExplorerEtlAudit', 'PK_ProviderAnalyticsEtlAudit', N'INDEX'
	EXEC sp_rename 'dbo.ProviderDataExplorerEtlAudit', 'ProviderAnalyticsEtlAudit'	
END

IF OBJECT_ID('dbo.ProviderDataExplorerIndustryComparisonReport', 'U') IS NOT NULL
BEGIN
	-- Rollbak the existing dbo.ProviderDataExplorerEtlAudit table to dbo.ProviderAnalyticsEtlAudit.
	EXEC sp_rename 'dbo.ProviderDataExplorerIndustryComparisonReport', 'ProviderAnalyticsIndustryComparisonReport'	
END

IF OBJECT_ID('dbo.ProviderDataExplorerProvider', 'U') IS NOT NULL
BEGIN
	-- Rollbak the existing dbo.ProviderDataExplorerProvider table to dbo.ProviderAnalyticsProvider.
	EXEC sp_rename 'dbo.ProviderDataExplorerProvider.PK_ProviderDataExplorerProvider', 'PK_ProviderAnalyticsProvider', N'INDEX'
	EXEC sp_rename 'dbo.ProviderDataExplorerProvider', 'ProviderAnalyticsProvider'	
END

IF OBJECT_ID('dbo.ProviderDataExplorerClaimantHeader', 'U') IS NOT NULL
BEGIN
	-- Rollbak the existing dbo.ProviderDataExplorerClaimantHeader table to dbo.ProviderAnalyticsClaimantHeader.
	EXEC sp_rename 'dbo.ProviderDataExplorerClaimantHeader.PK_ProviderDataExplorerClaimantHeader', 'PK_ProviderAnalyticsClaimantHeader', N'INDEX'
	EXEC sp_rename 'dbo.ProviderDataExplorerClaimantHeader', 'ProviderAnalyticsClaimantHeader'	
END

IF OBJECT_ID('stg.ProviderDataExplorerBillHeader', 'U') IS NOT NULL
DROP TABLE stg.ProviderDataExplorerBillHeader

IF OBJECT_ID('stg.ProviderDataExplorerBillLine', 'U') IS NOT NULL
DROP TABLE stg.ProviderDataExplorerBillLine

IF OBJECT_ID('stg.ProviderDataExplorerProvider', 'U') IS NOT NULL
DROP TABLE stg.ProviderDataExplorerProvider

IF OBJECT_ID('stg.ProviderDataExplorerClaimantHeader', 'U') IS NOT NULL
DROP TABLE stg.ProviderDataExplorerClaimantHeader

IF OBJECT_ID('rpt.ProviderDataExplorerCodeHierarchy', 'U') IS NOT NULL
DROP TABLE rpt.ProviderDataExplorerCodeHierarchy

IF OBJECT_ID('rpt.ProviderDataExplorerCodeMapping', 'U') IS NOT NULL
DROP TABLE rpt.ProviderDataExplorerCodeMapping

IF OBJECT_ID('rpt.ProviderDataExplorerPRCodeDataQuality', 'U') IS NOT NULL
DROP TABLE rpt.ProviderDataExplorerPRCodeDataQuality

IF OBJECT_ID('rpt.ProviderDataExplorerZipCode', 'U') IS NOT NULL
DROP TABLE rpt.ProviderDataExplorerZipCode

IF OBJECT_ID('rpt.ProviderDataExplorerZipCodeMSAvCBSA', 'U') IS NOT NULL
DROP TABLE rpt.ProviderDataExplorerZipCodeMSAvCBSA

IF OBJECT_ID( 'dbo.vwProviderDataExplorerReport' , 'V') IS NOT NULL     
DROP VIEW dbo.vwProviderDataExplorerReport ;

IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID('dbo.GetMaxRunFromOdsPostingGroupAuditId') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))    
DROP FUNCTION dbo.GetMaxRunFromOdsPostingGroupAuditId ;
IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID('dbo.ProviderDataExplorerUpdateProvider') AND type in (N'P', N'PC'))    
DROP PROCEDURE dbo.ProviderDataExplorerUpdateProvider ;
IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID('dbo.ProviderDataExplorerUpdateBillLine') AND type in (N'P', N'PC'))    
DROP PROCEDURE dbo.ProviderDataExplorerUpdateBillLine ;
IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID('dbo.ProviderDataExplorerRptUpdateProvider') AND type in (N'P', N'PC'))    
DROP PROCEDURE dbo.ProviderDataExplorerRptUpdateProvider ;
IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID('dbo.ProviderDataExplorerRptUpdateClaimantHeader') AND type in (N'P', N'PC'))    
DROP PROCEDURE dbo.ProviderDataExplorerRptUpdateClaimantHeader ;
IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID('dbo.ProviderDataExplorerRptUpdateBillLine') AND type in (N'P', N'PC'))    
DROP PROCEDURE dbo.ProviderDataExplorerRptUpdateBillLine ;
IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID('dbo.ProviderDataExplorerRptLoadProvider') AND type in (N'P', N'PC'))    
DROP PROCEDURE dbo.ProviderDataExplorerRptLoadProvider ;
IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID('dbo.ProviderDataExplorerRptLoadClaimantHeader') AND type in (N'P', N'PC'))    
DROP PROCEDURE dbo.ProviderDataExplorerRptLoadClaimantHeader ;
IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID('dbo.ProviderDataExplorerRptLoadBillLine') AND type in (N'P', N'PC'))    
DROP PROCEDURE dbo.ProviderDataExplorerRptLoadBillLine ;
IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID('dbo.ProviderDataExplorerRptLoadBillHeader') AND type in (N'P', N'PC'))    
DROP PROCEDURE dbo.ProviderDataExplorerRptLoadBillHeader ;
IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID('dbo.ProviderDataExplorerLoadProvider') AND type in (N'P', N'PC'))    
DROP PROCEDURE dbo.ProviderDataExplorerLoadProvider ;
IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID('dbo.ProviderDataExplorerLoadClaimantHeader') AND type in (N'P', N'PC'))    
DROP PROCEDURE dbo.ProviderDataExplorerLoadClaimantHeader ;
IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID('dbo.ProviderDataExplorerLoadBillLine') AND type in (N'P', N'PC'))    
DROP PROCEDURE dbo.ProviderDataExplorerLoadBillLine ;
IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID('dbo.ProviderDataExplorerLoadBillHeader') AND type in (N'P', N'PC'))    
DROP PROCEDURE dbo.ProviderDataExplorerLoadBillHeader ;
IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID('dbo.ProviderDataExplorerInitialLoadPrep') AND type in (N'P', N'PC'))    
DROP PROCEDURE dbo.ProviderDataExplorerInitialLoadPrep ;
IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID('dbo.ProviderDataExplorerEtlAuditStart') AND type in (N'P', N'PC'))    
DROP PROCEDURE dbo.ProviderDataExplorerEtlAuditStart ;
IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID('dbo.ProviderDataExplorerEtlAuditEnd') AND type in (N'P', N'PC'))    
DROP PROCEDURE dbo.ProviderDataExplorerEtlAuditEnd ;

DECLARE @jobId binary(16)  SELECT @jobId = job_id FROM msdb.dbo.sysjobs WHERE (name = N'RPT: Provider Data Explorer')  
IF (@jobId IS NOT NULL)  
BEGIN  EXEC msdb.dbo.sp_delete_job @jobId  END ;


GO