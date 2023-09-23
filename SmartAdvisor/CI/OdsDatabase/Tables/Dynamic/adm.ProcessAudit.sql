IF OBJECT_ID('adm.ProcessAudit', 'U') IS NULL
BEGIN
    CREATE TABLE adm.ProcessAudit
        (
            ProcessAuditId INT IDENTITY(1, 1) ,
            PostingGroupAuditId INT NOT NULL ,
            ProcessId SMALLINT NOT NULL ,
            Status VARCHAR(2) NOT NULL ,
			TotalRecordsInSource BIGINT NULL,
			TotalRecordsInTarget BIGINT NULL,
			TotalDeletedRecords INT NULL,
			ControlRowCount INT NULL ,
            ExtractRowCount INT NULL,
            UpdateRowCount INT NULL,
            LoadRowCount INT NULL,
            ExtractDate DATETIME2(7) NULL ,
            LastUpdateDate DATETIME2(7) NULL ,
            LoadDate DATETIME2(7) NULL, 
            CreateDate DATETIME2(7) NOT NULL ,
            LastChangeDate DATETIME2(7) NOT NULL
        );

    ALTER TABLE adm.ProcessAudit ADD 
    CONSTRAINT PK_ProcessAudit PRIMARY KEY CLUSTERED (ProcessAuditId);

END
GO

-- Adding New Column to store Records count from control file
IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'adm.ProcessAudit')
                        AND NAME = 'ControlRowCount' )
    BEGIN
	BEGIN TRANSACTION 
	BEGIN TRY 

	IF OBJECT_ID('tempdb..#ProcessAudit') IS NOT NULL DROP TABLE #ProcessAudit
	SELECT ProcessAuditId
		  ,PostingGroupAuditId
		  ,ProcessId
		  ,Status
		  ,ExtractRowCount AS ControlRowCount
		  ,ExtractRowCount
		  ,UpdateRowCount
		  ,LoadRowCount
		  ,ExtractDate
		  ,LastUpdateDate
		  ,LoadDate
		  ,CreateDate
		  ,LastChangeDate
	INTO #ProcessAudit
	FROM adm.ProcessAudit;
	
	DROP TABLE  adm.ProcessAudit;
	
	CREATE TABLE adm.ProcessAudit
        (
            ProcessAuditId INT IDENTITY(1, 1) ,
            PostingGroupAuditId INT NOT NULL ,
            ProcessId SMALLINT NOT NULL ,
            Status VARCHAR(2) NOT NULL ,
			ControlRowCount INT NULL,
            ExtractRowCount INT NULL,
            UpdateRowCount INT NULL,
            LoadRowCount INT NULL,
            ExtractDate DATETIME2(7) NULL ,
            LastUpdateDate DATETIME2(7) NULL ,
            LoadDate DATETIME2(7) NULL, 
            CreateDate DATETIME2(7) NOT NULL ,
            LastChangeDate DATETIME2(7) NOT NULL
        );

    ALTER TABLE adm.ProcessAudit ADD 
    CONSTRAINT PK_ProcessAudit PRIMARY KEY CLUSTERED (ProcessAuditId);

  	SET IDENTITY_INSERT adm.ProcessAudit ON;
	INSERT INTO adm.ProcessAudit(
		   ProcessAuditId
		  ,PostingGroupAuditId
		  ,ProcessId
		  ,Status
		  ,ControlRowCount
		  ,ExtractRowCount
		  ,UpdateRowCount
		  ,LoadRowCount
		  ,ExtractDate
		  ,LastUpdateDate
		  ,LoadDate
		  ,CreateDate
		  ,LastChangeDate)
	SELECT ProcessAuditId
		  ,PostingGroupAuditId
		  ,ProcessId
		  ,Status
		  ,ControlRowCount
		  ,ExtractRowCount
		  ,UpdateRowCount
		  ,LoadRowCount
		  ,ExtractDate
		  ,LastUpdateDate
		  ,LoadDate
		  ,CreateDate
		  ,LastChangeDate
	FROM #ProcessAudit; 
	SET IDENTITY_INSERT adm.ProcessAudit OFF; 
	DROP TABLE #ProcessAudit;
	COMMIT
	END TRY
	BEGIN CATCH
	IF OBJECT_ID('tempdb..#ProcessAudit') IS NOT NULL DROP TABLE #ProcessAudit
	ROLLBACK
	END CATCH
	END;
GO

