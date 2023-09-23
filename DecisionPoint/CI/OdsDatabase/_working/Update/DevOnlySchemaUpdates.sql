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

----

-- Tsk, tsk!  Someone dropped a column without cleaning up after themselves in DevOnlySchemaUpdates!
IF OBJECT_ID('src.BILL_HDR', 'U') IS NOT NULL
   AND EXISTS
(
    SELECT 1
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'src.BILL_HDR')
          AND NAME = 'BillVpnFlag'
)
BEGIN

    DECLARE @Sql VARCHAR(MAX);

    SET @Sql = 'ALTER TABLE src.BILL_HDR DROP COLUMN BillVpnFlag;';

    EXEC (@Sql);

END;
GO

-- Tsk, tsk!  Someone dropped a column without cleaning up after themselves in DevOnlySchemaUpdates!
IF OBJECT_ID('src.MedicareStatusIndicatorRule', 'U') IS NOT NULL
   AND EXISTS
(
    SELECT 1
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'src.MedicareStatusIndicatorRule')
          AND NAME = 'PricingType'
)
BEGIN

    DECLARE @Sql VARCHAR(MAX);

    SET @Sql = 'ALTER TABLE src.MedicareStatusIndicatorRule DROP COLUMN PricingType;';

    EXEC (@Sql);

END;
GO

-- ChargemasterCode hasn't been released on the ODS yet (v1.10).  Let's drop it.
IF EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills_Pharm')
						AND NAME = 'ChargemasterCode' )
	BEGIN

    DECLARE @Sql VARCHAR(MAX);

    SET @Sql = 'ALTER TABLE src.Bills_Pharm DROP COLUMN ChargemasterCode;';

    EXEC (@Sql);
		
	END 
GO

-- Column order now matters, so if we see ServiceCode before PpoCtgPenalty, let's drop it.  We
-- can do this because ServiceCode hasn't been released yet (v1.10).
-- Let's make sure this doesn't screw us in the future by only running against v1.10 or earlier
SET XACT_ABORT ON;
DECLARE @AppVersion VARCHAR(10) = '0.0.0.0';

IF EXISTS
(
    SELECT 1
    FROM sys.objects
    WHERE object_id = OBJECT_ID('adm.AppVersion')
)
BEGIN
    EXEC sp_executesql N'SELECT TOP 1
       @AppVersion = AppVersion
FROM adm.AppVersion
WHERE AppVersion IS NOT NULL
      AND AppVersion NOT LIKE ''%[^0-9.]%''
ORDER BY AppVersionId DESC;',
N'@AppVersion VARCHAR(10)',
@AppVersion = @AppVersion;
END;

IF CAST('/' + @AppVersion + '/' AS HIERARCHYID) <= CAST('/1.10.0.0/' AS HIERARCHYID)
BEGIN
    BEGIN TRANSACTION;

    DECLARE @ServiceCodePosition TINYINT = 0,
            @PpoCtgPenaltyPosition TINYINT = 0;

    SELECT @ServiceCodePosition = column_id
    FROM sys.columns
    WHERE object_id = OBJECT_ID('src.Bills_Pharm')
          AND name = 'ServiceCode';

    SELECT @PpoCtgPenaltyPosition = column_id
    FROM sys.columns
    WHERE object_id = OBJECT_ID('src.Bills_Pharm')
          AND name = 'PpoCtgPenalty';

    IF @ServiceCodePosition <> 0 -- ServiceCode column exists
       AND
       (
           (@ServiceCodePosition < @PpoCtgPenaltyPosition) -- and the ServiceCode column is before PpoCtgPenalty
           OR (@PpoCtgPenaltyPosition = 0) -- or the PpoCtgPenalty column doesn't yet exist
       )
        ALTER TABLE src.Bills_Pharm DROP COLUMN ServiceCode;

    COMMIT TRANSACTION;
END;
GO

-- PricingType hasn't been released on the ODS yet (v1.10).  Let's drop it.
IF EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.MedicareStatusIndicatorRule')
						AND NAME = 'PricingType' )
	BEGIN

    DECLARE @Sql VARCHAR(MAX);

    SET @Sql = 'ALTER TABLE src.MedicareStatusIndicatorRule DROP COLUMN PricingType;';

    EXEC (@Sql);
		
	END 
GO
