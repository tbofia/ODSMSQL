DECLARE @AppVer VARCHAR(10)
SET @AppVer = '2.2.0.0'

INSERT  INTO rpt.AppVersion
        ( AppVersion, AppVersionDate )
VALUES  ( @AppVer, GETDATE() )
GO
