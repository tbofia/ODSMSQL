IF OBJECT_ID('adm.Process', 'U') IS NULL
BEGIN
    CREATE TABLE adm.Process
        (
            ProcessId SMALLINT NOT NULL ,
			ReportId INT,
            ProcessDescription VARCHAR(255) NOT NULL ,
			ProductName VARCHAR(255) NOT NULL,
            TargetSchemaName VARCHAR(10) NOT NULL ,
            TargetTableName VARCHAR(255) NOT NULL ,
			FilterDateColumnName VARCHAR(255) NULL,
            IsActive BIT NOT NULL,
			IsReportedOn BIT NOT NULL,
			IndexScript VARCHAR(MAX) NULL
        );

    ALTER TABLE adm.Process ADD 
    CONSTRAINT PK_EtlProcess PRIMARY KEY CLUSTERED (ProcessId);
END
GO
