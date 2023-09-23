IF OBJECT_ID('adm.Process', 'U') IS NULL
BEGIN
    CREATE TABLE adm.Process
        (
            ProcessId SMALLINT NOT NULL ,
            ProcessDescription VARCHAR(100) NOT NULL ,
            TargetSchemaName VARCHAR(10) NOT NULL ,
            TargetTableName VARCHAR(100) NOT NULL ,
            ProductKey VARCHAR(100) NOT NULL,
			TargetPlatform VARCHAR(50) NOT NULL,
            FileColumnDelimiter VARCHAR(2) NOT NULL,
            PostingGroupId INT NOT NULL ,
            LoadGroup INT NOT NULL ,
            HashFunctionType INT NOT NULL ,
            IsActive BIT NOT NULL ,
            IsSnapshot BIT NOT NULL
        );

    ALTER TABLE adm.Process ADD 
    CONSTRAINT PK_EtlProcess PRIMARY KEY CLUSTERED (ProcessId);
END
GO