-- Adding New Column to store Records count from in Source
IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'adm.ProcessAudit')
                        AND NAME = 'TotalRecordsInSource' ) 
    BEGIN
	BEGIN TRANSACTION
	BEGIN TRY

	IF OBJECT_ID('tempdb..#ProcessAudit') IS NOT NULL DROP TABLE #ProcessAudit
	SELECT ProcessAuditId
		  ,PostingGroupAuditId
		  ,ProcessId
		  ,Status
		  ,NULL AS TotalRecordsInSource
		  ,ControlRowCount
		  ,ExtractRowCount
		  ,UpdateRowCount
		  ,LoadRowCount
		  ,ExtractDate
		  ,LastUpdateDate
		  ,LoadDate
		  ,CreateDate
		  ,LastChangeDate
	INTO #ProcessAudit
	FROM adm.ProcessAudit;
	
	DROP TABLE  adm.ProcessAudit;
	
	CREATE TABLE adm.ProcessAudit
        (
            ProcessAuditId INT IDENTITY(1, 1) ,
            PostingGroupAuditId INT NOT NULL ,
            ProcessId SMALLINT NOT NULL ,
            Status VARCHAR(2) NOT NULL ,
			TotalRecordsInSource BIGINT NULL,
			ControlRowCount INT NULL,
            ExtractRowCount INT NULL,
            UpdateRowCount INT NULL,
            LoadRowCount INT NULL,
            ExtractDate DATETIME2(7) NULL ,
            LastUpdateDate DATETIME2(7) NULL ,
            LoadDate DATETIME2(7) NULL, 
            CreateDate DATETIME2(7) NOT NULL ,
            LastChangeDate DATETIME2(7) NOT NULL
        );

    ALTER TABLE adm.ProcessAudit ADD 
    CONSTRAINT PK_ProcessAudit PRIMARY KEY CLUSTERED (ProcessAuditId);

  	SET IDENTITY_INSERT adm.ProcessAudit ON;
	INSERT INTO adm.ProcessAudit(
		   ProcessAuditId
		  ,PostingGroupAuditId
		  ,ProcessId
		  ,Status
		  ,TotalRecordsInSource
		  ,ControlRowCount
		  ,ExtractRowCount
		  ,UpdateRowCount
		  ,LoadRowCount
		  ,ExtractDate
		  ,LastUpdateDate
		  ,LoadDate
		  ,CreateDate
		  ,LastChangeDate)
	SELECT ProcessAuditId
		  ,PostingGroupAuditId
		  ,ProcessId
		  ,Status
		  ,TotalRecordsInSource
		  ,ControlRowCount
		  ,ExtractRowCount
		  ,UpdateRowCount
		  ,LoadRowCount
		  ,ExtractDate
		  ,LastUpdateDate
		  ,LoadDate
		  ,CreateDate
		  ,LastChangeDate
	FROM #ProcessAudit; 
	SET IDENTITY_INSERT adm.ProcessAudit OFF; 
	DROP TABLE #ProcessAudit;
	COMMIT
	END TRY
	BEGIN CATCH
	IF OBJECT_ID('tempdb..#ProcessAudit') IS NOT NULL DROP TABLE #ProcessAudit
	ROLLBACK
	END CATCH
	END;
GO

-- Adding New Column to store Records count from in Source
IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'adm.ProcessAudit')
                        AND NAME = 'TotalRecordsInTarget' )
    BEGIN
	BEGIN TRANSACTION
	BEGIN TRY

	IF OBJECT_ID('tempdb..#ProcessAudit') IS NOT NULL DROP TABLE #ProcessAudit
	SELECT ProcessAuditId
		  ,PostingGroupAuditId
		  ,ProcessId
		  ,Status
		  ,TotalRecordsInSource
		  ,NULL AS TotalRecordsInTarget
		  ,ControlRowCount
		  ,ExtractRowCount
		  ,UpdateRowCount
		  ,LoadRowCount
		  ,ExtractDate
		  ,LastUpdateDate
		  ,LoadDate
		  ,CreateDate
		  ,LastChangeDate
	INTO #ProcessAudit
	FROM adm.ProcessAudit;
	
	DROP TABLE  adm.ProcessAudit;
	
	CREATE TABLE adm.ProcessAudit
        (
            ProcessAuditId INT IDENTITY(1, 1) ,
            PostingGroupAuditId INT NOT NULL ,
            ProcessId SMALLINT NOT NULL ,
            Status VARCHAR(2) NOT NULL ,
			TotalRecordsInSource BIGINT NULL,
			TotalRecordsInTarget BIGINT NULL,
			ControlRowCount INT NULL,
            ExtractRowCount INT NULL,
            UpdateRowCount INT NULL,
            LoadRowCount INT NULL,
            ExtractDate DATETIME2(7) NULL ,
            LastUpdateDate DATETIME2(7) NULL ,
            LoadDate DATETIME2(7) NULL, 
            CreateDate DATETIME2(7) NOT NULL ,
            LastChangeDate DATETIME2(7) NOT NULL
        );

    ALTER TABLE adm.ProcessAudit ADD 
    CONSTRAINT PK_ProcessAudit PRIMARY KEY CLUSTERED (ProcessAuditId);

  	SET IDENTITY_INSERT adm.ProcessAudit ON;
	INSERT INTO adm.ProcessAudit(
		   ProcessAuditId
		  ,PostingGroupAuditId
		  ,ProcessId
		  ,Status
		  ,TotalRecordsInSource
		  ,TotalRecordsInTarget
		  ,ControlRowCount
		  ,ExtractRowCount
		  ,UpdateRowCount
		  ,LoadRowCount
		  ,ExtractDate
		  ,LastUpdateDate
		  ,LoadDate
		  ,CreateDate
		  ,LastChangeDate)
	SELECT ProcessAuditId
		  ,PostingGroupAuditId
		  ,ProcessId
		  ,Status
		  ,TotalRecordsInSource
		  ,TotalRecordsInTarget
		  ,ControlRowCount
		  ,ExtractRowCount
		  ,UpdateRowCount
		  ,LoadRowCount
		  ,ExtractDate
		  ,LastUpdateDate
		  ,LoadDate
		  ,CreateDate
		  ,LastChangeDate
	FROM #ProcessAudit; 
	SET IDENTITY_INSERT adm.ProcessAudit OFF; 
	DROP TABLE #ProcessAudit;
	COMMIT
	END TRY
	BEGIN CATCH
	IF OBJECT_ID('tempdb..#ProcessAudit') IS NOT NULL DROP TABLE #ProcessAudit
	ROLLBACK
	END CATCH
	END;
