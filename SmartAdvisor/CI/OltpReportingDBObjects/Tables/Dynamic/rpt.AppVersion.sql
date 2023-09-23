IF OBJECT_ID('rpt.AppVersion', 'U') IS NULL
BEGIN

    CREATE TABLE rpt.AppVersion
        (
            AppVersionId INT IDENTITY(1, 1) ,
            AppVersion VARCHAR(10) NULL ,
            AppVersionDate DATETIME2(7) NULL
        );

    ALTER TABLE rpt.AppVersion ADD 
    CONSTRAINT PK_AppVersion PRIMARY KEY CLUSTERED (AppVersionId);

END
GO

