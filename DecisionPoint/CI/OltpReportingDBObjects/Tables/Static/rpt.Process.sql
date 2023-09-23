IF OBJECT_ID('rpt.Process', 'U') IS NULL
BEGIN
    CREATE TABLE rpt.Process
        (
            ProcessId SMALLINT NOT NULL ,
            ProcessDescription VARCHAR(100) NOT NULL ,
            BaseFileName VARCHAR(100) NOT NULL ,
			IsSnapshot BIT NOT NULL ,
			FileExtension VARCHAR(3) NOT NULL ,
			IsHimStatic BIT NOT NULL ,
			IsActive BIT NOT NULL ,
			ProductKey VARCHAR(100) NOT NULL ,
			TargetPlatform VARCHAR(30) NOT NULL ,
			FileColumnDelimiter VARCHAR(3) NOT NULL ,
			MinODSVersion VARCHAR(20) NOT NULL
        );

    ALTER TABLE rpt.Process ADD 
    CONSTRAINT PK_EtlProcess PRIMARY KEY CLUSTERED (ProcessId);
END
GO