GO


-- Adding New Column to store Number of deleted records
IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'adm.ProcessAudit')
                        AND NAME = 'TotalDeletedRecords' )

    BEGIN
	BEGIN TRANSACTION
	BEGIN TRY

	IF OBJECT_ID('tempdb..#ProcessAudit') IS NOT NULL DROP TABLE #ProcessAudit
	SELECT ProcessAuditId
		  ,PostingGroupAuditId
		  ,ProcessId
		  ,Status
		  ,TotalRecordsInSource
		  ,TotalRecordsInTarget
		  ,NULL AS TotalDeletedRecords
		  ,ControlRowCount
		  ,ExtractRowCount
		  ,UpdateRowCount
		  ,LoadRowCount
		  ,ExtractDate
		  ,LastUpdateDate
		  ,LoadDate
		  ,CreateDate
		  ,LastChangeDate
	INTO  #ProcessAudit
	FROM adm.ProcessAudit;
	
	DROP TABLE  adm.ProcessAudit;
	
	CREATE TABLE adm.ProcessAudit
        (
            ProcessAuditId INT IDENTITY(1, 1) ,
            PostingGroupAuditId INT NOT NULL ,
            ProcessId SMALLINT NOT NULL ,
            Status VARCHAR(2) NOT NULL ,
			TotalRecordsInSource BIGINT NULL,
			TotalRecordsInTarget BIGINT NULL,
			TotalDeletedRecords INT NULL,
			ControlRowCount INT NULL,
            ExtractRowCount INT NULL,
            UpdateRowCount INT NULL,
            LoadRowCount INT NULL,
            ExtractDate DATETIME2(7) NULL ,
            LastUpdateDate DATETIME2(7) NULL ,
            LoadDate DATETIME2(7) NULL, 
            CreateDate DATETIME2(7) NOT NULL ,
            LastChangeDate DATETIME2(7) NOT NULL
        );

    ALTER TABLE adm.ProcessAudit ADD 
    CONSTRAINT PK_ProcessAudit PRIMARY KEY CLUSTERED (ProcessAuditId);

  	SET IDENTITY_INSERT adm.ProcessAudit ON;
	INSERT INTO adm.ProcessAudit(
		   ProcessAuditId
		  ,PostingGroupAuditId
		  ,ProcessId
		  ,Status
		  ,TotalRecordsInSource
		  ,TotalRecordsInTarget
		  ,TotalDeletedRecords
		  ,ControlRowCount
		  ,ExtractRowCount
		  ,UpdateRowCount
		  ,LoadRowCount
		  ,ExtractDate
		  ,LastUpdateDate
		  ,LoadDate
		  ,CreateDate
		  ,LastChangeDate)
	SELECT ProcessAuditId
		  ,PostingGroupAuditId
		  ,ProcessId
		  ,Status
		  ,TotalRecordsInSource
		  ,TotalRecordsInTarget
		  ,TotalDeletedRecords
		  ,ControlRowCount
		  ,ExtractRowCount
		  ,UpdateRowCount
		  ,LoadRowCount
		  ,ExtractDate
		  ,LastUpdateDate
		  ,LoadDate
		  ,CreateDate
		  ,LastChangeDate
	FROM #ProcessAudit; 
	SET IDENTITY_INSERT adm.ProcessAudit OFF; 
	DROP TABLE #ProcessAudit;
	COMMIT
	END TRY
	BEGIN CATCH
	IF OBJECT_ID('tempdb..#ProcessAudit') IS NOT NULL DROP TABLE #ProcessAudit
	ROLLBACK
	END CATCH
	END;
GO




