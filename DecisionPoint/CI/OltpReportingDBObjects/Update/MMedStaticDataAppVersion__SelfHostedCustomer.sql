
IF OBJECT_ID('dbo.MMedStaticDataAppVersion', 'V') IS NOT NULL
    DROP VIEW dbo.MMedStaticDataAppVersion;
GO

CREATE VIEW dbo.MMedStaticDataAppVersion
AS
SELECT  AppVersionId ,
        AppVersion ,
        AppVersionDate ,
        DataUpdateVersion ,
        DataUpdateDate
FROM    dbo.AppVersion
GO

GRANT SELECT ON dbo.MMedStaticDataAppVersion TO MedicalUserRole;
GO
 