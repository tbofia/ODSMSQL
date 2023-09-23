-- These objects should be in the dm schema; let's drop

-- views
IF OBJECT_ID('dbo.TreatmentCategoryRange', 'V') IS NOT NULL
    DROP VIEW dbo.TreatmentCategoryRange;
GO
IF OBJECT_ID('dbo.TreatmentCategory', 'V') IS NOT NULL
    DROP VIEW dbo.TreatmentCategory;
GO
IF OBJECT_ID('dbo.Tag', 'V') IS NOT NULL
    DROP VIEW dbo.Tag;
GO
IF OBJECT_ID('dbo.Note', 'V') IS NOT NULL
    DROP VIEW dbo.Note;
GO
IF OBJECT_ID('dbo.EventLogDetail', 'V') IS NOT NULL
    DROP VIEW dbo.EventLogDetail;
GO
IF OBJECT_ID('dbo.EventLog', 'V') IS NOT NULL
    DROP VIEW dbo.EventLog;
GO
IF OBJECT_ID('dbo.DemandPackageUploadedFile', 'V') IS NOT NULL
    DROP VIEW dbo.DemandPackageUploadedFile;
GO
IF OBJECT_ID('dbo.DemandPackageRequestedService', 'V') IS NOT NULL
    DROP VIEW dbo.DemandPackageRequestedService;
GO
IF OBJECT_ID('dbo.DemandPackage', 'V') IS NOT NULL
    DROP VIEW dbo.DemandPackage;
GO
IF OBJECT_ID('dbo.DemandClaimant', 'V') IS NOT NULL
    DROP VIEW dbo.DemandClaimant;
GO
IF OBJECT_ID('dbo.AnalysisRuleThreshold', 'V') IS NOT NULL
    DROP VIEW dbo.AnalysisRuleThreshold;
GO
IF OBJECT_ID('dbo.AnalysisRuleGroup', 'V') IS NOT NULL
    DROP VIEW dbo.AnalysisRuleGroup;
GO
IF OBJECT_ID('dbo.AnalysisRule', 'V') IS NOT NULL
    DROP VIEW dbo.AnalysisRule;
GO
IF OBJECT_ID('dbo.AnalysisGroup', 'V') IS NOT NULL
    DROP VIEW dbo.AnalysisGroup;
GO
IF OBJECT_ID('dbo.AcceptedTreatmentDate', 'V') IS NOT NULL
    DROP VIEW dbo.AcceptedTreatmentDate;
GO

-- table functions
IF OBJECT_ID('dbo.if_TreatmentCategoryRange', 'IF') IS NOT NULL
	DROP FUNCTION dbo.if_TreatmentCategoryRange;
GO
IF OBJECT_ID('dbo.if_TreatmentCategory', 'IF') IS NOT NULL
	DROP FUNCTION dbo.if_TreatmentCategory;
GO
IF OBJECT_ID('dbo.if_Tag', 'IF') IS NOT NULL
	DROP FUNCTION dbo.if_Tag;
GO
IF OBJECT_ID('dbo.if_Note', 'IF') IS NOT NULL
	DROP FUNCTION dbo.if_Note;
GO
IF OBJECT_ID('dbo.if_EventLogDetail', 'IF') IS NOT NULL
	DROP FUNCTION dbo.if_EventLogDetail;
GO
IF OBJECT_ID('dbo.if_EventLog', 'IF') IS NOT NULL
	DROP FUNCTION dbo.if_EventLog;
GO
IF OBJECT_ID('dbo.if_DemandPackageUploadedFile', 'IF') IS NOT NULL
	DROP FUNCTION dbo.if_DemandPackageUploadedFile;
GO
IF OBJECT_ID('dbo.if_DemandPackageRequestedService', 'IF') IS NOT NULL
	DROP FUNCTION dbo.if_DemandPackageRequestedService;
GO
IF OBJECT_ID('dbo.if_DemandPackage', 'IF') IS NOT NULL
	DROP FUNCTION dbo.if_DemandPackage;
GO
IF OBJECT_ID('dbo.if_DemandClaimant', 'IF') IS NOT NULL
	DROP FUNCTION dbo.if_DemandClaimant;
GO
IF OBJECT_ID('dbo.if_AnalysisRuleThreshold', 'IF') IS NOT NULL
	DROP FUNCTION dbo.if_AnalysisRuleThreshold;
GO
IF OBJECT_ID('dbo.if_AnalysisRuleGroup', 'IF') IS NOT NULL
	DROP FUNCTION dbo.if_AnalysisRuleGroup;
GO
IF OBJECT_ID('dbo.if_AnalysisRule', 'IF') IS NOT NULL
	DROP FUNCTION dbo.if_AnalysisRule;
GO
IF OBJECT_ID('dbo.if_AnalysisGroup', 'IF') IS NOT NULL
	DROP FUNCTION dbo.if_AnalysisGroup;
GO
IF OBJECT_ID('dbo.if_AcceptedTreatmentDate', 'IF') IS NOT NULL
	DROP FUNCTION dbo.if_AcceptedTreatmentDate;
GO
