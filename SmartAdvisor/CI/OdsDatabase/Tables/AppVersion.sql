DECLARE @AppVer VARCHAR(10)
SET @AppVer = '2.2.0.0'

INSERT  INTO adm.AppVersion
        ( AppVersion, ProductKey , AppVersionDate)
VALUES  ( @AppVer,'SmartAdvisor', GETDATE() )

GO
