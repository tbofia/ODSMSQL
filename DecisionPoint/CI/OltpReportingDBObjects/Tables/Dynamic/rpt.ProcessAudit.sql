IF OBJECT_ID('rpt.ProcessAudit', 'U') IS NULL
BEGIN
    CREATE TABLE rpt.ProcessAudit
        (
            ProcessAuditId INT IDENTITY(1, 1) ,
            PostingGroupAuditId INT NOT NULL ,
            ProcessId SMALLINT NOT NULL ,
            Status VARCHAR(2) NOT NULL ,
			TotalRowCount BIGINT NULL,
			TotalNumberOfFiles INT NULL,
            QueueDate DATETIME2(7) NOT NULL ,
            ExtractDate DATETIME2(7) NULL ,
            CreateDate DATETIME2(7) NOT NULL ,
            LastChangeDate DATETIME2(7) NOT NULL
        );

    ALTER TABLE rpt.ProcessAudit ADD 
    CONSTRAINT PK_ProcessAudit PRIMARY KEY CLUSTERED (ProcessAuditId);

END
GO

-- Adding New Column to store Records count from control file
IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'rpt.ProcessAudit')
                        AND NAME = 'TotalRowCount' )
    BEGIN

	BEGIN TRANSACTION
	BEGIN TRY

	SELECT  ProcessAuditId,
            PostingGroupAuditId,
            ProcessId,
            Status,
			NULL AS TotalRowCount,
            QueueDate,
            ExtractDate,
            CreateDate,
            LastChangeDate
	INTO #ProcessAudit
	FROM rpt.ProcessAudit;
	
	DROP TABLE  rpt.ProcessAudit;
	
	 CREATE TABLE rpt.ProcessAudit
        (
            ProcessAuditId INT IDENTITY(1, 1) ,
            PostingGroupAuditId INT NOT NULL ,
            ProcessId SMALLINT NOT NULL ,
            Status VARCHAR(2) NOT NULL ,
			TotalRowCount BIGINT NULL,
            QueueDate DATETIME2(7) NOT NULL ,
            ExtractDate DATETIME2(7) NULL ,
            CreateDate DATETIME2(7) NOT NULL ,
            LastChangeDate DATETIME2(7) NOT NULL
        );

    ALTER TABLE rpt.ProcessAudit ADD 
    CONSTRAINT PK_ProcessAudit PRIMARY KEY CLUSTERED (ProcessAuditId);

  	SET IDENTITY_INSERT rpt.ProcessAudit ON;
	INSERT INTO rpt.ProcessAudit(
		    ProcessAuditId,
            PostingGroupAuditId,
            ProcessId,
            Status,
			TotalRowCount,
            QueueDate,
            ExtractDate,
            CreateDate,
            LastChangeDate)
	SELECT  ProcessAuditId,
            PostingGroupAuditId,
            ProcessId,
            Status,
			TotalRowCount,
            QueueDate,
            ExtractDate,
            CreateDate,
            LastChangeDate
	FROM #ProcessAudit; 
	SET IDENTITY_INSERT rpt.ProcessAudit OFF; 
	COMMIT
	END TRY

	BEGIN CATCH
	ROLLBACK
	END CATCH

	END;
GO


-- Adding New Column to store Number Of Files
IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'rpt.ProcessAudit')
                        AND NAME = 'TotalNumberOfFiles' )
    BEGIN

	BEGIN TRANSACTION
	BEGIN TRY

	SELECT  ProcessAuditId,
            PostingGroupAuditId,
            ProcessId,
            Status,
			TotalRowCount,
			NULL AS TotalNumberOfFiles,
            QueueDate,
            ExtractDate,
            CreateDate,
            LastChangeDate
	INTO #ProcessAudit
	FROM rpt.ProcessAudit;
	
	DROP TABLE  rpt.ProcessAudit;
	
	 CREATE TABLE rpt.ProcessAudit
        (
            ProcessAuditId INT IDENTITY(1, 1) ,
            PostingGroupAuditId INT NOT NULL ,
            ProcessId SMALLINT NOT NULL ,
            Status VARCHAR(2) NOT NULL ,
			TotalRowCount BIGINT NULL,
			TotalNumberOfFiles INT NULL,
            QueueDate DATETIME2(7) NOT NULL ,
            ExtractDate DATETIME2(7) NULL ,
            CreateDate DATETIME2(7) NOT NULL ,
            LastChangeDate DATETIME2(7) NOT NULL
        );

    ALTER TABLE rpt.ProcessAudit ADD 
    CONSTRAINT PK_ProcessAudit PRIMARY KEY CLUSTERED (ProcessAuditId);

  	SET IDENTITY_INSERT rpt.ProcessAudit ON;
	INSERT INTO rpt.ProcessAudit(
		    ProcessAuditId,
            PostingGroupAuditId,
            ProcessId,
            Status,
			TotalRowCount,
			TotalNumberOfFiles,
            QueueDate,
            ExtractDate,
            CreateDate,
            LastChangeDate)
	SELECT  ProcessAuditId,
            PostingGroupAuditId,
            ProcessId,
            Status,
			TotalRowCount,
			TotalNumberOfFiles,
            QueueDate,
            ExtractDate,
            CreateDate,
            LastChangeDate
	FROM #ProcessAudit; 
	SET IDENTITY_INSERT rpt.ProcessAudit OFF; 
	COMMIT
	END TRY

	BEGIN CATCH
	ROLLBACK
	END CATCH

	END;
GO



