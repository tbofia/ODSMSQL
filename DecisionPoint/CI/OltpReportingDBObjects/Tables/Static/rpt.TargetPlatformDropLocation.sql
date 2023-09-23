IF OBJECT_ID('rpt.TargetPlatformDropLocation', 'U') IS NULL
BEGIN
    CREATE TABLE rpt.TargetPlatformDropLocation
        (
            TargetPlatform VARCHAR(100) NOT NULL ,
           	OutputPath VARCHAR(100) NOT NULL
        );

    ALTER TABLE rpt.TargetPlatformDropLocation ADD 
    CONSTRAINT PK_EtlTargetPlatformDropLocation PRIMARY KEY CLUSTERED (TargetPlatform);
END
GO
