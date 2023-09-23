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

--
IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'adm.Process')
						AND NAME = 'TargetPlatform' )
BEGIN
	--Backup the data
	IF OBJECT_ID('tempdb..#process', 'U') IS NOT NULL
	DROP TABLE #process

	SELECT *
	INTO #process
	FROM adm.Process

	DROP TABLE adm.Process

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

	INSERT adm.Process 
	(
		ProcessId
        ,ProcessDescription
        ,TargetSchemaName
        ,TargetTableName
        ,ProductKey
		,TargetPlatform
        ,FileColumnDelimiter
        ,PostingGroupId
        ,LoadGroup
        ,HashFunctionType
        ,IsActive
        ,IsSnapshot
	)
	SELECT
		ProcessId
        ,ProcessDescription
        ,TargetSchemaName
        ,TargetTableName
        ,ProductKey
		,NULL AS TargetPlatform
        ,FileColumnDelimiter
        ,PostingGroupId
        ,LoadGroup
        ,HashFunctionType
        ,IsActive
        ,IsSnapshot
	FROM #process
END
