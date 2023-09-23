IF OBJECT_ID('adm.AppVersion', 'U') IS NULL
BEGIN

    CREATE TABLE adm.AppVersion
        (
            AppVersionId INT IDENTITY(1, 1) ,
            AppVersion VARCHAR(10) NULL ,
            AppVersionDate DATETIME2(7) NULL
        );

    ALTER TABLE adm.AppVersion ADD 
    CONSTRAINT PK_AppVersion PRIMARY KEY CLUSTERED (AppVersionId);

END
GO

IF OBJECT_ID('adm.LoadStatus', 'U') IS NULL
BEGIN
CREATE TABLE adm.LoadStatus
(	JobRunId INT IDENTITY(1,1) NOT NULL,
	JobName VARCHAR(MAX) NOT NULL,
	Status VARCHAR(5) NOT NULL,
	NoOfCustomers INT NULL,
	StartDate DATETIME NOT NULL,
	EndDate DATETIME NULL 
	)
END
GO

IF OBJECT_ID('adm.PostingGroupAudit', 'U') IS NULL
BEGIN
    CREATE TABLE adm.PostingGroupAudit
        (
            PostingGroupAuditId INT IDENTITY(1, 1) ,
            OltpPostingGroupAuditId INT NOT NULL,
            PostingGroupId TINYINT NOT NULL ,
            CustomerId INT NOT NULL,
            Status VARCHAR(2) NOT NULL ,
            DataExtractTypeId INT NOT NULL ,
            OdsVersion VARCHAR(10) NULL ,
            SnapshotCreateDate DATETIME2(7) NULL ,
            SnapshotDropDate DATETIME2(7) NULL ,
            CreateDate DATETIME2(7) NOT NULL ,
            LastChangeDate DATETIME2(7) NOT NULL
        );

    ALTER TABLE adm.PostingGroupAudit ADD 
    CONSTRAINT PK_PostingGroupAudit PRIMARY KEY CLUSTERED (PostingGroupAuditId);
END
GO

-- Rename AppVersion Column.
IF EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'adm.PostingGroupAudit')
                        AND NAME = 'AppVersion' )
BEGIN
    EXEC sp_RENAME 'adm.PostingGroupAudit.AppVersion', 'OdsVersion', 'COLUMN'
END
GO

-- Rename IsIncremental Column
IF EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'adm.PostingGroupAudit')
                        AND NAME = 'IsIncremental' )
BEGIN
    EXEC sp_RENAME 'adm.PostingGroupAudit.IsIncremental', 'DataExtractTypeId', 'COLUMN'
END
GO

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




IF OBJECT_ID('src.AcceptedTreatmentDate', 'U') IS NULL
    BEGIN
        CREATE TABLE src.AcceptedTreatmentDate
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  AcceptedTreatmentDateId int NOT NULL,
			  DemandClaimantId int  NULL,
			  TreatmentDate datetimeoffset(7) NULL,
			  Comments varchar(255) NULL,
			  TreatmentCategoryId tinyint NULL,
			  LastUpdatedBy varchar(15) NULL,
			  LastUpdatedDate datetimeoffset(7) NULL 

            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.AcceptedTreatmentDate ADD 
        CONSTRAINT PK_AcceptedTreatmentDate PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,AcceptedTreatmentDateId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);
		
		ALTER INDEX PK_AcceptedTreatmentDate ON src.AcceptedTreatmentDate REBUILD WITH(STATISTICS_INCREMENTAL = ON);

	END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_AcceptedTreatmentDate'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_AcceptedTreatmentDate ON src.AcceptedTreatmentDate REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.Adjustment3603rdPartyEndNoteSubCategory', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Adjustment3603rdPartyEndNoteSubCategory
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ReasonNumber INT NOT NULL ,
			  SubCategoryId INT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Adjustment3603rdPartyEndNoteSubCategory ADD 
     CONSTRAINT PK_Adjustment3603rdPartyEndNoteSubCategory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ReasonNumber) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Adjustment3603rdPartyEndNoteSubCategory ON src.Adjustment3603rdPartyEndNoteSubCategory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.Adjustment360ApcEndNoteSubCategory', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Adjustment360ApcEndNoteSubCategory
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ReasonNumber INT NOT NULL ,
			  SubCategoryId INT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Adjustment360ApcEndNoteSubCategory ADD 
     CONSTRAINT PK_Adjustment360ApcEndNoteSubCategory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ReasonNumber) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Adjustment360ApcEndNoteSubCategory ON src.Adjustment360ApcEndNoteSubCategory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.Adjustment360Category', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Adjustment360Category
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  Adjustment360CategoryId INT NOT NULL ,
			  Name VARCHAR (50) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Adjustment360Category ADD 
     CONSTRAINT PK_Adjustment360Category PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Adjustment360CategoryId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Adjustment360Category ON src.Adjustment360Category   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.Adjustment360EndNoteSubCategory', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Adjustment360EndNoteSubCategory
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ReasonNumber INT NOT NULL ,
			  SubCategoryId INT NULL ,
			  EndnoteTypeId TINYINT CONSTRAINT DF_Adjustment360EndNoteSubCategory_EndnoteTypeId DEFAULT(1) NOT NULL
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Adjustment360EndNoteSubCategory ADD 
     CONSTRAINT PK_Adjustment360EndNoteSubCategory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ReasonNumber, EndnoteTypeId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Adjustment360EndNoteSubCategory ON src.Adjustment360EndNoteSubCategory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO

 IF NOT EXISTS ( SELECT 1
			FROM sys.indexes AS i 
			INNER JOIN sys.index_columns AS ic 
				ON i.OBJECT_ID = ic.OBJECT_ID 
				AND i.index_id = ic.index_id 
				AND i.is_primary_key = 1 
				AND ic.OBJECT_ID = OBJECT_ID('src.Adjustment360EndNoteSubCategory')
			INNER JOIN sys.columns AS c 
				ON ic.object_id = c.object_id 
				AND ic.column_id = c.column_id
				AND c.name = 'EndnoteTypeId' )
BEGIN
	SET XACT_ABORT ON;

	--Drop PK
	ALTER TABLE src.Adjustment360EndNoteSubCategory
	DROP CONSTRAINT PK_Adjustment360EndNoteSubCategory;

	--Add new Column if not exists
	 IF NOT EXISTS ( SELECT  1
				FROM    sys.columns c 
				WHERE   object_id = OBJECT_ID(N'src.Adjustment360EndNoteSubCategory')
					AND NAME =  'EndnoteTypeId' )
	BEGIN
		ALTER TABLE src.Adjustment360EndNoteSubCategory ADD EndnoteTypeId TINYINT CONSTRAINT DF_Adjustment360EndNoteSubCategory_EndnoteTypeId DEFAULT(1) NOT NULL;
	END 

	--recreate pk
	ALTER TABLE src.Adjustment360EndNoteSubCategory ADD 
    CONSTRAINT PK_Adjustment360EndNoteSubCategory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ReasonNumber, EndnoteTypeId) WITH (DATA_COMPRESSION = PAGE) ON
    DP_Ods_PartitionScheme(OdsCustomerId);

    ALTER INDEX PK_Adjustment360EndNoteSubCategory ON src.Adjustment360EndNoteSubCategory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
END


-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1 
                FROM sys.stats
                WHERE name = 'PK_Adjustment360EndNoteSubCategory' 
                AND is_incremental = 1)  
BEGIN
ALTER INDEX PK_Adjustment360EndNoteSubCategory ON src.Adjustment360EndNoteSubCategory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 

END ;
GO


IF OBJECT_ID('src.Adjustment360OverrideEndNoteSubCategory', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Adjustment360OverrideEndNoteSubCategory
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ReasonNumber INT NOT NULL ,
			  SubCategoryId INT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Adjustment360OverrideEndNoteSubCategory ADD 
     CONSTRAINT PK_Adjustment360OverrideEndNoteSubCategory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ReasonNumber) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Adjustment360OverrideEndNoteSubCategory ON src.Adjustment360OverrideEndNoteSubCategory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.Adjustment360SubCategory', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Adjustment360SubCategory
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  Adjustment360SubCategoryId INT NOT NULL ,
			  Name VARCHAR (50) NULL ,
			  Adjustment360CategoryId INT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Adjustment360SubCategory ADD 
     CONSTRAINT PK_Adjustment360SubCategory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Adjustment360SubCategoryId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Adjustment360SubCategory ON src.Adjustment360SubCategory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.Adjustment3rdPartyEndnoteSubCategory', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Adjustment3rdPartyEndnoteSubCategory
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ReasonNumber INT NOT NULL ,
			  SubCategoryId VARCHAR (100) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Adjustment3rdPartyEndnoteSubCategory ADD 
     CONSTRAINT PK_Adjustment3rdPartyEndnoteSubCategory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ReasonNumber) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Adjustment3rdPartyEndnoteSubCategory ON src.Adjustment3rdPartyEndnoteSubCategory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.AdjustmentApcEndNoteSubCategory', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.AdjustmentApcEndNoteSubCategory
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ReasonNumber INT NOT NULL ,
			  SubCategoryId VARCHAR (100) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.AdjustmentApcEndNoteSubCategory ADD 
     CONSTRAINT PK_AdjustmentApcEndNoteSubCategory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ReasonNumber) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_AdjustmentApcEndNoteSubCategory ON src.AdjustmentApcEndNoteSubCategory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.AdjustmentEndNoteSubCategory', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.AdjustmentEndNoteSubCategory
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ReasonNumber INT NOT NULL ,
			  SubCategoryId VARCHAR (100) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.AdjustmentEndNoteSubCategory ADD 
     CONSTRAINT PK_AdjustmentEndNoteSubCategory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ReasonNumber) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_AdjustmentEndNoteSubCategory ON src.AdjustmentEndNoteSubCategory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.AdjustmentOverrideEndNoteSubCategory', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.AdjustmentOverrideEndNoteSubCategory
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ReasonNumber INT NOT NULL ,
			  SubCategoryId VARCHAR (100) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.AdjustmentOverrideEndNoteSubCategory ADD 
     CONSTRAINT PK_AdjustmentOverrideEndNoteSubCategory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ReasonNumber) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_AdjustmentOverrideEndNoteSubCategory ON src.AdjustmentOverrideEndNoteSubCategory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.Adjustor', 'U') IS NULL
BEGIN
    CREATE TABLE src.Adjustor
        (
          OdsPostingGroupAuditId INT NOT NULL ,
          OdsCustomerId INT NOT NULL ,
          OdsCreateDate DATETIME2(7) NOT NULL ,
          OdsSnapshotDate DATETIME2(7) NOT NULL ,
          OdsRowIsCurrent BIT NOT NULL ,
          OdsHashbytesValue VARBINARY(8000) NULL,
          DmlOperation CHAR(1) NOT NULL ,
          lAdjIdNo INT NOT NULL ,
          IDNumber VARCHAR(15) NULL ,
          Lastname VARCHAR(30) NULL ,
          FirstName VARCHAR(30) NULL ,
          Address1 VARCHAR(30) NULL ,
          Address2 VARCHAR(30) NULL ,
          City VARCHAR(30) NULL ,
          State VARCHAR(2) NULL ,
          ZipCode VARCHAR(12) NULL ,
          Phone VARCHAR(25) NULL ,
          Fax VARCHAR(25) NULL ,
          Office VARCHAR(120) NULL ,
          EMail VARCHAR(60) NULL ,
          InUse VARCHAR(100) NULL ,
          OfficeIdNo INT NULL ,
          UserId INT NULL ,
          CreateDate DATETIME NULL ,
          LastChangedOn DATETIME NULL 
        ) ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (DATA_COMPRESSION = PAGE);

    ALTER TABLE src.Adjustor ADD 
    CONSTRAINT PK_Adjustor PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, lAdjIdNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_Adjustor ON src.Adjustor REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Alter Office Column size to increase from 30 to 120
ALTER TABLE src.Adjustor
ALTER COLUMN Office VARCHAR(120);
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Adjustor'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Adjustor ON src.Adjustor REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.AnalysisGroup', 'U') IS NULL
    BEGIN
        CREATE TABLE src.AnalysisGroup
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  AnalysisGroupId int NOT NULL,
	          GroupName varchar(200) NULL
	          
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.AnalysisGroup ADD 
        CONSTRAINT PK_AnalysisGroup PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,AnalysisGroupId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_AnalysisGroup ON src.AnalysisGroup REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_AnalysisGroup'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_AnalysisGroup ON src.AnalysisGroup REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

IF OBJECT_ID('src.AnalysisRule', 'U') IS NULL
    BEGIN
        CREATE TABLE src.AnalysisRule
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              AnalysisRuleId INT NOT NULL ,
              Title VARCHAR(200) NULL ,
              AssemblyQualifiedName VARCHAR(200) NULL ,
              MethodToInvoke VARCHAR(50) NULL ,
              DisplayMessage NVARCHAR(200) NULL ,
              DisplayOrder INT NULL ,
              IsActive BIT NULL ,
              CreateDate DATETIMEOFFSET(7) NULL ,
              LastChangedOn DATETIMEOFFSET(7) NULL ,
              MessageToken NVARCHAR(200) NULL
            )
        ON  DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.AnalysisRule ADD 
        CONSTRAINT PK_AnalysisRule PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,AnalysisRuleId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_AnalysisRule ON src.AnalysisRule REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

IF EXISTS ( SELECT  1
            FROM    sys.columns c
                    INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
            WHERE   c.object_id = OBJECT_ID(N'src.AnalysisRule')
                    AND c.name = 'AssemblyQualifiedName'
                    AND c.max_length <> 200 )
    BEGIN
        ALTER TABLE src.AnalysisRule ALTER COLUMN AssemblyQualifiedName VARCHAR(200) NULL;
    END;
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_AnalysisRule'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_AnalysisRule ON src.AnalysisRule REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

IF OBJECT_ID('src.AnalysisRuleGroup', 'U') IS NULL
    BEGIN
        CREATE TABLE src.AnalysisRuleGroup
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  AnalysisRuleGroupId int NOT NULL,
	          AnalysisRuleId int NULL,
	          AnalysisGroupId int NULL

            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.AnalysisRuleGroup ADD 
        CONSTRAINT PK_AnalysisRuleGroup PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,AnalysisRuleGroupId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_AnalysisRuleGroup ON src.AnalysisRuleGroup REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_AnalysisRuleGroup'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_AnalysisRuleGroup ON src.AnalysisRuleGroup REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

IF OBJECT_ID('src.AnalysisRuleThreshold', 'U') IS NULL
    BEGIN
        CREATE TABLE src.AnalysisRuleThreshold
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  AnalysisRuleThresholdId int NOT NULL,
	          AnalysisRuleId int NULL,
	          ThresholdKey varchar(50) NULL,
	          ThresholdValue varchar(100) NULL,
	          CreateDate datetimeoffset(7) NULL,
	          LastChangedOn datetimeoffset(7) NULL

            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.AnalysisRuleThreshold ADD 
        CONSTRAINT PK_AnalysisRuleThreshold PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,AnalysisRuleThresholdId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);
		
		ALTER INDEX PK_AnalysisRuleThreshold ON src.AnalysisRuleThreshold REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_AnalysisRuleThreshold'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_AnalysisRuleThreshold ON src.AnalysisRuleThreshold REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO


IF OBJECT_ID('src.ApportionmentEndnote', 'U') IS NULL
    BEGIN
        CREATE TABLE src.ApportionmentEndnote
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              ApportionmentEndnote INT NOT NULL,
              ShortDescription VARCHAR(50) NULL,
              LongDescription VARCHAR(500) NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.ApportionmentEndnote ADD 
        CONSTRAINT PK_ApportionmentEndnote PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ApportionmentEndnote) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_ApportionmentEndnote ON src.ApportionmentEndnote REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO
IF OBJECT_ID('src.BillAdjustment', 'U') IS NULL
    BEGIN
        CREATE TABLE src.BillAdjustment
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              BillLineAdjustmentId BIGINT NOT NULL,
			  BillIdNo INT NULL ,
			  LineNumber INT NULL ,
			  Adjustment MONEY NULL ,
			  EndNote INT NULL ,
			  EndNoteTypeId INT NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.BillAdjustment ADD 
        CONSTRAINT PK_BillAdjustment PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillLineAdjustmentId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_BillAdjustment ON src.BillAdjustment REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

IF OBJECT_ID('src.BillApportionmentEndnote', 'U') IS NULL
    BEGIN
        CREATE TABLE src.BillApportionmentEndnote
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              BillId INT NOT NULL,
              LineNumber SMALLINT NOT NULL,
              Endnote INT NOT NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.BillApportionmentEndnote ADD 
        CONSTRAINT PK_BillApportionmentEndnote PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillId , LineNumber, Endnote) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_BillApportionmentEndnote ON src.BillApportionmentEndnote REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

IF OBJECT_ID('src.BillCustomEndnote', 'U') IS NULL
    BEGIN
        CREATE TABLE src.BillCustomEndnote
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              BillId INT NOT NULL,
              LineNumber SMALLINT NOT NULL,
              Endnote INT NOT NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.BillCustomEndnote ADD 
        CONSTRAINT PK_BillCustomEndnote PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillId, LineNumber, Endnote) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_BillCustomEndnote ON src.BillCustomEndnote REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO


IF OBJECT_ID('src.BillExclusionLookUpTable', 'U') IS NULL
BEGIN
    CREATE TABLE src.BillExclusionLookUpTable
        (
            OdsPostingGroupAuditId INT NOT NULL ,
            OdsCustomerId INT NOT NULL ,
            OdsCreateDate DATETIME2(7) NOT NULL ,
			OdsSnapshotDate DATETIME2(7) NOT NULL ,
			OdsRowIsCurrent BIT NOT NULL ,
			OdsHashbytesValue VARBINARY(8000) NULL,
			DmlOperation CHAR(1) NOT NULL ,
            ReportID tinyint NOT NULL,
	        ReportName nvarchar(100) NULL
        ) ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (DATA_COMPRESSION = PAGE);

    ALTER TABLE src.BillExclusionLookUpTable ADD 
    CONSTRAINT PK_BillExclusionLookUpTable PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ReportID) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_BillExclusionLookUpTable ON src.BillExclusionLookUpTable REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_BillExclusionLookUpTable'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_BillExclusionLookUpTable ON src.BillExclusionLookUpTable REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.BILLS', 'U') IS NULL
    BEGIN
        CREATE TABLE src.BILLS
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              BillIDNo INT NOT NULL ,
              LINE_NO SMALLINT NOT NULL ,
              LINE_NO_DISP SMALLINT NULL ,
              OVER_RIDE SMALLINT NULL ,
              DT_SVC DATETIME NULL ,
              PRC_CD VARCHAR(7) NULL ,
              UNITS REAL NULL ,
              TS_CD VARCHAR(14) NULL ,
              CHARGED MONEY NULL ,
              ALLOWED MONEY NULL ,
              ANALYZED MONEY NULL ,
              REASON1 INT NULL ,
              REASON2 INT NULL ,
              REASON3 INT NULL ,
              REASON4 INT NULL ,
              REASON5 INT NULL ,
              REASON6 INT NULL ,
              REASON7 INT NULL ,
              REASON8 INT NULL ,
              REF_LINE_NO SMALLINT NULL ,
              SUBNET VARCHAR(9) NULL ,
              OverrideReason SMALLINT NULL ,
              FEE_SCHEDULE MONEY NULL ,
              POS_RevCode VARCHAR(4) NULL ,
              CTGPenalty MONEY NULL ,
              PrePPOAllowed MONEY NULL ,
              PPODate DATETIME NULL ,
              PPOCTGPenalty MONEY NULL ,
              UCRPerUnit MONEY NULL ,
              FSPerUnit MONEY NULL ,
              HCRA_Surcharge MONEY NULL ,
              EligibleAmt MONEY NULL ,
              DPAllowed MONEY NULL ,
              EndDateOfService DATETIME NULL ,
              AnalyzedCtgPenalty DECIMAL(19, 4) NULL ,
              AnalyzedCtgPpoPenalty DECIMAL(19, 4) NULL ,
              RepackagedNdc VARCHAR(13) NULL ,
              OriginalNdc VARCHAR(13) NULL ,
              UnitOfMeasureId TINYINT NULL ,
              PackageTypeOriginalNdc VARCHAR(2) NULL ,
			  ServiceCode VARCHAR(25) NULL ,
			  PreApportionedAmount DECIMAL(19,4) NULL ,
			  DeductibleApplied DECIMAL(19,4) NULL,
			  BillReviewResults DECIMAL(19,4) NULL,
			  PreOverriddenDeductible DECIMAL(19,4) NULL,
		      RemainingBalance DECIMAL (19,4) NULL,
			  CtgCoPayPenalty DECIMAL(19,4) NULL,
			  PpoCtgCoPayPenalty DECIMAL(19,4) NULL,
			  AnalyzedCtgCoPayPenalty DECIMAL(19,4) NULL,
			  AnalyzedPpoCtgCoPayPenalty DECIMAL(19,4) NULL,
			  CtgVunPenalty DECIMAL(19,4) NULL,
			  PpoCtgVunPenalty DECIMAL(19,4) NULL,
			  AnalyzedCtgVunPenalty DECIMAL(19,4) NULL,
			  AnalyzedPpoCtgVunPenalty DECIMAL(19,4) NULL

			 ,RenderingNpi VARCHAR(15) NULL 
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.BILLS ADD 
        CONSTRAINT PK_Bills PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIDNo, LINE_NO) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Bills ON src.BILLS REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

SET XACT_ABORT ON 
IF EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills')
						AND NAME = 'ChargemasterCode' )
	BEGIN
		BEGIN TRANSACTION
			EXEC SP_RENAME 'src.BillS.ChargemasterCode' , 'ServiceCode' , 'COLUMN'
			ALTER TABLE src.Bills ALTER COLUMN ServiceCode VARCHAR(25) NULL ;
		COMMIT TRANSACTION
	END 
GO


IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.BILLS')
						AND NAME = 'ServiceCode' )
	BEGIN
		ALTER TABLE src.BILLS ADD ServiceCode VARCHAR(25) NULL ;
	END 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.BILLS')
						AND NAME = 'PreApportionedAmount' )
	BEGIN
		ALTER TABLE src.BILLS ADD PreApportionedAmount DECIMAL(19,4) NULL ;
	END 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.BILLS')
						AND NAME = 'DeductibleApplied' )
	BEGIN
		ALTER TABLE src.BILLS ADD DeductibleApplied DECIMAL(19,4) NULL ;
	END 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.BILLS')
						AND NAME = 'PreOverriddenDeductible' )
	BEGIN
		ALTER TABLE src.BILLS ADD PreOverriddenDeductible DECIMAL(19,4) NULL ;
	END ; 
GO

SET XACT_ABORT ON 
IF EXISTS ( SELECT  1
				FROM    sys.columns c 
				WHERE   object_id = OBJECT_ID(N'src.BILLS')
						AND NAME =  'PreDeductibleAllowed' )
	BEGIN
		BEGIN TRANSACTION
			EXEC SP_RENAME 'src.BILLS.PreDeductibleAllowed' ,  'BillReviewResults'  , 'COLUMN' 
		COMMIT TRANSACTION
	END
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.BILLS')
						AND NAME = 'BillReviewResults' )
	BEGIN
		ALTER TABLE src.BILLS ADD BillReviewResults DECIMAL(19,4) NULL ;
	END 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.BILLS')
						AND NAME = 'RemainingBalance' )
	BEGIN
		ALTER TABLE src.BILLS ADD RemainingBalance DECIMAL(19,4) NULL ;
	END 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills')
						AND NAME = 'CtgCoPayPenalty' )
	BEGIN
		ALTER TABLE src.Bills ADD CtgCoPayPenalty DECIMAL(19,4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills')
						AND NAME = 'PpoCtgCoPayPenalty' )
	BEGIN
		ALTER TABLE src.Bills ADD PpoCtgCoPayPenalty DECIMAL(19,4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills')
						AND NAME = 'AnalyzedCtgCoPayPenalty' )
	BEGIN
		ALTER TABLE src.Bills ADD AnalyzedCtgCoPayPenalty DECIMAL(19,4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills')
						AND NAME = 'AnalyzedPpoCtgCoPayPenalty' )
	BEGIN
		ALTER TABLE src.Bills ADD AnalyzedPpoCtgCoPayPenalty DECIMAL(19,4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills')
						AND NAME = 'CtgVunPenalty' )
	BEGIN
		ALTER TABLE src.Bills ADD CtgVunPenalty DECIMAL(19,4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills')
						AND NAME = 'PpoCtgVunPenalty' )
	BEGIN
		ALTER TABLE src.Bills ADD PpoCtgVunPenalty DECIMAL(19,4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills')
						AND NAME = 'AnalyzedCtgVunPenalty' )
	BEGIN
		ALTER TABLE src.Bills ADD AnalyzedCtgVunPenalty DECIMAL(19,4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills')
						AND NAME = 'AnalyzedPpoCtgVunPenalty' )
	BEGIN
		ALTER TABLE src.Bills ADD AnalyzedPpoCtgVunPenalty DECIMAL(19,4) NULL ;
	END ; 
GO


IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills')
						AND NAME = 'RenderingNpi' )
	BEGIN
		ALTER TABLE src.Bills ADD RenderingNpi VARCHAR(15) NULL ;
	END ; 
GO


SET XACT_ABORT ON 
IF EXISTS ( SELECT  1
				FROM    sys.columns c 
				WHERE   object_id = OBJECT_ID(N'src.Bills')
						AND NAME =  'PpoCtgCoPayPenalty' )
	BEGIN
		BEGIN TRANSACTION
			EXEC SP_RENAME 'src.Bills.PpoCtgCoPayPenalty' ,  'PpoCtgCoPayPenaltyPercentage'  , 'COLUMN' 
		COMMIT TRANSACTION
	END
GO



SET XACT_ABORT ON 
IF EXISTS ( SELECT  1
				FROM    sys.columns c 
				WHERE   object_id = OBJECT_ID(N'src.Bills')
						AND NAME =  'AnalyzedPpoCtgCoPayPenalty' )
	BEGIN
		BEGIN TRANSACTION
			EXEC SP_RENAME 'src.Bills.AnalyzedPpoCtgCoPayPenalty' ,  'AnalyzedPpoCtgCoPayPenaltyPercentage'  , 'COLUMN' 
		COMMIT TRANSACTION
	END
GO



SET XACT_ABORT ON 
IF EXISTS ( SELECT  1
				FROM    sys.columns c 
				WHERE   object_id = OBJECT_ID(N'src.Bills')
						AND NAME =  'PpoCtgVunPenalty' )
	BEGIN
		BEGIN TRANSACTION
			EXEC SP_RENAME 'src.Bills.PpoCtgVunPenalty' ,  'PpoCtgVunPenaltyPercentage'  , 'COLUMN' 
		COMMIT TRANSACTION
	END
GO


SET XACT_ABORT ON 
IF EXISTS ( SELECT  1
				FROM    sys.columns c 
				WHERE   object_id = OBJECT_ID(N'src.Bills')
						AND NAME =  'AnalyzedPpoCtgVunPenalty' )
	BEGIN
		BEGIN TRANSACTION
			EXEC SP_RENAME 'src.Bills.AnalyzedPpoCtgVunPenalty' ,  'AnalyzedPpoCtgVunPenaltyPercentage'  , 'COLUMN' 
		COMMIT TRANSACTION
	END
GO



-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Bills'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Bills ON src.BILLS REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO













IF OBJECT_ID('src.BillsOverride', 'U') IS NULL
    BEGIN
        CREATE TABLE src.BillsOverride
            (
			OdsPostingGroupAuditId INT NOT NULL ,
			OdsCustomerId INT NOT NULL ,
			OdsCreateDate DATETIME2(7) NOT NULL ,
			OdsSnapshotDate DATETIME2(7) NOT NULL ,
			OdsRowIsCurrent BIT NOT NULL ,
			OdsHashbytesValue VARBINARY(8000) NULL ,
			DmlOperation CHAR(1) NOT NULL ,
			BillsOverrideID INT NOT NULL,
			BillIDNo INT NULL,
			LINE_NO SMALLINT NULL,
			UserId INT NULL,
			DateSaved DATETIME NULL,
			AmountBefore MONEY NULL,
			AmountAfter MONEY NULL,
			CodesOverrode VARCHAR(50) NULL,
			SeqNo INT NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.BillsOverride ADD 
        CONSTRAINT PK_BillsOverride PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillsOverrideID) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);
    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_BillsOverride'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_BillsOverride ON src.BillsOverride REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.BillsProviderNetwork', 'U') IS NULL
BEGIN
	CREATE TABLE src.BillsProviderNetwork (
		OdsPostingGroupAuditId INT NOT NULL
		,OdsCustomerId INT NOT NULL
		,OdsCreateDate DATETIME2(7) NOT NULL
		,OdsSnapshotDate DATETIME2(7) NOT NULL
		,OdsRowIsCurrent BIT NOT NULL
		,OdsHashbytesValue VARBINARY(8000) NULL
		,DmlOperation CHAR(1) NOT NULL
		,BillIdNo INT NOT NULL
		,NetworkId INT NULL
		,NetworkName VARCHAR(50) NULL
		) ON DP_Ods_PartitionScheme (OdsCustomerId)
		WITH (DATA_COMPRESSION = PAGE);

	ALTER TABLE src.BillsProviderNetwork ADD CONSTRAINT PK_BillsProviderNetwork PRIMARY KEY CLUSTERED (
		OdsPostingGroupAuditId
		,OdsCustomerId
		,BillIdNo
		)
		WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_BillsProviderNetwork ON src.BillsProviderNetwork REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
Go

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_BillsProviderNetwork'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_BillsProviderNetwork ON src.BillsProviderNetwork REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.BILLS_CTG_Endnotes', 'U') IS NULL
    BEGIN
        CREATE TABLE src.BILLS_CTG_Endnotes
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              BillIdNo INT NOT NULL ,
              Line_No SMALLINT NOT NULL ,
              Endnote INT NOT NULL ,
              RuleType VARCHAR(2) NULL ,
              RuleId INT NULL ,
              PreCertAction SMALLINT NULL ,
              PercentDiscount REAL NULL ,
              ActionId SMALLINT NULL 
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.BILLS_CTG_Endnotes ADD 
        CONSTRAINT PK_BILLS_CTG_Endnotes PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIdNo, Line_No, Endnote) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_BILLS_CTG_Endnotes ON src.BILLS_CTG_Endnotes REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_BILLS_CTG_Endnotes'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_BILLS_CTG_Endnotes ON src.BILLS_CTG_Endnotes REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.BILLS_DRG', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.BILLS_DRG
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  BillIdNo INT NOT NULL ,
			  PricerPassThru MONEY NULL ,
			  PricerCapital_Outlier_Amt MONEY NULL ,
			  PricerCapital_OldHarm_Amt MONEY NULL ,
			  PricerCapital_IME_Amt MONEY NULL ,
			  PricerCapital_HSP_Amt MONEY NULL ,
			  PricerCapital_FSP_Amt MONEY NULL ,
			  PricerCapital_Exceptions_Amt MONEY NULL ,
			  PricerCapital_DSH_Amt MONEY NULL ,
			  PricerCapitalPayment MONEY NULL ,
			  PricerDSH MONEY NULL ,
			  PricerIME MONEY NULL ,
			  PricerCostOutlier MONEY NULL ,
			  PricerHSP MONEY NULL ,
			  PricerFSP MONEY NULL ,
			  PricerTotalPayment MONEY NULL ,
			  PricerReturnMsg VARCHAR (255) NULL ,
			  ReturnDRG VARCHAR (3) NULL ,
			  ReturnDRGDesc VARCHAR (125) NULL ,
			  ReturnMDC VARCHAR (3) NULL ,
			  ReturnMDCDesc VARCHAR (100) NULL ,
			  ReturnDRGWt REAL NULL ,
			  ReturnDRGALOS REAL NULL ,
			  ReturnADX VARCHAR (8) NULL ,
			  ReturnSDX VARCHAR (8) NULL ,
			  ReturnMPR VARCHAR (8) NULL ,
			  ReturnPR2 VARCHAR (8) NULL ,
			  ReturnPR3 VARCHAR (8) NULL ,
			  ReturnNOR VARCHAR (8) NULL ,
			  ReturnNO2 VARCHAR (8) NULL ,
			  ReturnCOM VARCHAR (255) NULL ,
			  ReturnCMI SMALLINT NULL ,
			  ReturnDCC VARCHAR (8) NULL ,
			  ReturnDX1 VARCHAR (8) NULL ,
			  ReturnDX2 VARCHAR (8) NULL ,
			  ReturnDX3 VARCHAR (8) NULL ,
			  ReturnMCI SMALLINT NULL ,
			  ReturnOR1 VARCHAR (8) NULL ,
			  ReturnOR2 VARCHAR (8) NULL ,
			  ReturnOR3 VARCHAR (8) NULL ,
			  ReturnTRI SMALLINT NULL ,
			  SOJ VARCHAR (2) NULL ,
			  OPCERT VARCHAR (7) NULL ,
			  BlendCaseInclMalp REAL NULL ,
			  CapitalCost REAL NULL ,
			  HospBadDebt REAL NULL ,
			  ExcessPhysMalp REAL NULL ,
			  SparcsPerCase REAL NULL ,
			  AltLevelOfCare REAL NULL ,
			  DRGWgt REAL NULL ,
			  TransferCapital REAL NULL ,
			  NYDrgType SMALLINT NULL ,
			  LOS SMALLINT NULL ,
			  TrimPoint SMALLINT NULL ,
			  GroupBlendPercentage REAL NULL ,
			  AdjustmentFactor REAL NULL ,
			  HospLongStayGroupPrice REAL NULL ,
			  TotalDRGCharge MONEY NULL ,
			  BlendCaseAdj REAL NULL ,
			  CapitalCostAdj REAL NULL ,
			  NonMedicareCaseMix REAL NULL ,
			  HighCostChargeConverter REAL NULL ,
			  DischargeCasePaymentRate MONEY NULL ,
			  DirectMedicalEducation MONEY NULL ,
			  CasePaymentCapitalPerDiem MONEY NULL ,
			  HighCostOutlierThreshold MONEY NULL ,
			  ISAF REAL NULL ,
			  ReturnSOI SMALLINT NULL ,
			  CapitalCostPerDischarge MONEY NULL ,
			  ReturnSOIDesc VARCHAR (20) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.BILLS_DRG ADD 
     CONSTRAINT PK_BILLS_DRG PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIdNo) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_BILLS_DRG ON src.BILLS_DRG   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF  EXISTS ( SELECT  1
			FROM    sys.columns c 
					INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
			WHERE   object_id = OBJECT_ID(N'src.BILLS_DRG')
					AND c.name = 'ReturnDRGDesc' 
					AND NOT ( t.name = 'VARCHAR' 
						 AND c.max_length = '125'
						   ) ) 
	BEGIN
		ALTER TABLE src.BILLS_DRG ALTER COLUMN ReturnDRGDesc VARCHAR(125) NULL ;
	END ; 
GO

IF  EXISTS ( SELECT  1
			FROM    sys.columns c 
					INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
			WHERE   object_id = OBJECT_ID(N'src.BILLS_DRG')
					AND c.name = 'ReturnMDCDesc' 
					AND NOT ( t.name = 'VARCHAR' 
						 AND c.max_length = '100'
						   ) ) 
	BEGIN
		ALTER TABLE src.BILLS_DRG ALTER COLUMN ReturnMDCDesc VARCHAR(100) NULL ;
	END ; 
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1 
                FROM sys.stats
                WHERE name = 'PK_BILLS_DRG' 
                AND is_incremental = 1)  BEGIN
ALTER INDEX PK_BILLS_DRG ON src.BILLS_DRG   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
END ;
GO

IF OBJECT_ID('src.BILLS_Endnotes', 'U') IS NULL
    BEGIN
        CREATE TABLE src.BILLS_Endnotes
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              BillIDNo INT NOT NULL ,
              LINE_NO SMALLINT NOT NULL ,
              EndNote SMALLINT NOT NULL ,
              Referral VARCHAR(200) NULL ,
              PercentDiscount REAL NULL ,
              ActionId SMALLINT NULL ,
			  EndnoteTypeId TINYINT CONSTRAINT DF_BILLS_Endnotes_EndnoteTypeId DEFAULT(1) NOT NULL

            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.BILLS_Endnotes ADD 
        CONSTRAINT PK_BILLS_Endnotes PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIDNo, LINE_NO, EndNote, EndnoteTypeId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_BILLS_Endnotes ON src.BILLS_Endnotes REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID('src.Bills_Endnotes')
                        AND name = 'Referral'
                        AND max_length = 200 )
ALTER TABLE src.Bills_Endnotes 
ALTER COLUMN Referral VARCHAR(200) NULL
GO

--Add Code Block to Check
/*
	if primary key does not include EndnoteTypeId
		1. rename old table
		2. create a new table
		3. create new primary key
		4. partition
		5. update hashbyte
		6. switch partition.
*/
IF NOT EXISTS ( SELECT 1
			FROM sys.indexes AS i 
			INNER JOIN sys.index_columns AS ic 
				ON i.OBJECT_ID = ic.OBJECT_ID 
				AND i.index_id = ic.index_id 
				AND i.is_primary_key = 1 
				AND ic.OBJECT_ID = OBJECT_ID('src.bills_endnotes')
			INNER JOIN sys.columns AS c 
				ON ic.object_id = c.object_id 
				AND ic.column_id = c.column_id
				AND c.name = 'EndnoteTypeId' )
BEGIN
	SET XACT_ABORT ON;

	

	--1. rename old table
	EXEC sp_rename 'src.BILLS_Endnotes.PK_BILLS_Endnotes', 'PK_BILLS_Endnotes_bak', N'INDEX'
	EXEC sp_rename 'src.Bills_Endnotes', 'Bills_Endnotes_bak'

	--2. create a new table with partition
	IF OBJECT_ID('src.BILLS_Endnotes', 'U') IS NULL
    BEGIN
        CREATE TABLE src.BILLS_Endnotes
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              BillIDNo INT NOT NULL ,
              LINE_NO SMALLINT NOT NULL ,
              EndNote SMALLINT NOT NULL ,
              Referral VARCHAR(200) NULL ,
              PercentDiscount REAL NULL ,
              ActionId SMALLINT NULL ,
			  EndnoteTypeId TINYINT CONSTRAINT DF_BILLS_Endnotes_EndnoteTypeId DEFAULT(1) NOT NULL

            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.BILLS_Endnotes ADD 
        CONSTRAINT PK_BILLS_Endnotes PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIDNo, LINE_NO, EndNote, EndnoteTypeId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_BILLS_Endnotes ON src.BILLS_Endnotes REBUILD WITH(STATISTICS_INCREMENTAL = ON);
	END

	--3. for each partition, update EndnoteTypeId and OdsHashbytesValue, then switch partition
	IF OBJECT_ID('tempdb..#partitions','U') IS NOT NULL
		DROP TABLE #partitions;
	
	SELECT partition_number, SUM(rows) AS Rows 
	INTO #partitions
	FROM sys.partitions p
	JOIN sys.tables t
		ON p.object_id = t.object_id
		AND SCHEMA_NAME(t.schema_id) = 'src'
		AND t.name = 'Bills_Endnotes_bak'
		AND p.rows != 0
		AND p.index_id = 1
	GROUP BY partition_number
	ORDER BY Rows DESC;

	DECLARE @partition_number INT;

	DECLARE PARTITION_CURSOR CURSOR FOR 
	SELECT partition_number
	FROM #partitions;

	OPEN PARTITION_CURSOR

	FETCH NEXT FROM PARTITION_CURSOR INTO @partition_number

	WHILE @@FETCH_STATUS=0
	BEGIN
		BEGIN TRANSACTION T1;
		--3.1 update EndnoteTypeId and OdsHashbytesValue
		IF EXISTS( SELECT 1 FROM sys.tables t WHERE SCHEMA_NAME(t.schema_id) = 'stg' and t.name = 'BILLS_Endnotes_bak')
		DROP TABLE stg.BILLS_Endnotes_bak
		
		CREATE TABLE stg.BILLS_Endnotes_bak
			(
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              BillIDNo INT NOT NULL ,
              LINE_NO SMALLINT NOT NULL ,
              EndNote SMALLINT NOT NULL ,
              Referral VARCHAR(200) NULL ,
              PercentDiscount REAL NULL ,
              ActionId SMALLINT NULL ,
			  EndnoteTypeId TINYINT CONSTRAINT DF_BILLS_Endnotes_EndnoteTypeId DEFAULT(1) NOT NULL

            )ON DP_Ods_PartitionScheme(OdsCustomerId)
			WITH (
                 DATA_COMPRESSION = PAGE);
		
		--Create clustered index on stg table.
		ALTER TABLE stg.BILLS_Endnotes_bak ADD 
        CONSTRAINT PK_BILLS_Endnotes PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIDNo, LINE_NO, EndNote, EndnoteTypeId) WITH (DATA_COMPRESSION = PAGE);

		INSERT stg.BILLS_Endnotes_bak
		(
			OdsPostingGroupAuditId
		  ,OdsCustomerId
		  ,OdsCreateDate
		  ,OdsSnapshotDate
		  ,OdsRowIsCurrent
		  ,OdsHashbytesValue
		  ,DmlOperation
		  ,BillIDNo
		  ,LINE_NO
		  ,EndNote
		  ,Referral
		  ,PercentDiscount
		  ,ActionId
		  ,EndnoteTypeId
		)
		SELECT 
			OdsPostingGroupAuditId
		  ,OdsCustomerId
		  ,OdsCreateDate
		  ,OdsSnapshotDate
		  ,OdsRowIsCurrent
		  ,HASHBYTES('SHA1', (SELECT [BillIDNo]
									,[LINE_NO]
									,[EndNote]
									,[Referral]
									,[PercentDiscount]
									,[ActionId]
									,1 AS EndnoteTypeId FOR XML RAW)) AS OdsHashbytesValue
		  ,DmlOperation
		  ,BillIDNo
		  ,LINE_NO
		  ,EndNote
		  ,Referral
		  ,PercentDiscount
		  ,ActionId
		  ,1
		FROM src.Bills_Endnotes_bak
		WHERE OdsCustomerId = @partition_number
		ORDER BY OdsPostingGroupAuditId, OdsCustomerId, BillIDNo, LINE_NO, EndNote;

		--3.2 switch partition
		DECLARE @SQL VARCHAR(MAX) = '';
		SET @SQL = '
		ALTER TABLE stg.BILLS_Endnotes_bak SWITCH PARTITION ' + CAST(@partition_number AS VARCHAR(10)) + ' TO src.BILLS_Endnotes PARTITION ' + CAST(@partition_number AS VARCHAR(10)) + '
		DROP TABLE stg.BILLS_Endnotes_bak ';

		EXEC(@SQL);

		COMMIT TRANSACTION T1;

		FETCH NEXT FROM PARTITION_CURSOR INTO @partition_number
		

	END

	CLOSE PARTITION_CURSOR;  
	DEALLOCATE PARTITION_CURSOR;

	--DROP TABLE src.BILLS_Endnotes_bak;

	
END

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_BILLS_Endnotes'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_BILLS_Endnotes ON src.BILLS_Endnotes REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO


IF OBJECT_ID('src.Bills_OverrideEndNotes', 'U') IS NULL
    BEGIN
        CREATE TABLE src.Bills_OverrideEndNotes
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL , 
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              OverrideEndNoteID INT NOT NULL ,
              BillIdNo INT NULL ,
              Line_No SMALLINT NULL ,
              OverrideEndNote SMALLINT NULL ,
              PercentDiscount REAL NULL ,
              ActionId SMALLINT NULL 
             
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Bills_OverrideEndNotes ADD 
        CONSTRAINT PK_Bills_OverrideEndNotes PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, OverrideEndNoteID) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Bills_OverrideEndNotes ON src.Bills_OverrideEndNotes REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Bills_OverrideEndNotes'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Bills_OverrideEndNotes ON src.Bills_OverrideEndNotes REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.Bills_Pharm', 'U') IS NULL
    BEGIN
        CREATE TABLE src.Bills_Pharm
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,  
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              BillIdNo INT NOT NULL ,
              Line_No SMALLINT NOT NULL ,
              LINE_NO_DISP SMALLINT NULL ,
              DateOfService DATETIME NULL ,
              NDC VARCHAR(13) NULL ,
              PriceTypeCode VARCHAR(2) NULL ,
              Units REAL NULL ,
              Charged MONEY NULL ,
              Allowed MONEY NULL ,
              EndNote VARCHAR(20) NULL ,
              Override SMALLINT NULL ,
              Override_Rsn VARCHAR(10) NULL ,
              Analyzed MONEY NULL ,
              CTGPenalty MONEY NULL ,
              PrePPOAllowed MONEY NULL ,
              PPODate DATETIME NULL ,
              POS_RevCode VARCHAR(4) NULL ,
              DPAllowed MONEY NULL ,
              HCRA_Surcharge MONEY NULL ,
              EndDateOfService DATETIME NULL ,
              RepackagedNdc VARCHAR(13) NULL ,
              OriginalNdc VARCHAR(13) NULL ,
              UnitOfMeasureId TINYINT NULL ,
              PackageTypeOriginalNdc VARCHAR(2) NULL ,
			  PpoCtgPenalty DECIMAL(19, 4) NULL ,
			  ServiceCode VARCHAR (25) NULL ,
              PreApportionedAmount DECIMAL(19,4) NULL,
			  DeductibleApplied DECIMAL(19,4) NULL,
			  BillReviewResults DECIMAL(19,4) NULL,
			  PreOverriddenDeductible DECIMAL(19,4) NULL,
		      RemainingBalance DECIMAL (19,4) NULL,
			  CtgCoPayPenalty DECIMAL(19,4) NULL,
              PpoCtgCoPayPenalty DECIMAL(19,4) NULL,
			  CtgVunPenalty DECIMAL(19,4) NULL,
			  PpoCtgVunPenalty DECIMAL(19,4) NULL

			 ,RenderingNpi VARCHAR(15) NULL 
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Bills_Pharm ADD 
        CONSTRAINT PK_Bills_Pharm PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIdNo, Line_No) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Bills_Pharm ON src.Bills_Pharm REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills_Pharm')
						AND NAME = 'DeductibleApplied' )
	BEGIN
		ALTER TABLE src.Bills_Pharm ADD DeductibleApplied DECIMAL(19,4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills_Pharm')
						AND NAME = 'PreOverriddenDeductible' )
	BEGIN
		ALTER TABLE src.Bills_Pharm ADD PreOverriddenDeductible DECIMAL(19,4) NULL ;
	END ; 
GO


SET XACT_ABORT ON 
IF EXISTS ( SELECT  1
				FROM    sys.columns c 
				WHERE   object_id = OBJECT_ID(N'src.Bills_Pharm')
						AND NAME =  'PreDeductibleAllowed' )
	BEGIN
		BEGIN TRANSACTION
			EXEC SP_RENAME 'src.Bills_Pharm.PreDeductibleAllowed' ,  'BillReviewResults'  , 'COLUMN' 
		COMMIT TRANSACTION
	END
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills_Pharm')
						AND NAME = 'BillReviewResults' )
	BEGIN
		ALTER TABLE src.Bills_Pharm ADD BillReviewResults DECIMAL(19,4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills_Pharm')
						AND NAME = 'RemainingBalance' )
	BEGIN
		ALTER TABLE src.Bills_Pharm ADD RemainingBalance DECIMAL(19,4) NULL;	
	END	
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills_Pharm')
						AND NAME = 'CtgCoPayPenalty' )
	BEGIN
		ALTER TABLE src.Bills_Pharm ADD CtgCoPayPenalty DECIMAL(19,4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills_Pharm')
						AND NAME = 'PpoCtgCoPayPenalty' )
	BEGIN
		ALTER TABLE src.Bills_Pharm ADD PpoCtgCoPayPenalty DECIMAL(19,4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills_Pharm')
						AND NAME = 'CtgVunPenalty' )
	BEGIN
		ALTER TABLE src.Bills_Pharm ADD CtgVunPenalty DECIMAL(19,4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills_Pharm')
						AND NAME = 'PpoCtgVunPenalty' )
	BEGIN
		ALTER TABLE src.Bills_Pharm ADD PpoCtgVunPenalty DECIMAL(19,4) NULL ;
	END ; 
GO


IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills_Pharm')
						AND NAME = 'RenderingNpi' )
	BEGIN
		ALTER TABLE src.Bills_Pharm ADD RenderingNpi VARCHAR(15) NULL ;
	END ; 
GO


SET XACT_ABORT ON 
IF EXISTS ( SELECT  1
				FROM    sys.columns c 
				WHERE   object_id = OBJECT_ID(N'src.Bills_Pharm')
						AND NAME =  'PpoCtgCoPayPenalty' )
	BEGIN
		BEGIN TRANSACTION
			EXEC SP_RENAME 'src.Bills_Pharm.PpoCtgCoPayPenalty' ,  'PpoCtgCoPayPenaltyPercentage'  , 'COLUMN' 
		COMMIT TRANSACTION
	END
GO



SET XACT_ABORT ON 
IF EXISTS ( SELECT  1
				FROM    sys.columns c 
				WHERE   object_id = OBJECT_ID(N'src.Bills_Pharm')
						AND NAME =  'PpoCtgVunPenalty' )
	BEGIN
		BEGIN TRANSACTION
			EXEC SP_RENAME 'src.Bills_Pharm.PpoCtgVunPenalty' ,  'PpoCtgVunPenaltyPercentage'  , 'COLUMN' 
		COMMIT TRANSACTION
	END
GO


-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Bills_Pharm'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Bills_Pharm ON src.Bills_Pharm REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

-- Looks like this was introduced in DP 9.5 but never made it into the ODS.  MASA seems to expect is, so
-- while I'm here, let's add it.
IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills_Pharm')
						AND NAME = 'PpoCtgPenalty' )
	BEGIN
		ALTER TABLE src.Bills_Pharm ADD PpoCtgPenalty DECIMAL(19, 4) NULL;
	
	END 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills_Pharm')
						AND NAME = 'ServiceCode' )
	BEGIN
		ALTER TABLE src.Bills_Pharm ADD ServiceCode VARCHAR(25) NULL ;
	
	END 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills_Pharm')
						AND NAME = 'PreApportionedAmount' )
	BEGIN
		ALTER TABLE src.Bills_Pharm ADD PreApportionedAmount DECIMAL(19,4) NULL;	
	END	
GO










IF OBJECT_ID('src.Bills_Pharm_CTG_Endnotes', 'U') IS NULL
    BEGIN
        CREATE TABLE src.Bills_Pharm_CTG_Endnotes
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL , 
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              BillIDNo INT NOT NULL ,
              LINE_NO SMALLINT NOT NULL ,
              EndNote SMALLINT NOT NULL ,
              RuleType VARCHAR(2) NULL ,
              RuleId INT NULL ,
              PreCertAction SMALLINT NULL ,
              PercentDiscount REAL NULL ,
              ActionId SMALLINT NULL 
             
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Bills_Pharm_CTG_Endnotes ADD 
        CONSTRAINT PK_Bills_Pharm_CTG_Endnotes PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIDNo, LINE_NO, EndNote) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Bills_Pharm_CTG_Endnotes ON src.Bills_Pharm_CTG_Endnotes REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Bills_Pharm_CTG_Endnotes'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Bills_Pharm_CTG_Endnotes ON src.Bills_Pharm_CTG_Endnotes REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.Bills_Pharm_Endnotes', 'U') IS NULL
    BEGIN
        CREATE TABLE src.Bills_Pharm_Endnotes
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL , 
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              BillIDNo INT NOT NULL ,
              LINE_NO SMALLINT NOT NULL ,
              EndNote SMALLINT NOT NULL ,
              Referral VARCHAR(200) NULL ,
              PercentDiscount REAL NULL ,
              ActionId SMALLINT NULL ,
			  EndnoteTypeId TINYINT CONSTRAINT DF_Bills_Pharm_Endnotes_EndnoteTypeId DEFAULT(1) NOT NULL
             
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Bills_Pharm_Endnotes ADD 
        CONSTRAINT PK_Bills_Pharm_Endnotes PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIDNo, LINE_NO, EndNote, EndnoteTypeId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Bills_Pharm_Endnotes ON src.Bills_Pharm_Endnotes REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID('src.Bills_Pharm_Endnotes')
                        AND name = 'Referral'
                        AND max_length = 200 )
ALTER TABLE src.Bills_Pharm_Endnotes 
ALTER COLUMN Referral VARCHAR(200) NULL
GO

--Add Code Block to Check
/*
	if primary key does not exist
		1. rename old table
		2. create a new table
		3. create new primary key
		4. partition
		5. update hashbyte
		6. switch partition.
*/
IF NOT EXISTS ( SELECT 1
			FROM sys.indexes AS i 
			INNER JOIN sys.index_columns AS ic 
				ON i.OBJECT_ID = ic.OBJECT_ID 
				AND i.index_id = ic.index_id 
				AND i.is_primary_key = 1 
				AND ic.OBJECT_ID = OBJECT_ID('src.Bills_Pharm_Endnotes')
			INNER JOIN sys.columns AS c 
				ON ic.object_id = c.object_id 
				AND ic.column_id = c.column_id
				AND c.name = 'EndnoteTypeId' )
BEGIN
	SET XACT_ABORT ON;

	

	--1. rename old table
	EXEC sp_rename 'src.Bills_Pharm_Endnotes.PK_Bills_Pharm_Endnotes', 'PK_Bills_Pharm_Endnotes_bak', N'INDEX'
	EXEC sp_rename 'src.Bills_Pharm_Endnotes', 'Bills_Pharm_Endnotes_bak'

	--2. create a new table with partition
	IF OBJECT_ID('src.Bills_Pharm_Endnotes', 'U') IS NULL
    BEGIN
        CREATE TABLE src.Bills_Pharm_Endnotes
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              BillIDNo INT NOT NULL ,
              LINE_NO SMALLINT NOT NULL ,
              EndNote SMALLINT NOT NULL ,
              Referral VARCHAR(200) NULL ,
              PercentDiscount REAL NULL ,
              ActionId SMALLINT NULL ,
			  EndnoteTypeId TINYINT CONSTRAINT DF_Bills_Pharm_Endnotes_EndnoteTypeId DEFAULT(1) NOT NULL

            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Bills_Pharm_Endnotes ADD 
        CONSTRAINT PK_Bills_Pharm_Endnotes PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIDNo, LINE_NO, EndNote, EndnoteTypeId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Bills_Pharm_Endnotes ON src.Bills_Pharm_Endnotes REBUILD WITH(STATISTICS_INCREMENTAL = ON);
	END

	--3. for each partition, update EndnoteTypeId and OdsHashbytesValue, then switch partition
	IF OBJECT_ID('tempdb..#partitions','U') IS NOT NULL
		DROP TABLE #partitions;
	
	SELECT partition_number, SUM(rows) AS Rows 
	INTO #partitions
	FROM sys.partitions p
	JOIN sys.tables t
		ON p.object_id = t.object_id
		AND SCHEMA_NAME(t.schema_id) = 'src'
		AND t.name = 'Bills_Pharm_Endnotes_bak'
		AND p.rows != 0
		AND p.index_id = 1
	GROUP BY partition_number
	ORDER BY Rows DESC;


	DECLARE @partition_number INT;

	DECLARE PARTITION_CURSOR CURSOR FOR 
	SELECT partition_number
	FROM #partitions;

	OPEN PARTITION_CURSOR

	FETCH NEXT FROM PARTITION_CURSOR INTO @partition_number

	WHILE @@FETCH_STATUS=0
	BEGIN
		BEGIN TRANSACTION T1;
		--3.1 update EndnoteTypeId and OdsHashbytesValue
		IF EXISTS( SELECT 1 FROM sys.tables t WHERE SCHEMA_NAME(t.schema_id) = 'stg' and t.name = 'Bills_Pharm_Endnotes_bak')
		DROP TABLE stg.Bills_Pharm_Endnotes_bak
		
		CREATE TABLE stg.Bills_Pharm_Endnotes_bak
			(
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              BillIDNo INT NOT NULL ,
              LINE_NO SMALLINT NOT NULL ,
              EndNote SMALLINT NOT NULL ,
              Referral VARCHAR(200) NULL ,
              PercentDiscount REAL NULL ,
              ActionId SMALLINT NULL ,
			  EndnoteTypeId TINYINT CONSTRAINT DF_Bills_Pharm_Endnotes_EndnoteTypeId DEFAULT(1) NOT NULL

            )ON DP_Ods_PartitionScheme(OdsCustomerId)
			WITH (
                 DATA_COMPRESSION = PAGE);
		
		--Create clustered index on stg table.
		ALTER TABLE stg.Bills_Pharm_Endnotes_bak ADD 
        CONSTRAINT PK_Bills_Pharm_Endnotes PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIDNo, LINE_NO, EndNote, EndnoteTypeId) WITH (DATA_COMPRESSION = PAGE);

		--Insert Data
		INSERT stg.Bills_Pharm_Endnotes_bak
		(
			OdsPostingGroupAuditId
		  ,OdsCustomerId
		  ,OdsCreateDate
		  ,OdsSnapshotDate
		  ,OdsRowIsCurrent
		  ,OdsHashbytesValue
		  ,DmlOperation
		  ,BillIDNo
		  ,LINE_NO
		  ,EndNote
		  ,Referral
		  ,PercentDiscount
		  ,ActionId
		  ,EndnoteTypeId
		)
		SELECT 
			OdsPostingGroupAuditId
		  ,OdsCustomerId
		  ,OdsCreateDate
		  ,OdsSnapshotDate
		  ,OdsRowIsCurrent
		  ,HASHBYTES('SHA1', (SELECT [BillIDNo]
									,[LINE_NO]
									,[EndNote]
									,[Referral]
									,[PercentDiscount]
									,[ActionId]
									,1 AS EndnoteTypeId FOR XML RAW)) AS OdsHashbytesValue
		  ,DmlOperation
		  ,BillIDNo
		  ,LINE_NO
		  ,EndNote
		  ,Referral
		  ,PercentDiscount
		  ,ActionId
		  ,1
		FROM src.Bills_Pharm_Endnotes_bak
		WHERE OdsCustomerId = @partition_number
		ORDER BY OdsPostingGroupAuditId, OdsCustomerId, BillIDNo, LINE_NO, EndNote;

		--4.2 switch partition
		DECLARE @SQL VARCHAR(MAX) = '';

		SET @SQL = '
		ALTER TABLE stg.Bills_Pharm_Endnotes_bak SWITCH PARTITION ' + CAST(@partition_number AS VARCHAR(10)) + ' TO src.Bills_Pharm_Endnotes PARTITION ' + CAST(@partition_number AS VARCHAR(10)) + '
		DROP TABLE stg.Bills_Pharm_Endnotes_bak ';

		EXEC(@SQL);

		COMMIT TRANSACTION T1;

		FETCH NEXT FROM PARTITION_CURSOR INTO @partition_number
		

	END

	CLOSE PARTITION_CURSOR;  
	DEALLOCATE PARTITION_CURSOR;

	--DROP TABLE src.Bills_Pharm_Endnotes_bak;

	
END



-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Bills_Pharm_Endnotes'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Bills_Pharm_Endnotes ON src.Bills_Pharm_Endnotes REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO


IF OBJECT_ID('src.Bills_Pharm_OverrideEndNotes', 'U') IS NULL
    BEGIN
        CREATE TABLE src.Bills_Pharm_OverrideEndNotes
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL , 
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              OverrideEndNoteID INT NOT NULL ,
              BillIdNo INT NULL ,
              Line_No SMALLINT NULL ,
              OverrideEndNote SMALLINT NULL ,
              PercentDiscount REAL NULL ,
              ActionId SMALLINT NULL 
             
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Bills_Pharm_OverrideEndNotes ADD 
        CONSTRAINT PK_Bills_Pharm_OverrideEndNotes PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, OverrideEndNoteID) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Bills_Pharm_OverrideEndNotes ON src.Bills_Pharm_OverrideEndNotes REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Bills_Pharm_OverrideEndNotes'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Bills_Pharm_OverrideEndNotes ON src.Bills_Pharm_OverrideEndNotes REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.Bills_Tax', 'U') IS NULL
    BEGIN
        CREATE TABLE src.Bills_Tax
            (
			OdsPostingGroupAuditId INT NOT NULL ,
			OdsCustomerId INT NOT NULL ,
			OdsCreateDate DATETIME2(7) NOT NULL ,
			OdsSnapshotDate DATETIME2(7) NOT NULL ,
			OdsRowIsCurrent BIT NOT NULL ,
			OdsHashbytesValue VARBINARY(8000) NULL ,
			DmlOperation CHAR(1) NOT NULL ,
			BillsTaxId INT NOT NULL,
			TableType SMALLINT NULL,
			BillIdNo INT NULL,
			Line_No SMALLINT NULL,
			SeqNo SMALLINT NULL,
			TaxTypeId SMALLINT NULL,
			ImportTaxRate DECIMAL(5, 5) NULL,
			Tax MONEY NULL,
			OverridenTax MONEY NULL,
			ImportTaxAmount MONEY NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Bills_Tax ADD 
        CONSTRAINT PK_Bills_Tax PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillsTaxId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Bills_Tax ON src.Bills_Tax REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Bills_Tax'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Bills_Tax ON src.Bills_Tax REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.BILL_HDR', 'U') IS NULL
    BEGIN
        CREATE TABLE src.BILL_HDR
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              BillIDNo INT NOT NULL ,
              CMT_HDR_IDNo INT NULL ,
              DateSaved DATETIME NULL ,
              DateRcv DATETIME NULL ,
              InvoiceNumber VARCHAR(40) NULL ,
              InvoiceDate DATETIME NULL ,
              FileNumber VARCHAR(50) NULL ,
              Note VARCHAR(20) NULL ,
              NoLines SMALLINT NULL ,
              AmtCharged MONEY NULL ,
              AmtAllowed MONEY NULL ,
              ReasonVersion SMALLINT NULL ,
              Region VARCHAR(50) NULL ,
              PvdUpdateCounter SMALLINT NULL ,
              FeatureID INT NULL ,
              ClaimDateLoss DATETIME NULL ,
              CV_Type VARCHAR(2) NULL ,
              Flags INT NULL ,
              WhoCreate VARCHAR(15) NULL ,
              WhoLast VARCHAR(15) NULL ,
              AcceptAssignment SMALLINT NULL ,
              EmergencyService SMALLINT NULL ,
              CmtPaidDeductible MONEY NULL ,
              InsPaidLimit MONEY NULL ,
              StatusFlag VARCHAR(2) NULL ,
              OfficeId INT NULL ,
              CmtPaidCoPay MONEY NULL ,
              AmbulanceMethod SMALLINT NULL ,
              StatusDate DATETIME NULL ,
              Category INT NULL ,
              CatDesc VARCHAR(1000) NULL ,
              AssignedUser VARCHAR(15) NULL ,
              CreateDate DATETIME NULL ,
              PvdZOS VARCHAR(12) NULL ,
              PPONumberSent SMALLINT NULL ,
              AdmissionDate DATETIME NULL ,
              DischargeDate DATETIME NULL ,
              DischargeStatus SMALLINT NULL ,
              TypeOfBill VARCHAR(4) NULL ,
              SentryMessage VARCHAR(1000) NULL ,
              AmbulanceZipOfPickup VARCHAR(12) NULL ,
              AmbulanceNumberOfPatients SMALLINT NULL ,
              WhoCreateID INT NULL ,
              WhoLastId INT NULL ,
              NYRequestDate DATETIME NULL ,
              NYReceivedDate DATETIME NULL ,
              ImgDocId VARCHAR(50) NULL ,
              PaymentDecision SMALLINT NULL ,
              PvdCMSId VARCHAR(6) NULL ,
              PvdNPINo VARCHAR(15) NULL ,
              DischargeHour VARCHAR(2) NULL ,
              PreCertChanged SMALLINT NULL ,
              DueDate DATETIME NULL ,
              AttorneyIDNo INT NULL ,
              AssignedGroup INT NULL ,
              LastChangedOn DATETIME NULL ,
              PrePPOAllowed MONEY NULL ,
              PPSCode SMALLINT NULL ,
              SOI SMALLINT NULL ,
              StatementStartDate DATETIME NULL ,
              StatementEndDate DATETIME NULL ,
              DeductibleOverride BIT NULL ,
              AdmissionType TINYINT NULL ,
              CoverageType VARCHAR(2) NULL ,
              PricingProfileId INT NULL ,
              DesignatedPricingState VARCHAR(2) NULL ,
              DateAnalyzed DATETIME NULL ,
              SentToPpoSysId INT NULL ,
			  PricingState VARCHAR(2) NULL,
			  BillVpnEligible  BIT NULL,
			  ApportionmentPercentage DECIMAL(5,2) NULL,
			  BillSourceId TINYINT NULL,
			  OutOfStateProviderNumber INT NULL,
			  FloridaDeductibleRuleEligible BIT NULL
            )
        ON  DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.BILL_HDR ADD 
        CONSTRAINT PK_Bill_Hdr PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIDNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);
		
		ALTER INDEX PK_Bill_Hdr ON src.BILL_HDR REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END;
GO

-- Add Coveragetype column to src.Bill_Hdr.
IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.BILL_HDR')
                        AND NAME = 'CoverageType' )
    BEGIN
        ALTER TABLE src.BILL_HDR ADD CoverageType VARCHAR(2) NULL;
    END;
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.BILL_HDR')
                        AND NAME = 'PricingProfileId' )
    BEGIN
        ALTER TABLE src.BILL_HDR ADD PricingProfileId INT NULL;
    END;
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.BILL_HDR')
                        AND NAME = 'DesignatedPricingState' )
    BEGIN
        ALTER TABLE src.BILL_HDR ADD DesignatedPricingState VARCHAR(2) NULL;
    END;
GO

IF EXISTS ( SELECT  1
            FROM    sys.columns c
                    INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
            WHERE   c.object_id = OBJECT_ID(N'src.BILL_HDR')
                    AND c.name = 'Region'
                    AND NOT ( t.name = 'VARCHAR'
                              AND c.max_length = 50
                            ) )
    BEGIN
        ALTER TABLE src.BILL_HDR ALTER COLUMN Region VARCHAR(50) NULL;
    END;
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.BILL_HDR')
                        AND NAME = 'DateAnalyzed' )
    BEGIN
        ALTER TABLE src.BILL_HDR ADD DateAnalyzed DATETIME NULL;
    END;
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.BILL_HDR')
                        AND NAME = 'SentToPpoSysId' )
    BEGIN
        ALTER TABLE src.BILL_HDR ADD SentToPpoSysId INT NULL;
    END;
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.BILL_HDR')
                        AND NAME = 'PricingState' )
    BEGIN
        ALTER TABLE src.BILL_HDR ADD PricingState VARCHAR(2) NULL;
    END;
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.BILL_HDR')
                        AND NAME = 'BillVpnEligible' )
    BEGIN
        ALTER TABLE src.BILL_HDR ADD BillVpnEligible BIT NULL;
    END;
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.BILL_HDR')
                        AND NAME = 'ApportionmentPercentage' )
    BEGIN
        ALTER TABLE src.BILL_HDR ADD ApportionmentPercentage DECIMAL(5,2) NULL;
    END;
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.BILL_HDR')
						AND NAME = 'BillSourceId' )
	BEGIN
		ALTER TABLE src.BILL_HDR ADD BillSourceId TINYINT NULL ;
	END ; 
GO


IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.BILL_HDR')
						AND NAME = 'OutOfStateProviderNumber' )
	BEGIN
		ALTER TABLE src.BILL_HDR ADD OutOfStateProviderNumber INT NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.BILL_HDR')
						AND NAME = 'FloridaDeductibleRuleEligible' )
	BEGIN
		ALTER TABLE src.BILL_HDR ADD FloridaDeductibleRuleEligible BIT NULL ;
	END ; 
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Bill_Hdr'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Bill_Hdr ON src.BILL_HDR REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO







IF OBJECT_ID('src.Bill_History', 'U') IS NULL
    BEGIN
        CREATE TABLE src.Bill_History
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              BillIdNo INT NOT NULL ,
              SeqNo INT NOT NULL ,
              DateCommitted DATETIME NULL ,
              AmtCommitted MONEY NULL ,
              UserId VARCHAR(15) NULL ,
              AmtCoPay MONEY NULL ,
              AmtDeductible MONEY NULL ,
              Flags INT NULL ,
              AmtSalesTax MONEY NULL ,
              AmtOtherTax MONEY NULL ,
              DeductibleOverride BIT NULL ,
			  PricingState VARCHAR(2) NULL,
			  ApportionmentPercentage DECIMAL(5,2) NULL,
			  FloridaDeductibleRuleEligible BIT NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Bill_History ADD 
        CONSTRAINT PK_Bill_History PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIdNo, SeqNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Bill_History ON src.Bill_History REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Add column to src.Bill_History.
IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.Bill_History')
                        AND NAME = 'PricingState' )
BEGIN
    ALTER TABLE src.Bill_History ADD PricingState VARCHAR(2) NULL
END
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.Bill_History')
                        AND NAME = 'ApportionmentPercentage' )
BEGIN
    ALTER TABLE src.Bill_History ADD ApportionmentPercentage DECIMAL(5,2) NULL
END
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bill_History')
						AND NAME = 'FloridaDeductibleRuleEligible' )
	BEGIN
		ALTER TABLE src.Bill_History ADD FloridaDeductibleRuleEligible BIT NULL ;
	END ; 
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Bill_History'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Bill_History ON src.Bill_History REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.Bill_Payment_Adjustments', 'U') IS NULL
    BEGIN
        CREATE TABLE src.Bill_Payment_Adjustments
            (
			OdsPostingGroupAuditId INT NOT NULL ,
			OdsCustomerId INT NOT NULL ,
			OdsCreateDate DATETIME2(7) NOT NULL ,
			OdsSnapshotDate DATETIME2(7) NOT NULL ,
			OdsRowIsCurrent BIT NOT NULL ,
			OdsHashbytesValue VARBINARY(8000) NULL ,
			DmlOperation CHAR(1) NOT NULL ,
			Bill_Payment_Adjustment_ID int NOT NULL,
			BillIDNo INT NULL,
			SeqNo SMALLINT NULL,
			InterestFlags INT NULL,
			DateInterestStarts DATETIME NULL,
			DateInterestEnds DATETIME NULL,
			InterestAdditionalInfoReceived DATETIME NULL,
			Interest MONEY NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Bill_Payment_Adjustments ADD 
        CONSTRAINT PK_Bill_Payment_Adjustments PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Bill_Payment_Adjustment_ID) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Bill_Payment_Adjustments ON src.Bill_Payment_Adjustments REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO
IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.Bill_Payment_Adjustments')
                        AND NAME = 'Comments' )
BEGIN
    ALTER TABLE src.Bill_Payment_Adjustments ADD Comments VARCHAR(1000) NULL 
END
GO


-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Bill_Payment_Adjustments'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Bill_Payment_Adjustments ON src.Bill_Payment_Adjustments REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

IF OBJECT_ID('src.Bill_Pharm_ApportionmentEndnote', 'U') IS NULL
    BEGIN
        CREATE TABLE src.Bill_Pharm_ApportionmentEndnote
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              BillId INT NOT NULL,
              LineNumber SMALLINT NOT NULL,
              Endnote INT NOT NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Bill_Pharm_ApportionmentEndnote ADD 
        CONSTRAINT PK_Bill_Pharm_ApportionmentEndnote PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillId , LineNumber, Endnote) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Bill_Pharm_ApportionmentEndnote ON src.Bill_Pharm_ApportionmentEndnote REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO
IF OBJECT_ID('src.BILL_SENTRY_ENDNOTE', 'U') IS NULL
BEGIN
    CREATE TABLE src.BILL_SENTRY_ENDNOTE
        (
          OdsPostingGroupAuditId INT NOT NULL ,
          OdsCustomerId INT NOT NULL ,
          OdsCreateDate DATETIME2(7) NOT NULL ,
          OdsSnapshotDate DATETIME2(7) NOT NULL ,
          OdsRowIsCurrent BIT NOT NULL ,
          OdsHashbytesValue VARBINARY(8000) NULL,
          DmlOperation CHAR(1) NOT NULL ,
          BillID INT NOT NULL ,
          Line INT NOT NULL ,
          RuleID INT NOT NULL ,
          PercentDiscount REAL NULL ,
          ActionId SMALLINT NULL 
        ) ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (DATA_COMPRESSION = PAGE);

    ALTER TABLE src.BILL_SENTRY_ENDNOTE ADD 
    CONSTRAINT PK_BILL_SENTRY_ENDNOTE PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillID, Line, RuleID) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_BILL_SENTRY_ENDNOTE ON src.BILL_SENTRY_ENDNOTE REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_BILL_SENTRY_ENDNOTE'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_BILL_SENTRY_ENDNOTE ON src.BILL_SENTRY_ENDNOTE REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.BIReportAdjustmentCategory', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.BIReportAdjustmentCategory
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  BIReportAdjustmentCategoryId INT NOT NULL ,
			  Name VARCHAR (50) NULL ,
			  Description VARCHAR (500) NULL ,
			  DisplayPriority INT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.BIReportAdjustmentCategory ADD 
     CONSTRAINT PK_BIReportAdjustmentCategory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BIReportAdjustmentCategoryId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_BIReportAdjustmentCategory ON src.BIReportAdjustmentCategory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.BIReportAdjustmentCategoryMapping', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.BIReportAdjustmentCategoryMapping
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  BIReportAdjustmentCategoryId INT NOT NULL ,
			  Adjustment360SubCategoryId INT NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.BIReportAdjustmentCategoryMapping ADD 
     CONSTRAINT PK_BIReportAdjustmentCategoryMapping PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BIReportAdjustmentCategoryId, Adjustment360SubCategoryId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_BIReportAdjustmentCategoryMapping ON src.BIReportAdjustmentCategoryMapping   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.Bitmasks', 'U') IS NULL
    BEGIN

        CREATE TABLE src.Bitmasks
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              TableProgramUsed VARCHAR(50) NOT NULL ,
              AttributeUsed VARCHAR(50) NOT NULL ,
              Decimal BIGINT NOT NULL ,
              ConstantName VARCHAR(50) NULL ,
              Bit VARCHAR(50) NULL ,
              Hex VARCHAR(20) NULL ,
              Description VARCHAR(250) NULL 
              
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Bitmasks ADD 
        CONSTRAINT PK_Bitmasks PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, TableProgramUsed, AttributeUsed, Decimal) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Bitmasks ON src.Bitmasks REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Bitmasks'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Bitmasks ON src.Bitmasks REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

IF OBJECT_ID('src.CbreToDpEndnoteMapping', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.CbreToDpEndnoteMapping
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  Endnote INT NOT NULL ,
			  EndnoteTypeId TINYINT NOT NULL ,
			  CbreEndnote SMALLINT NOT NULL ,
			  PricingState VARCHAR (2) NOT NULL ,
			  PricingMethodId TINYINT NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.CbreToDpEndnoteMapping ADD 
     CONSTRAINT PK_CbreToDpEndnoteMapping PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Endnote, EndnoteTypeId, CbreEndnote, PricingState, PricingMethodId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_CbreToDpEndnoteMapping ON src.CbreToDpEndnoteMapping   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.CLAIMANT', 'U') IS NULL
    BEGIN
        CREATE TABLE src.CLAIMANT
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL , 
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              CmtIDNo INT NOT NULL ,
              ClaimIDNo INT NULL ,
              CmtSSN VARCHAR(11) NULL ,
              CmtLastName VARCHAR(60) NULL ,
              CmtFirstName VARCHAR(35) NULL ,
              CmtMI VARCHAR(1) NULL ,
              CmtDOB DATETIME NULL ,
              CmtSEX VARCHAR(1) NULL ,
              CmtAddr1 VARCHAR(55) NULL ,
              CmtAddr2 VARCHAR(55) NULL ,
              CmtCity VARCHAR(30) NULL ,
              CmtState VARCHAR(2) NULL ,
              CmtZip VARCHAR(12) NULL ,
              CmtPhone VARCHAR(25) NULL ,
              CmtOccNo VARCHAR(11) NULL ,
              CmtAttorneyNo INT NULL ,
              CmtPolicyLimit MONEY NULL ,
              CmtStateOfJurisdiction VARCHAR(2) NULL ,
              CmtDeductible MONEY NULL ,
              CmtCoPaymentPercentage SMALLINT NULL ,
              CmtCoPaymentMax MONEY NULL ,
              CmtPPO_Eligible SMALLINT NULL ,
              CmtCoordBenefits SMALLINT NULL ,
              CmtFLCopay SMALLINT NULL ,
              CmtCOAExport DATETIME NULL ,
              CmtPGFirstName VARCHAR(30) NULL ,
              CmtPGLastName VARCHAR(30) NULL ,
              CmtDedType SMALLINT NULL ,
              ExportToClaimIQ SMALLINT NULL ,
              CmtInactive SMALLINT NULL ,
              CmtPreCertOption SMALLINT NULL ,
              CmtPreCertState VARCHAR(2) NULL ,
              CreateDate DATETIME NULL ,
              LastChangedOn DATETIME NULL ,
              OdsParticipant BIT NULL ,
              CoverageType VARCHAR(2) NULL ,
              DoNotDisplayCoverageTypeOnEOB BIT NULL ,
			  ShowAllocationsOnEob BIT NULL ,
			  SetPreAllocation BIT NULL,
			  PharmacyEligible TINYINT NULL ,
			  SendCardToClaimant TINYINT NULL,
			  ShareCoPayMaximum BIT NULL

            ) ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (DATA_COMPRESSION = PAGE);

        ALTER TABLE src.CLAIMANT ADD 
        CONSTRAINT PK_CLAIMANT PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, CmtIDNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_CLAIMANT ON src.CLAIMANT REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Add Coveragetype column to src.claimant.
IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.CLAIMANT')
                        AND NAME = 'CoverageType' )
BEGIN
    ALTER TABLE src.CLAIMANT ADD CoverageType VARCHAR(2) NULL
END
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.CLAIMANT')
                        AND NAME = 'DoNotDisplayCoverageTypeOnEOB' )
BEGIN
    ALTER TABLE src.CLAIMANT ADD DoNotDisplayCoverageTypeOnEOB BIT NULL
END
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.CLAIMANT')
                        AND NAME = 'ShowAllocationsOnEob' )
BEGIN
    ALTER TABLE src.CLAIMANT ADD ShowAllocationsOnEob BIT NULL
END
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.CLAIMANT')
                        AND NAME = 'SetPreAllocation' )
BEGIN
    ALTER TABLE src.CLAIMANT ADD SetPreAllocation BIT NULL
END
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.CLAIMANT')
						AND NAME = 'PharmacyEligible' )
	BEGIN
		ALTER TABLE src.CLAIMANT ADD PharmacyEligible TINYINT NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.CLAIMANT')
						AND NAME = 'SendCardToClaimant' )
	BEGIN
		ALTER TABLE src.CLAIMANT ADD SendCardToClaimant TINYINT NULL ;
	END ; 
GO


IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.CLAIMANT')
						AND NAME = 'ShareCoPayMaximum' )
	BEGIN
		ALTER TABLE src.CLAIMANT ADD ShareCoPayMaximum BIT NULL ;
	END ; 
GO


-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_CLAIMANT'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_CLAIMANT ON src.CLAIMANT REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO





IF OBJECT_ID('src.ClaimantManualProviderSummary', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ClaimantManualProviderSummary
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ManualProviderId INT NOT NULL ,
			  DemandClaimantId INT NOT NULL ,
			  FirstDateOfService DATETIME2 (7) NULL ,
			  LastDateOfService DATETIME2 (7) NULL ,
			  Visits INT NULL ,
			  ChargedAmount DECIMAL(19, 4) NULL ,
			  EvaluatedAmount DECIMAL(19, 4) NULL ,
			  MinimumEvaluatedAmount DECIMAL(19, 4) NULL ,
			  MaximumEvaluatedAmount DECIMAL(19, 4) NULL ,
			  Comments VARCHAR (255) NULL 

 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ClaimantManualProviderSummary ADD 
     CONSTRAINT PK_ClaimantManualProviderSummary PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ManualProviderId, DemandClaimantId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ClaimantManualProviderSummary ON src.ClaimantManualProviderSummary   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.ClaimantProviderSummaryEvaluation', 'U') IS NULL
    BEGIN
        CREATE TABLE src.ClaimantProviderSummaryEvaluation
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              ClaimantProviderSummaryEvaluationId INT NOT NULL ,
              ClaimantHeaderId INT NULL ,
              EvaluatedAmount DECIMAL(19, 4) NULL ,
              MinimumEvaluatedAmount DECIMAL(19, 4) NULL ,
              MaximumEvaluatedAmount DECIMAL(19, 4) NULL ,
              Comments VARCHAR(255) NULL
            )
        ON  DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.ClaimantProviderSummaryEvaluation ADD 
        CONSTRAINT PK_ClaimantProviderSummaryEvaluation PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClaimantProviderSummaryEvaluationId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_ClaimantProviderSummaryEvaluation ON src.ClaimantProviderSummaryEvaluation REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END;
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_ClaimantProviderSummaryEvaluation'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_ClaimantProviderSummaryEvaluation ON src.ClaimantProviderSummaryEvaluation REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.Claimant_ClientRef', 'U') IS NULL
    BEGIN
        CREATE TABLE src.Claimant_ClientRef
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              CmtIdNo INT NOT NULL,
              CmtSuffix VARCHAR(50) NULL,
              ClaimIdNo INT NULL,
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Claimant_ClientRef ADD 
        CONSTRAINT PK_Claimant_ClientRef PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, CmtIdNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Claimant_ClientRef ON src.Claimant_ClientRef REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Claimant_ClientRef'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Claimant_ClientRef ON src.Claimant_ClientRef REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.CLAIMS', 'U') IS NULL
    BEGIN
        CREATE TABLE src.CLAIMS
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              ClaimIDNo INT NOT NULL ,
              ClaimNo VARCHAR(MAX) NULL ,
              DateLoss DATETIME NULL ,
              CV_Code VARCHAR(2) NULL ,
              DiaryIndex INT NULL ,
              LastSaved DATETIME NULL ,
              PolicyNumber VARCHAR(50) NULL ,
              PolicyHoldersName VARCHAR(30) NULL ,
              PaidDeductible MONEY NULL ,
              Status VARCHAR(1) NULL ,
              InUse VARCHAR(100) NULL ,
              CompanyID INT NULL ,
              OfficeIndex INT NULL ,
              AdjIdNo INT NULL ,
              PaidCoPay MONEY NULL ,
              AssignedUser VARCHAR(15) NULL ,
              Privatized SMALLINT NULL ,
              PolicyEffDate DATETIME NULL ,
              Deductible MONEY NULL ,
              LossState VARCHAR(2) NULL ,
              AssignedGroup INT NULL ,
              CreateDate DATETIME NULL ,
              LastChangedOn DATETIME NULL ,
              AllowMultiCoverage BIT NULL
            )
        ON  DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.CLAIMS ADD 
        CONSTRAINT PK_CLAIMS PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClaimIDNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_CLAIMS ON src.CLAIMS REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END;
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.CLAIMS')
                        AND NAME = 'AllowMultiCoverage' )
    BEGIN
        ALTER TABLE src.CLAIMS ADD AllowMultiCoverage BIT NULL;
    END;
GO

IF EXISTS ( SELECT  1
                FROM    sys.columns c
				INNER JOIN sys.types t
					ON c.system_type_id = t.system_type_id AND c.user_type_id = t.user_type_id
                WHERE   c.object_id = OBJECT_ID(N'src.CLAIMS')
                    AND c.NAME = 'ClaimNo' 
					AND (t.name <> 'VARCHAR' OR c.max_length <> -1)
						)
    BEGIN
        ALTER TABLE src.CLAIMS ALTER COLUMN ClaimNo VARCHAR(MAX);
    END;
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_CLAIMS'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_CLAIMS ON src.CLAIMS REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.Claims_ClientRef', 'U') IS NULL
BEGIN
    CREATE TABLE src.Claims_ClientRef
        (
		OdsPostingGroupAuditId INT NOT NULL ,
		OdsCustomerId INT NOT NULL ,
		OdsCreateDate DATETIME2(7) NOT NULL ,
		OdsSnapshotDate DATETIME2(7) NOT NULL ,
		OdsRowIsCurrent BIT NOT NULL ,
		OdsHashbytesValue VARBINARY(8000) NULL ,
		DmlOperation CHAR(1) NOT NULL ,
		ClaimIdNo INT NOT NULL,
		ClientRefId VARCHAR(50) NULL
		)ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (
             DATA_COMPRESSION = PAGE);

    ALTER TABLE src.Claims_ClientRef ADD 
    CONSTRAINT PK_Claims_ClientRef PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClaimIdNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_Claims_ClientRef ON src.Claims_ClientRef REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Claims_ClientRef'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Claims_ClientRef ON src.Claims_ClientRef REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.CMS_Zip2Region', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.CMS_Zip2Region
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  StartDate DATETIME NOT NULL ,
			  EndDate DATETIME NULL ,
			  ZIP_Code VARCHAR (5) NOT NULL ,
			  State VARCHAR (2) NULL ,
			  Region VARCHAR (2) NULL ,
			  AmbRegion VARCHAR (2) NULL ,
			  RuralFlag SMALLINT NULL ,
			  ASCRegion SMALLINT NULL ,
			  PlusFour SMALLINT NULL ,
			  CarrierId INT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.CMS_Zip2Region ADD 
     CONSTRAINT PK_CMS_Zip2Region PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, StartDate, ZIP_Code) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_CMS_Zip2Region ON src.CMS_Zip2Region   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.CMT_DX', 'U') IS NULL
    BEGIN
        CREATE TABLE src.CMT_DX
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL , 
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              BillIDNo INT NOT NULL ,
              DX VARCHAR(8) NOT NULL ,
              SeqNum SMALLINT NULL ,
              POA VARCHAR(1) NULL ,
              IcdVersion TINYINT NOT NULL
             
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.CMT_DX ADD 
        CONSTRAINT PK_CMT_DX PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIDNo, DX, IcdVersion) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_CMT_DX ON src.CMT_DX REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_CMT_DX'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_CMT_DX ON src.CMT_DX REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.CMT_HDR', 'U') IS NULL
    BEGIN
        CREATE TABLE src.CMT_HDR
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,    
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              CMT_HDR_IDNo INT NOT NULL ,
              CmtIDNo INT NULL ,
              PvdIDNo INT NULL ,
              LastChangedOn DATETIME NULL 
          
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.CMT_HDR ADD 
        CONSTRAINT PK_CMT_HDR PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, CMT_HDR_IDNo)WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_CMT_HDR ON src.CMT_HDR REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_CMT_HDR'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_CMT_HDR ON src.CMT_HDR REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.CMT_ICD9', 'U') IS NULL
    BEGIN
        CREATE TABLE src.CMT_ICD9
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,  
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              BillIDNo INT NOT NULL ,
              SeqNo SMALLINT NOT NULL ,
              ICD9 VARCHAR(7) NULL ,
              IcdVersion TINYINT NULL 
            
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.CMT_ICD9 ADD 
        CONSTRAINT PK_CMT_ICD9 PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIDNo, SeqNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_CMT_ICD9 ON src.CMT_ICD9 REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_CMT_ICD9'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_CMT_ICD9 ON src.CMT_ICD9 REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
 -- Renaming src.lk_CVTYPE table to src.CoverageType for 10.7 DP Schema changes
 IF OBJECT_ID('src.lkp_CVTYPE', 'U') IS NOT NULL
    BEGIN
	SET XACT_ABORT ON;
	BEGIN TRANSACTION
	-- Create the backup table for src.lk_CVTYPE
	CREATE TABLE src.lkp_CVTYPE_BAK
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL , 
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              LongName VARCHAR(30) NULL ,
              ShortName VARCHAR(2) NOT NULL ,
			  CbreCoverageTypeCode VARCHAR(2) NULL,
			  CoverageTypeCategoryCode VARCHAR(4) NULL,
			  PricingMethodId TINYINT NULL
			  )
	INSERT INTO src.lkp_CVTYPE_BAK SELECT *  FROM  src.lkp_CVTYPE

	-- Rename the existing src.lk_CVTYPE tbale to src.CoverageType including stg table, view & Function.
	EXEC sp_rename 'src.lkp_CVTYPE.PK_lkp_CVTYPE', 'PK_CoverageType', N'INDEX'
	EXEC sp_rename 'src.lkp_CVTYPE', 'CoverageType'
	--Drop Stg, View & functions here , and will be created as a part of install.bat
	IF OBJECT_ID('stg.lkp_CVTYPE', 'U') IS NOT NULL 
	DROP TABLE stg.lkp_CVTYPE 
	
	IF OBJECT_ID('dbo.lkp_CVTYPE', 'V') IS NOT NULL
    DROP VIEW dbo.lkp_CVTYPE;
	
	IF OBJECT_ID('dbo.if_lkp_CVTYPE', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_lkp_CVTYPE;
	
	COMMIT TRANSACTION
	END 
GO


IF OBJECT_ID('src.CoverageType', 'U') IS NULL
    BEGIN
        CREATE TABLE src.CoverageType
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL , 
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              LongName VARCHAR(30) NULL ,
              ShortName VARCHAR(2) NOT NULL ,
			  CbreCoverageTypeCode VARCHAR(2) NULL,
			  CoverageTypeCategoryCode VARCHAR(4) NULL,
			  PricingMethodId TINYINT NULL
             
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.CoverageType ADD 
        CONSTRAINT PK_CoverageType PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ShortName)WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_CoverageType ON src.CoverageType REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.CoverageType')
						AND NAME = 'CbreCoverageTypeCode' )
	BEGIN
		ALTER TABLE src.CoverageType ADD CbreCoverageTypeCode VARCHAR(2) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.CoverageType')
						AND NAME = 'CoverageTypeCategoryCode' )
	BEGIN
		ALTER TABLE src.CoverageType ADD CoverageTypeCategoryCode VARCHAR(4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.CoverageType')
						AND NAME = 'PricingMethodId' )
	BEGIN
		ALTER TABLE src.CoverageType ADD PricingMethodId TINYINT NULL  ;
	END ; 
GO



-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_CoverageType'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_CoverageType ON src.CoverageType REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO





IF OBJECT_ID('src.cpt_DX_DICT', 'U') IS NULL
    BEGIN
        CREATE TABLE src.cpt_DX_DICT
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL , 
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              ICD9 VARCHAR(6) NOT NULL ,
              StartDate DATETIME NOT NULL ,
              EndDate DATETIME NULL ,
              Flags SMALLINT NULL ,
              NonSpecific VARCHAR(1) NULL ,
              AdditionalDigits VARCHAR(1) NULL ,
              Traumatic VARCHAR(1) NULL ,
              DX_DESC VARCHAR(MAX) NULL ,
              Duration SMALLINT NULL ,
              Colossus SMALLINT NULL ,
              DiagnosisFamilyId TINYINT NULL
             
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.cpt_DX_DICT ADD 
        CONSTRAINT PK_cpt_DX_DICT PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ICD9, StartDate) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_cpt_DX_DICT ON src.cpt_DX_DICT REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_cpt_DX_DICT'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_cpt_DX_DICT ON src.cpt_DX_DICT REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.cpt_PRC_DICT', 'U') IS NULL
    BEGIN
        CREATE TABLE src.cpt_PRC_DICT
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,  
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              PRC_CD VARCHAR(7) NOT NULL ,
              StartDate DATETIME NOT NULL ,
              EndDate DATETIME NULL ,
              PRC_DESC VARCHAR(MAX) NULL ,
              Flags INT NULL ,
              Vague VARCHAR(1) NULL ,
              PerVisit SMALLINT NULL ,
              PerClaimant SMALLINT NULL ,
              PerProvider SMALLINT NULL ,
              BodyFlags INT NULL ,
              Colossus SMALLINT NULL ,
              CMS_Status VARCHAR(1) NULL ,
              DrugFlag SMALLINT NULL ,
              CurativeFlag SMALLINT NULL ,
              ExclPolicyLimit SMALLINT NULL ,
              SpecNetFlag SMALLINT NULL 
            
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.cpt_PRC_DICT ADD 
        CONSTRAINT PK_cpt_PRC_DICT PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, PRC_CD, StartDate) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_cpt_PRC_DICT ON src.cpt_PRC_DICT REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_cpt_PRC_DICT'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_cpt_PRC_DICT ON src.cpt_PRC_DICT REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.CreditReason', 'U') IS NULL
BEGIN
	CREATE TABLE src.CreditReason (
		OdsPostingGroupAuditId INT NOT NULL
		,OdsCustomerId INT NOT NULL
		,OdsCreateDate DATETIME2(7) NOT NULL
		,OdsSnapshotDate DATETIME2(7) NOT NULL
		,OdsRowIsCurrent BIT NOT NULL
		,OdsHashbytesValue VARBINARY(8000) NULL
		,DmlOperation CHAR(1) NOT NULL
		,CreditReasonId INT NOT NULL
		,CreditReasonDesc VARCHAR(100) NULL
		,IsVisible BIT NULL 
		) ON DP_Ods_PartitionScheme (OdsCustomerId)
		WITH (DATA_COMPRESSION = PAGE);

	ALTER TABLE src.CreditReason ADD CONSTRAINT PK_CreditReason PRIMARY KEY CLUSTERED (
		OdsPostingGroupAuditId
		,OdsCustomerId
		,CreditReasonId
		)
		WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_CreditReason ON src.CreditReason REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
Go

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_CreditReason'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_CreditReason ON src.CreditReason REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.CreditReasonOverrideENMap', 'U') IS NULL
BEGIN
	CREATE TABLE src.CreditReasonOverrideENMap (
		OdsPostingGroupAuditId INT NOT NULL
		,OdsCustomerId INT NOT NULL
		,OdsCreateDate DATETIME2(7) NOT NULL
		,OdsSnapshotDate DATETIME2(7) NOT NULL
		,OdsRowIsCurrent BIT NOT NULL
		,OdsHashbytesValue VARBINARY(8000) NULL
		,DmlOperation CHAR(1) NOT NULL
		,CreditReasonOverrideENMapId INT NOT NULL
		,CreditReasonId INT NULL
		,OverrideEndnoteId SMALLINT NULL
		) ON DP_Ods_PartitionScheme (OdsCustomerId)
		WITH (DATA_COMPRESSION = PAGE);

	ALTER TABLE src.CreditReasonOverrideENMap ADD CONSTRAINT PK_CreditReasonOverrideENMap PRIMARY KEY CLUSTERED (
		OdsPostingGroupAuditId
		,OdsCustomerId
		,CreditReasonOverrideENMapId
		)
		WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_CreditReasonOverrideENMap ON src.CreditReasonOverrideENMap REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

IF EXISTS ( SELECT  1
            FROM    sys.columns c
                    INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
            WHERE   c.object_id = OBJECT_ID(N'src.CreditReasonOverrideENMap')
                    AND c.name = 'CreditReasonId'
                    AND t.name <> 'int')
    BEGIN
        ALTER TABLE src.CreditReasonOverrideENMap ALTER COLUMN CreditReasonId INT NULL;
    END;
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_CreditReasonOverrideENMap'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_CreditReasonOverrideENMap ON src.CreditReasonOverrideENMap REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.CriticalAccessHospitalInpatientRevenueCode', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.CriticalAccessHospitalInpatientRevenueCode
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  RevenueCode VARCHAR (4) NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.CriticalAccessHospitalInpatientRevenueCode ADD 
     CONSTRAINT PK_CriticalAccessHospitalInpatientRevenueCode PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, RevenueCode) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_CriticalAccessHospitalInpatientRevenueCode ON src.CriticalAccessHospitalInpatientRevenueCode   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.CTG_Endnotes', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.CTG_Endnotes
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  Endnote INT NOT NULL ,
			  ShortDesc VARCHAR (50) NULL ,
			  LongDesc VARCHAR (500) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.CTG_Endnotes ADD 
     CONSTRAINT PK_CTG_Endnotes PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Endnote) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_CTG_Endnotes ON src.CTG_Endnotes   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.CustomBillStatuses', 'U') IS NULL
    BEGIN
        CREATE TABLE src.CustomBillStatuses
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              StatusId INT  NOT NULL,
              StatusName VARCHAR(50) NULL,
              StatusDescription VARCHAR(300) NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.CustomBillStatuses ADD 
        CONSTRAINT PK_CustomBillStatuses PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, StatusId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_CustomBillStatuses ON src.CustomBillStatuses REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_CustomBillStatuses'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_CustomBillStatuses ON src.CustomBillStatuses REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO


IF OBJECT_ID('src.CustomEndnote', 'U') IS NULL
    BEGIN
        CREATE TABLE src.CustomEndnote
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              CustomEndnote INT NOT NULL,
              ShortDescription VARCHAR(50) NULL,
              LongDescription VARCHAR(500) NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.CustomEndnote ADD 
        CONSTRAINT PK_CustomEndnote PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, CustomEndnote) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_CustomEndnote ON src.CustomEndnote REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO


IF OBJECT_ID('src.CustomerBillExclusion', 'U') IS NULL
BEGIN
    CREATE TABLE src.CustomerBillExclusion
        (
            OdsPostingGroupAuditId INT NOT NULL ,
            OdsCustomerId INT NOT NULL ,
            OdsCreateDate DATETIME2(7) NOT NULL ,
			OdsSnapshotDate DATETIME2(7) NOT NULL ,
			OdsRowIsCurrent BIT NOT NULL ,
			OdsHashbytesValue VARBINARY(8000) NULL,
			DmlOperation CHAR(1) NOT NULL ,
            BillIdNo int NOT NULL,
	        Customer nvarchar(50) NOT NULL,
	        ReportID tinyint NOT NULL,
			CreateDate datetime  NULL
        ) ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (DATA_COMPRESSION = PAGE);

    ALTER TABLE src.CustomerBillExclusion ADD 
    CONSTRAINT PK_CustomerBillExclusion PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIdNo,Customer,ReportID) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_CustomerBillExclusion ON src.CustomerBillExclusion REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_CustomerBillExclusion'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_CustomerBillExclusion ON src.CustomerBillExclusion REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

IF OBJECT_ID('src.DeductibleRuleCriteria', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.DeductibleRuleCriteria
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  DeductibleRuleCriteriaId INT NOT NULL ,
			  PricingRuleDateCriteriaId TINYINT NULL ,
			  StartDate DATETIME NULL ,
			  EndDate DATETIME NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.DeductibleRuleCriteria ADD 
     CONSTRAINT PK_DeductibleRuleCriteria PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, DeductibleRuleCriteriaId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_DeductibleRuleCriteria ON src.DeductibleRuleCriteria   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.DeductibleRuleCriteriaCoverageType', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.DeductibleRuleCriteriaCoverageType
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  DeductibleRuleCriteriaId INT NOT NULL ,
			  CoverageType VARCHAR (5) NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.DeductibleRuleCriteriaCoverageType ADD 
     CONSTRAINT PK_DeductibleRuleCriteriaCoverageType PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, DeductibleRuleCriteriaId, CoverageType) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_DeductibleRuleCriteriaCoverageType ON src.DeductibleRuleCriteriaCoverageType   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.DeductibleRuleExemptEndnote', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.DeductibleRuleExemptEndnote
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  Endnote INT NOT NULL ,
			  EndnoteTypeId TINYINT NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.DeductibleRuleExemptEndnote ADD 
     CONSTRAINT PK_DeductibleRuleExemptEndnote PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Endnote, EndnoteTypeId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_DeductibleRuleExemptEndnote ON src.DeductibleRuleExemptEndnote   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO

 IF EXISTS ( SELECT  1
            FROM    sys.columns c
                    INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
            WHERE   c.object_id = OBJECT_ID(N'src.DeductibleRuleExemptEndnote')
                    AND c.name = 'Endnote'
                    AND NOT ( t.name = 'INT'
                            ) )
    BEGIN
		IF EXISTS (
			SELECT 1 FROM sys.tables t
			INNER JOIN sys.indexes i ON i.object_id = t.object_id
			WHERE i.is_primary_key = 1 AND SCHEMA_NAME(t.schema_id) = 'src' AND t.name = 'DeductibleRuleExemptEndnote'
		)
		ALTER TABLE src.DeductibleRuleExemptEndnote DROP CONSTRAINT PK_DeductibleRuleExemptEndnote;

		IF EXISTS (
			SELECT 1 FROM sys.tables t
			INNER JOIN sys.indexes i ON i.object_id = t.object_id
			WHERE SCHEMA_NAME(t.schema_id) = 'src' AND t.name = 'DeductibleRuleExemptEndnote' 
			AND i.name = 'IX_Endnote_EndnoteTypeId_OdsCustomerId_OdsPostingGroupAuditId'
		)
		DROP INDEX IX_Endnote_EndnoteTypeId_OdsCustomerId_OdsPostingGroupAuditId ON src.DeductibleRuleExemptEndnote;

		IF EXISTS (
			SELECT 1 FROM sys.tables t
			INNER JOIN sys.indexes i ON i.object_id = t.object_id
			WHERE SCHEMA_NAME(t.schema_id) = 'src' AND t.name = 'DeductibleRuleExemptEndnote' 
			AND i.name = 'IX_OdsPostingGroupAuditId_DmlOperation'
		)
		DROP INDEX IX_OdsPostingGroupAuditId_DmlOperation ON src.DeductibleRuleExemptEndnote;

		IF EXISTS (
			SELECT 1 FROM sys.tables t
			INNER JOIN sys.indexes i ON i.object_id = t.object_id
			WHERE SCHEMA_NAME(t.schema_id) = 'src' AND t.name = 'DeductibleRuleExemptEndnote' 
			AND i.name = 'IX_OdsCustomerId_OdsRowIsCurrent'
		)
		DROP INDEX IX_OdsCustomerId_OdsRowIsCurrent ON src.DeductibleRuleExemptEndnote;

        ALTER TABLE src.DeductibleRuleExemptEndnote ALTER COLUMN Endnote INT NOT NULL;
    END;
GO

 IF EXISTS ( SELECT  1
            FROM    sys.columns c
                    INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
            WHERE   c.object_id = OBJECT_ID(N'src.DeductibleRuleExemptEndnote')
                    AND c.name = 'EndnoteTypeId'
                    AND NOT ( t.name = 'TINYINT'
                            ) )
    BEGIN
		IF EXISTS (
			SELECT 1 FROM sys.tables t
			INNER JOIN sys.indexes i ON i.object_id = t.object_id
			WHERE i.is_primary_key = 1 AND SCHEMA_NAME(t.schema_id) = 'src' AND t.name = 'DeductibleRuleExemptEndnote'
		)
		ALTER TABLE src.DeductibleRuleExemptEndnote DROP CONSTRAINT PK_DeductibleRuleExemptEndnote;

		IF EXISTS (
			SELECT 1 FROM sys.tables t
			INNER JOIN sys.indexes i ON i.object_id = t.object_id
			WHERE SCHEMA_NAME(t.schema_id) = 'src' AND t.name = 'DeductibleRuleExemptEndnote' 
			AND i.name = 'IX_Endnote_EndnoteTypeId_OdsCustomerId_OdsPostingGroupAuditId'
		)
		DROP INDEX IX_Endnote_EndnoteTypeId_OdsCustomerId_OdsPostingGroupAuditId ON src.DeductibleRuleExemptEndnote;

		IF EXISTS (
			SELECT 1 FROM sys.tables t
			INNER JOIN sys.indexes i ON i.object_id = t.object_id
			WHERE SCHEMA_NAME(t.schema_id) = 'src' AND t.name = 'DeductibleRuleExemptEndnote' 
			AND i.name = 'IX_OdsPostingGroupAuditId_DmlOperation'
		)
		DROP INDEX IX_OdsPostingGroupAuditId_DmlOperation ON src.DeductibleRuleExemptEndnote;

		IF EXISTS (
			SELECT 1 FROM sys.tables t
			INNER JOIN sys.indexes i ON i.object_id = t.object_id
			WHERE SCHEMA_NAME(t.schema_id) = 'src' AND t.name = 'DeductibleRuleExemptEndnote' 
			AND i.name = 'IX_OdsCustomerId_OdsRowIsCurrent'
		)
		DROP INDEX IX_OdsCustomerId_OdsRowIsCurrent ON src.DeductibleRuleExemptEndnote;

        ALTER TABLE src.DeductibleRuleExemptEndnote ALTER COLUMN EndnoteTypeId TINYINT NOT NULL;
    END;
GO

IF NOT EXISTS (
			SELECT 1 FROM sys.tables t
			INNER JOIN sys.indexes i ON i.object_id = t.object_id
			WHERE i.is_primary_key = 1 AND SCHEMA_NAME(t.schema_id) = 'src' AND t.name = 'DeductibleRuleExemptEndnote'
		)
BEGIN
	 ALTER TABLE src.DeductibleRuleExemptEndnote 
	 ADD CONSTRAINT PK_DeductibleRuleExemptEndnote PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Endnote, EndnoteTypeId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_DeductibleRuleExemptEndnote ON src.DeductibleRuleExemptEndnote   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
END
GO
IF OBJECT_ID('src.DemandClaimant', 'U') IS NULL
    BEGIN
        CREATE TABLE src.DemandClaimant
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  DemandClaimantId int NOT NULL,
			  ExternalClaimantId int NULL,
			  OrganizationId nvarchar(100) NULL,
			  HeightInInches smallint NULL,
			  [Weight] smallint NULL,
			  Occupation varchar(50) NULL,
			  BiReportStatus smallint NULL,
			  HasDemandPackage int NULL,
			  FactsOfLoss varchar(250) NULL,
			  PreExistingConditions varchar(100) NULL,
			  Archived bit NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.DemandClaimant ADD 
        CONSTRAINT PK_DemandClaimant PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,DemandClaimantId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_DemandClaimant ON src.DemandClaimant REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_DemandClaimant'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_DemandClaimant ON src.DemandClaimant REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.DemandPackage', 'U') IS NULL
    BEGIN
        CREATE TABLE src.DemandPackage
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  DemandPackageId int NOT NULL,
			  DemandClaimantId int NULL,
			  RequestedByUserName varchar(15) NULL,
			  DateTimeReceived datetimeoffset(7) NULL,
			  CorrelationId varchar(36) NULL,
			  [PageCount] smallint NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.DemandPackage ADD 
        CONSTRAINT PK_DemandPackage PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,DemandPackageId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_DemandPackage ON src.DemandPackage REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_DemandPackage'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_DemandPackage ON src.DemandPackage REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.DemandPackageRequestedService', 'U') IS NULL
    BEGIN
        CREATE TABLE src.DemandPackageRequestedService
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  DemandPackageRequestedServiceId int NOT NULL,
	          DemandPackageId int NULL,
	          ReviewRequestOptions nvarchar(max) NULL
	          
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.DemandPackageRequestedService ADD 
        CONSTRAINT PK_DemandPackageRequestedService PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,DemandPackageRequestedServiceId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_DemandPackageRequestedService ON src.DemandPackageRequestedService REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_DemandPackageRequestedService'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_DemandPackageRequestedService ON src.DemandPackageRequestedService REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

IF OBJECT_ID('src.DemandPackageUploadedFile', 'U') IS NULL
    BEGIN
        CREATE TABLE src.DemandPackageUploadedFile
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  DemandPackageUploadedFileId int NOT NULL,
	          DemandPackageId int NULL,
	          [FileName] varchar(255) NULL,
	          Size int NULL,
	          DocStoreId varchar(50) NULL
	          
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.DemandPackageUploadedFile ADD 
        CONSTRAINT PK_DemandPackageUploadedFile PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,DemandPackageUploadedFileId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_DemandPackageUploadedFile ON src.DemandPackageUploadedFile REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_DemandPackageUploadedFile'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_DemandPackageUploadedFile ON src.DemandPackageUploadedFile REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

IF OBJECT_ID('src.DiagnosisCodeGroup', 'U') IS NULL
    BEGIN

        CREATE TABLE src.DiagnosisCodeGroup
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,  
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              DiagnosisCode VARCHAR(8) NOT NULL ,
              StartDate DATETIME NOT NULL ,
              EndDate DATETIME NULL ,
              MajorCategory VARCHAR(500) NULL ,
              MinorCategory VARCHAR(500) NULL 
            
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.DiagnosisCodeGroup ADD 
        CONSTRAINT PK_DiagnosisCodeGroup PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, DiagnosisCode, StartDate) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_DiagnosisCodeGroup ON src.DiagnosisCodeGroup REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_DiagnosisCodeGroup'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_DiagnosisCodeGroup ON src.DiagnosisCodeGroup REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.EncounterType', 'U') IS NULL
    BEGIN
        CREATE TABLE src.EncounterType
            (
			 OdsPostingGroupAuditId INT NOT NULL ,
			 OdsCustomerId INT NOT NULL ,              
			 OdsCreateDate DATETIME2(7) NOT NULL ,
			 OdsSnapshotDate DATETIME2(7) NOT NULL ,
			 OdsRowIsCurrent BIT NOT NULL ,
			 OdsHashbytesValue VARBINARY(8000) NULL ,
			 DmlOperation CHAR(1) NOT NULL ,
			 EncounterTypeId TINYINT NOT NULL,
	         EncounterTypePriority TINYINT NULL,
	         [Description] VARCHAR(100) NULL,
	         NarrativeInformation VARCHAR(max) NULL
           )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.EncounterType ADD 
        CONSTRAINT PK_EncounterType PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, EncounterTypeId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_EncounterType ON src.EncounterType REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_EncounterType'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_EncounterType ON src.EncounterType REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO



IF OBJECT_ID('src.EndnoteSubCategory', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.EndnoteSubCategory
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  EndnoteSubCategoryId TINYINT NOT NULL ,
			  Description VARCHAR (50) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.EndnoteSubCategory ADD 
     CONSTRAINT PK_EndnoteSubCategory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, EndnoteSubCategoryId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_EndnoteSubCategory ON src.EndnoteSubCategory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.Esp_Ppo_Billing_Data_Self_Bill', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Esp_Ppo_Billing_Data_Self_Bill
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  COMPANYCODE VARCHAR (10) NULL ,
			  TRANSACTIONTYPE VARCHAR (10) NULL ,
			  BILL_HDR_AMTALLOWED NUMERIC (15,2) NULL ,
			  BILL_HDR_AMTCHARGED NUMERIC (15,2) NULL ,
			  BILL_HDR_BILLIDNO INT NULL ,
			  BILL_HDR_CMT_HDR_IDNO INT NULL ,
			  BILL_HDR_CREATEDATE DATETIME NULL ,
			  BILL_HDR_CV_TYPE VARCHAR (5) NULL ,
			  BILL_HDR_FORM_TYPE VARCHAR (8) NULL ,
			  BILL_HDR_NOLINES INT NULL ,
			  BILLS_ALLOWED NUMERIC (15,2) NULL ,
			  BILLS_ANALYZED NUMERIC (15,2) NULL ,
			  BILLS_CHARGED NUMERIC (15,2) NULL ,
			  BILLS_DT_SVC DATETIME NULL ,
			  BILLS_LINE_NO INT NULL ,
			  CLAIMANT_CLIENTREF_CMTSUFFIX VARCHAR (50) NULL ,
			  CLAIMANT_CMTFIRST_NAME VARCHAR (50) NULL ,
			  CLAIMANT_CMTIDNO VARCHAR (20) NULL ,
			  CLAIMANT_CMTLASTNAME VARCHAR (60) NULL ,
			  CMTSTATEOFJURISDICTION VARCHAR (2) NULL ,
			  CLAIMS_COMPANYID INT NULL ,
			  CLAIMS_CLAIMNO VARCHAR (50) NULL ,
			  CLAIMS_DATELOSS DATETIME NULL ,
			  CLAIMS_OFFICEINDEX INT NULL ,
			  CLAIMS_POLICYHOLDERSNAME VARCHAR (100) NULL ,
			  CLAIMS_POLICYNUMBER VARCHAR (50) NULL ,
			  PNETWKEVENTLOG_EVENTID INT NULL ,
			  PNETWKEVENTLOG_LOGDATE DATETIME NULL ,
			  PNETWKEVENTLOG_NETWORKID INT NULL ,
			  ACTIVITY_FLAG VARCHAR (1) NULL ,
			  PPO_AMTALLOWED NUMERIC (15,2) NULL ,
			  PREPPO_AMTALLOWED NUMERIC (15,2) NULL ,
			  PREPPO_ALLOWED_FS VARCHAR (1) NULL ,
			  PRF_COMPANY_COMPANYNAME VARCHAR (50) NULL ,
			  PRF_OFFICE_OFCNAME VARCHAR (50) NULL ,
			  PRF_OFFICE_OFCNO VARCHAR (25) NULL ,
			  PROVIDER_PVDFIRSTNAME VARCHAR (60) NULL ,
			  PROVIDER_PVDGROUP VARCHAR (60) NULL ,
			  PROVIDER_PVDLASTNAME VARCHAR (60) NULL ,
			  PROVIDER_PVDTIN VARCHAR (15) NULL ,
			  PROVIDER_STATE VARCHAR (5) NULL ,
			  UDFCLAIM_UDFVALUETEXT VARCHAR (255) NULL ,
			  ENTRY_DATE DATETIME NULL ,
			  UDFCLAIMANT_UDFVALUETEXT VARCHAR (255) NULL ,
			  SOURCE_DB VARCHAR (20) NULL ,
			  CLAIMS_CV_CODE VARCHAR (5) NULL ,
			  VPN_TRANSACTIONID BIGINT NOT NULL ,
			  VPN_TRANSACTIONTYPEID INT NULL ,
			  VPN_BILLIDNO INT NULL ,
			  VPN_LINE_NO SMALLINT NULL ,
			  VPN_CHARGED MONEY NULL ,
			  VPN_DPALLOWED MONEY NULL ,
			  VPN_VPNALLOWED MONEY NULL ,
			  VPN_SAVINGS MONEY NULL ,
			  VPN_CREDITS MONEY NULL ,
			  VPN_HASOVERRIDE BIT NULL ,
			  VPN_ENDNOTES NVARCHAR (200) NULL ,
			  VPN_NETWORKIDNO INT NULL ,
			  VPN_PROCESSFLAG SMALLINT NULL ,
			  VPN_LINETYPE INT NULL ,
			  VPN_DATETIMESTAMP DATETIME NULL ,
			  VPN_SEQNO INT NULL ,
			  VPN_VPN_REF_LINE_NO SMALLINT NULL ,
			  VPN_NETWORKNAME VARCHAR (50) NULL ,
			  VPN_SOJ VARCHAR (2) NULL ,
			  VPN_CAT3 INT NULL ,
			  VPN_PPODATESTAMP DATETIME NULL ,
			  VPN_NINTEYDAYS INT NULL ,
			  VPN_BILL_TYPE CHAR (1) NULL ,
			  VPN_NET_SAVINGS MONEY NULL ,
			  CREDIT BIT NULL ,
			  RECON BIT NULL ,
			  DELETED BIT NULL ,
			  STATUS_FLAG VARCHAR (2) NULL ,
			  DATE_SAVED DATETIME NULL ,
			  SUB_NETWORK VARCHAR (50) NULL ,
			  INVALID_CREDIT BIT NULL ,
			  PROVIDER_SPECIALTY VARCHAR (50) NULL ,
			  ADJUSTOR_IDNUMBER VARCHAR (25) NULL ,
			  ACP_FLAG VARCHAR (1) NULL ,
			  OVERRIDE_ENDNOTES VARCHAR (MAX) NULL ,
			  OVERRIDE_ENDNOTES_DESC VARCHAR (MAX) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Esp_Ppo_Billing_Data_Self_Bill ADD 
     CONSTRAINT PK_Esp_Ppo_Billing_Data_Self_Bill PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, VPN_TRANSACTIONID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Esp_Ppo_Billing_Data_Self_Bill ON src.Esp_Ppo_Billing_Data_Self_Bill   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.EvaluationSummary', 'U') IS NULL
BEGIN
    CREATE TABLE src.EvaluationSummary
    (
        OdsPostingGroupAuditId INT NOT NULL,
        OdsCustomerId INT NOT NULL,
        OdsCreateDate DATETIME2(7) NOT NULL,
        OdsSnapshotDate DATETIME2(7) NOT NULL,
        OdsRowIsCurrent BIT NOT NULL,
        OdsHashbytesValue VARBINARY(8000) NULL,
        DmlOperation CHAR(1) NOT NULL,
        DemandClaimantId INT NOT NULL,
        Details NVARCHAR(MAX) NULL,
        CreatedBy NVARCHAR(50) NULL,
        CreatedDate DATETIMEOFFSET(7) NULL,
        ModifiedBy NVARCHAR(50) NULL,
        ModifiedDate DATETIMEOFFSET(7) NULL
    ) ON DP_Ods_PartitionScheme (OdsCustomerId)
    WITH (DATA_COMPRESSION = PAGE);

    ALTER TABLE src.EvaluationSummary
    ADD CONSTRAINT PK_EvaluationSummary
        PRIMARY KEY CLUSTERED (
                                  OdsPostingGroupAuditId,
                                  OdsCustomerId,
                                  DemandClaimantId
                              )
        WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

    ALTER INDEX PK_EvaluationSummary
    ON src.EvaluationSummary
    REBUILD
    WITH (STATISTICS_INCREMENTAL = ON);
END;

GO
IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.EvaluationSummary')
						AND NAME = 'EvaluationSummaryTemplateVersionId' )
	BEGIN
		ALTER TABLE src.EvaluationSummary ADD EvaluationSummaryTemplateVersionId INT NULL ;
	END ; 
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1 
                FROM sys.stats
                WHERE name = 'PK_EvaluationSummary' 
                AND is_incremental = 1)  
BEGIN
ALTER INDEX PK_EvaluationSummary ON src.EvaluationSummary   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 

END ;
GO




IF OBJECT_ID('src.EvaluationSummaryHistory', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.EvaluationSummaryHistory
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  EvaluationSummaryHistoryId INT NOT NULL ,
			  DemandClaimantId INT NULL ,
			  EvaluationSummary NVARCHAR (MAX) NULL ,
			  CreatedBy NVARCHAR (50) NULL ,
			  CreatedDate DATETIMEOFFSET NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.EvaluationSummaryHistory ADD 
     CONSTRAINT PK_EvaluationSummaryHistory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, EvaluationSummaryHistoryId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_EvaluationSummaryHistory ON src.EvaluationSummaryHistory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.EvaluationSummaryTemplateVersion', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.EvaluationSummaryTemplateVersion
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  EvaluationSummaryTemplateVersionId INT NOT NULL ,
			  Template NVARCHAR (MAX) NULL ,
			  TemplateHash VARBINARY(32) NULL ,
			  CreatedDate DATETIMEOFFSET NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.EvaluationSummaryTemplateVersion ADD 
     CONSTRAINT PK_EvaluationSummaryTemplateVersion PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, EvaluationSummaryTemplateVersionId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_EvaluationSummaryTemplateVersion ON src.EvaluationSummaryTemplateVersion   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.EventLog', 'U') IS NULL
    BEGIN
        CREATE TABLE src.EventLog
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  EventLogId int NOT NULL,
	          ObjectName varchar(50) NULL,
	          ObjectId int NULL,
	          UserName varchar(15) NULL,
	          LogDate datetimeoffset(7) NULL,
	          ActionName varchar(20) NULL,
	          OrganizationId nvarchar(100) NULL
	          
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.EventLog ADD 
        CONSTRAINT PK_EventLog PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,EventLogId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_EventLog ON src.EventLog REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_EventLog'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_EventLog ON src.EventLog REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.EventLogDetail', 'U') IS NULL
    BEGIN
        CREATE TABLE src.EventLogDetail
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  EventLogDetailId int NOT NULL,
	          EventLogId int NULL,
	          PropertyName varchar(50) NULL,
	          OldValue varchar(max) NULL,
	          NewValue varchar(max) NULL
	          
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.EventLogDetail ADD 
        CONSTRAINT PK_EventLogDetail PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,EventLogDetailId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_EventLogDetail ON src.EventLogDetail REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_EventLogDetail'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_EventLogDetail ON src.EventLogDetail REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.ExtractCat', 'U') IS NULL
    BEGIN
        CREATE TABLE src.ExtractCat
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              CatIdNo INT NOT NULL ,
			  Description VARCHAR(50) NULL ,					  
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.ExtractCat ADD 
        CONSTRAINT PK_ExtractCat PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, CatIdNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_ExtractCat ON src.ExtractCat REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO
IF OBJECT_ID('src.GeneralInterestRuleBaseType', 'U') IS NULL
BEGIN
    CREATE TABLE src.GeneralInterestRuleBaseType
    (
        OdsPostingGroupAuditId INT NOT NULL,
        OdsCustomerId INT NOT NULL,
        OdsCreateDate DATETIME2(7) NOT NULL,
        OdsSnapshotDate DATETIME2(7) NOT NULL,
        OdsRowIsCurrent BIT NOT NULL,
        OdsHashbytesValue VARBINARY(8000) NULL,
        DmlOperation CHAR(1) NOT NULL,
        GeneralInterestRuleBaseTypeId TINYINT NOT NULL,
        GeneralInterestRuleBaseTypeName VARCHAR(50) NULL
    ) ON DP_Ods_PartitionScheme (OdsCustomerId)
    WITH (DATA_COMPRESSION = PAGE);

    ALTER TABLE src.GeneralInterestRuleBaseType
    ADD CONSTRAINT PK_GeneralInterestRuleBaseType
        PRIMARY KEY CLUSTERED (
                                  OdsPostingGroupAuditId,
                                  OdsCustomerId,
                                  GeneralInterestRuleBaseTypeId
                              )
        WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

    ALTER INDEX PK_GeneralInterestRuleBaseType
    ON src.GeneralInterestRuleBaseType
    REBUILD
    WITH (STATISTICS_INCREMENTAL = ON);
END;

GO
IF OBJECT_ID('src.GeneralInterestRuleSetting', 'U') IS NULL
    BEGIN
        CREATE TABLE src.GeneralInterestRuleSetting
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              GeneralInterestRuleBaseTypeId TINYINT NOT NULL               
            )
        ON  DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.GeneralInterestRuleSetting ADD 
        CONSTRAINT PK_GeneralInterestRuleSetting PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, GeneralInterestRuleBaseTypeId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);
		
		ALTER INDEX PK_GeneralInterestRuleSetting ON src.GeneralInterestRuleSetting REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END;
GO
IF OBJECT_ID('src.Icd10DiagnosisVersion', 'U') IS NULL
    BEGIN
        CREATE TABLE src.Icd10DiagnosisVersion
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,              
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              DiagnosisCode VARCHAR(8) NOT NULL ,
              StartDate DATETIME NOT NULL ,
              EndDate DATETIME NULL ,
              NonSpecific BIT NULL ,
              Traumatic BIT NULL ,
              Duration SMALLINT NULL ,
              Description VARCHAR(MAX) NULL ,
              DiagnosisFamilyId TINYINT NULL ,
			  TotalCharactersRequired TINYINT NULL ,
			  PlaceholderRequired BIT NULL 

            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Icd10DiagnosisVersion ADD 
        CONSTRAINT PK_Icd10DiagnosisVersion PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, DiagnosisCode, StartDate) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Icd10DiagnosisVersion ON src.Icd10DiagnosisVersion REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Icd10DiagnosisVersion'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Icd10DiagnosisVersion ON src.Icd10DiagnosisVersion REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Icd10DiagnosisVersion')
						AND NAME = 'TotalCharactersRequired' )
	BEGIN
		ALTER TABLE src.Icd10DiagnosisVersion ADD TotalCharactersRequired TINYINT NULL ;
	END 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Icd10DiagnosisVersion')
						AND NAME = 'PlaceholderRequired' )
	BEGIN
		ALTER TABLE src.Icd10DiagnosisVersion ADD PlaceholderRequired BIT NULL ;
	END 
GO
IF OBJECT_ID('src.ICD10ProcedureCode', 'U') IS NULL
    BEGIN
        CREATE TABLE src.ICD10ProcedureCode
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              ICDProcedureCode VARCHAR(7) NOT NULL ,
              StartDate DATETIME NOT NULL ,
              EndDate DATETIME NULL ,
              Description VARCHAR(300) NULL ,
              PASGrpNo SMALLINT NULL 
              
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.ICD10ProcedureCode ADD 
        CONSTRAINT PK_ICD10ProcedureCode PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ICDProcedureCode, StartDate) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_ICD10ProcedureCode ON src.ICD10ProcedureCode REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_ICD10ProcedureCode'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_ICD10ProcedureCode ON src.ICD10ProcedureCode REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.IcdDiagnosisCodeDictionary', 'U') IS NULL
    BEGIN
        CREATE TABLE src.IcdDiagnosisCodeDictionary
            (
			 OdsPostingGroupAuditId INT NOT NULL ,
			 OdsCustomerId INT NOT NULL ,              
			 OdsCreateDate DATETIME2(7) NOT NULL ,
			 OdsSnapshotDate DATETIME2(7) NOT NULL ,
			 OdsRowIsCurrent BIT NOT NULL ,
			 OdsHashbytesValue VARBINARY(8000) NULL ,
			 DmlOperation CHAR(1) NOT NULL ,
			 DiagnosisCode VARCHAR(8) NOT NULL,
			 IcdVersion TINYINT NOT NULL,
			 StartDate DATETIME2(7) NOT NULL,
			 EndDate DATETIME2(7) NULL,
			 NonSpecific BIT NULL,
			 Traumatic BIT NULL,
			 Duration TINYINT NULL,
			 [Description] VARCHAR(max) NULL,
			 DiagnosisFamilyId TINYINT NULL,
			 DiagnosisSeverityId TINYINT NULL,
			 LateralityId TINYINT NULL,
			 TotalCharactersRequired TINYINT NULL,
			 PlaceholderRequired BIT NULL,
			 Flags SMALLINT NULL,
			 AdditionalDigits BIT NULL,
			 Colossus SMALLINT NULL,
			 InjuryNatureId TINYINT NULL,
			 EncounterSubcategoryId TINYINT NULL
           )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.IcdDiagnosisCodeDictionary ADD 
        CONSTRAINT PK_IcdDiagnosisCodeDictionary PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, DiagnosisCode, IcdVersion, StartDate) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_IcdDiagnosisCodeDictionary ON src.IcdDiagnosisCodeDictionary REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.IcdDiagnosisCodeDictionary')
                        AND NAME = 'EncounterSubcategoryId' )
BEGIN
    ALTER TABLE src.IcdDiagnosisCodeDictionary ADD EncounterSubcategoryId TINYINT NULL
END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_IcdDiagnosisCodeDictionary'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_IcdDiagnosisCodeDictionary ON src.IcdDiagnosisCodeDictionary REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO




IF OBJECT_ID('src.IcdDiagnosisCodeDictionaryBodyPart', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.IcdDiagnosisCodeDictionaryBodyPart
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  DiagnosisCode VARCHAR (8) NOT NULL ,
			  IcdVersion TINYINT NOT NULL ,
			  StartDate DATETIME2 (7) NOT NULL ,
			  NcciBodyPartId TINYINT NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.IcdDiagnosisCodeDictionaryBodyPart ADD 
     CONSTRAINT PK_IcdDiagnosisCodeDictionaryBodyPart PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, DiagnosisCode, IcdVersion, StartDate, NcciBodyPartId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_IcdDiagnosisCodeDictionaryBodyPart ON src.IcdDiagnosisCodeDictionaryBodyPart   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.InjuryNature', 'U') IS NULL
    BEGIN
        CREATE TABLE src.InjuryNature
            (
			 OdsPostingGroupAuditId INT NOT NULL ,
			 OdsCustomerId INT NOT NULL ,              
			 OdsCreateDate DATETIME2(7) NOT NULL ,
			 OdsSnapshotDate DATETIME2(7) NOT NULL ,
			 OdsRowIsCurrent BIT NOT NULL ,
			 OdsHashbytesValue VARBINARY(8000) NULL ,
			 DmlOperation CHAR(1) NOT NULL ,
			 InjuryNatureId TINYINT NOT NULL,
	         InjuryNaturePriority TINYINT NULL,
	         [Description] VARCHAR(100) NULL,
	         NarrativeInformation VARCHAR(max) NULL
           )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.InjuryNature ADD 
        CONSTRAINT PK_InjuryNature PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, InjuryNatureId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_InjuryNature ON src.InjuryNature REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_InjuryNature'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_InjuryNature ON src.InjuryNature REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO



IF OBJECT_ID('src.lkp_SPC', 'U') IS NULL
    BEGIN
        CREATE TABLE src.lkp_SPC
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              lkp_SpcId INT NOT NULL ,
              LongName VARCHAR(50) NULL ,
              ShortName VARCHAR(4) NULL ,
              Mult MONEY NULL ,
              NCD92 SMALLINT NULL ,
              NCD93 SMALLINT NULL ,
              PlusFour SMALLINT NULL 
              
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.lkp_SPC ADD 
        CONSTRAINT PK_lkp_SPC PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, lkp_SpcId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_lkp_SPC ON src.lkp_SPC REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- The following fields became nullable in v1.1
IF EXISTS ( SELECT  1
            FROM    sys.columns
            WHERE   object_id = OBJECT_ID('src.lkp_SPC')
                    AND name = 'LongName'
                    AND is_nullable = 0 )
    ALTER TABLE src.lkp_SPC ALTER COLUMN Longname VARCHAR(50) NULL;
GO

IF EXISTS ( SELECT  1
            FROM    sys.columns
            WHERE   object_id = OBJECT_ID('src.lkp_SPC')
                    AND name = 'ShortName'
                    AND is_nullable = 0 )
    ALTER TABLE src.lkp_SPC ALTER COLUMN ShortName VARCHAR(4) NULL;
GO

IF EXISTS ( SELECT  1
            FROM    sys.columns
            WHERE   object_id = OBJECT_ID('src.lkp_SPC')
                    AND name = 'Mult'
                    AND is_nullable = 0 )
    ALTER TABLE src.lkp_SPC ALTER COLUMN Mult MONEY NULL;
GO

IF EXISTS ( SELECT  1
            FROM    sys.columns
            WHERE   object_id = OBJECT_ID('src.lkp_SPC')
                    AND name = 'NCD92'
                    AND is_nullable = 0 )
    ALTER TABLE src.lkp_SPC ALTER COLUMN NCD92 SMALLINT NULL;
GO

IF EXISTS ( SELECT  1
            FROM    sys.columns
            WHERE   object_id = OBJECT_ID('src.lkp_SPC')
                    AND name = 'NCD93'
                    AND is_nullable = 0 )
    ALTER TABLE src.lkp_SPC ALTER COLUMN NCD93 SMALLINT NULL;
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.lkp_SPC')
						AND NAME = 'CbreSpecialtyCode' )
	BEGIN
		ALTER TABLE src.lkp_SPC ADD CbreSpecialtyCode VARCHAR(12) NULL ;
	END ; 
GO


-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_lkp_SPC'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_lkp_SPC ON src.lkp_SPC REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

IF OBJECT_ID('src.lkp_TS', 'U') IS NULL
    BEGIN
        CREATE TABLE src.lkp_TS
            (
			OdsPostingGroupAuditId INT NOT NULL ,
			OdsCustomerId INT NOT NULL ,
			OdsCreateDate DATETIME2(7) NOT NULL ,
			OdsSnapshotDate DATETIME2(7) NOT NULL ,
			OdsRowIsCurrent BIT NOT NULL ,
			OdsHashbytesValue VARBINARY(8000) NULL ,
			DmlOperation CHAR(1) NOT NULL ,
			ShortName VARCHAR(2) NOT NULL,
			StartDate  DATETIME2(7) NOT NULL,
			EndDate  DATETIME2(7) NULL,
			LongName VARCHAR(100) NULL,
			Global SMALLINT NULL,
			AnesMedDirect SMALLINT NULL,
			AffectsPricing SMALLINT NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.lkp_TS ADD 
        CONSTRAINT PK_lkp_TS PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ShortName, StartDate) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_lkp_TS ON src.lkp_TS REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.lkp_TS')
						AND NAME = 'IsAssistantSurgery' )
	BEGIN
		ALTER TABLE src.lkp_TS ADD IsAssistantSurgery BIT NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.lkp_TS')
						AND NAME = 'IsCoSurgeon' )
	BEGIN
		ALTER TABLE src.lkp_TS ADD IsCoSurgeon BIT NULL ;
	END ; 
GO

 
IF  EXISTS ( SELECT  1
			FROM    sys.columns c 
					INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
			WHERE   object_id = OBJECT_ID(N'src.lkp_TS')
					AND c.name = 'StartDate' 
					AND NOT ( t.name = 'DATETIME2' 
						 AND c.max_length = '7'
						   ) ) 
	--Drop PK key and Index and Alter the Column and Add the PK and Index Back
	BEGIN
		ALTER TABLE src.lkp_TS DROP CONSTRAINT PK_lkp_TS;
		DROP INDEX IF EXISTS PK_lkp_TS ON src.lkp_TS;
		DROP INDEX IF EXISTS IX_ShortName_StartDate_OdsCustomerId_OdsPostingGroupAuditId ON src.lkp_TS;
		DROP INDEX IF EXISTS IX_OdsPostingGroupAuditId_DmlOperation ON src.lkp_TS;
		DROP INDEX IF EXISTS IX_OdsCustomerId_OdsRowIsCurrent ON src.lkp_TS;

		ALTER TABLE src.lkp_TS ALTER COLUMN StartDate DATETIME2(7) NOT NULL ;
		ALTER TABLE src.lkp_TS ADD 
		CONSTRAINT PK_lkp_TS PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ShortName, StartDate) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);
	END ; 
GO		

IF  EXISTS ( SELECT  1
			FROM    sys.columns c 
					INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
			WHERE   object_id = OBJECT_ID(N'src.lkp_TS')
					AND c.name = 'EndDate' 
					AND NOT ( t.name = 'DATETIME2' 
						 AND c.max_length = '7'
						   ) ) 
	BEGIN
		ALTER TABLE src.lkp_TS ALTER COLUMN EndDate DATETIME2(7) NULL ;
	END ; 
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_lkp_TS'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_lkp_TS ON src.lkp_TS REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO



IF OBJECT_ID('src.ManualProvider', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ManualProvider
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ManualProviderId INT NOT NULL ,
			  TIN VARCHAR (15) NULL ,
			  LastName VARCHAR (60) NULL ,
			  FirstName VARCHAR (35) NULL ,
			  GroupName VARCHAR (60) NULL ,
			  Address1 VARCHAR (55) NULL ,
			  Address2 VARCHAR (55) NULL ,
			  City VARCHAR (30) NULL ,
			  State VARCHAR (2) NULL ,
			  Zip VARCHAR (12) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ManualProvider ADD 
     CONSTRAINT PK_ManualProvider PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ManualProviderId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ManualProvider ON src.ManualProvider   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.ManualProviderSpecialty', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ManualProviderSpecialty
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ManualProviderId INT NOT NULL ,
			  Specialty VARCHAR (12) NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ManualProviderSpecialty ADD 
     CONSTRAINT PK_ManualProviderSpecialty PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ManualProviderId, Specialty) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ManualProviderSpecialty ON src.ManualProviderSpecialty   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.MedicalCodeCutOffs', 'U') IS NULL
    BEGIN
        CREATE TABLE src.MedicalCodeCutOffs
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              CodeTypeID INT NOT NULL,
              CodeType VARCHAR(50) NULL,
              Code VARCHAR(50) NOT NULL,
              FormType VARCHAR(10) NOT NULL,
              MaxChargedPerUnit FLOAT NULL,
              MaxUnitsPerEncounter FLOAT NULL          

            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.MedicalCodeCutOffs ADD 
        CONSTRAINT PK_MedicalCodeCutOffs PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, CodeTypeID, Code, FormType) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_MedicalCodeCutOffs ON src.MedicalCodeCutOffs REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_MedicalCodeCutOffs'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_MedicalCodeCutOffs ON src.MedicalCodeCutOffs REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

IF OBJECT_ID('src.MedicareStatusIndicatorRule', 'U') IS NULL
    BEGIN
        CREATE TABLE src.MedicareStatusIndicatorRule
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              MedicareStatusIndicatorRuleId INT NOT NULL ,
              MedicareStatusIndicatorRuleName VARCHAR(50) NULL ,
              StatusIndicator VARCHAR(500) NULL ,
			  StartDate DATETIME2(7) NULL,
			  EndDate DATETIME2(7) NULL,
			  Endnote INT NULL,
	          EditActionId TINYINT NULL,
	          Comments VARCHAR(1000) NULL,
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.MedicareStatusIndicatorRule ADD 
        CONSTRAINT PK_MedicareStatusIndicatorRule PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, MedicareStatusIndicatorRuleId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_MedicareStatusIndicatorRule ON src.MedicareStatusIndicatorRule REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO



IF OBJECT_ID('src.MedicareStatusIndicatorRuleCoverageType', 'U') IS NULL
BEGIN
	CREATE TABLE src.MedicareStatusIndicatorRuleCoverageType (
		OdsPostingGroupAuditId INT NOT NULL,
		OdsCustomerId INT NOT NULL,
		OdsCreateDate DATETIME2(7) NOT NULL,
		OdsSnapshotDate DATETIME2(7) NOT NULL,
		OdsRowIsCurrent BIT NOT NULL,
		OdsHashbytesValue VARBINARY(8000) NULL,
		DmlOperation CHAR(1) NOT NULL,
		MedicareStatusIndicatorRuleId INT NOT NULL,
		ShortName VARCHAR(2) NOT NULL
		) ON DP_Ods_PartitionScheme (OdsCustomerId)
		WITH (DATA_COMPRESSION = PAGE);

	ALTER TABLE src.MedicareStatusIndicatorRuleCoverageType ADD CONSTRAINT PK_MedicareStatusIndicatorRuleCoverageType PRIMARY KEY CLUSTERED (
		OdsPostingGroupAuditId,
		OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		ShortName
		)
		WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_MedicareStatusIndicatorRuleCoverageType ON src.MedicareStatusIndicatorRuleCoverageType REBUILD
		WITH (STATISTICS_INCREMENTAL = ON);
END
ELSE -- We should do below things only when object is not null
BEGIN
	-- If ShortName is nullable, make it not nullable
	IF COLUMNPROPERTY(OBJECT_ID('src.MedicareStatusIndicatorRuleCoverageType', 'U'), 'ShortName', 'AllowsNull') = 1
	BEGIN
		ALTER TABLE src.MedicareStatusIndicatorRuleCoverageType
		ALTER COLUMN ShortName VARCHAR(2) NOT NULL;
	END;

	SET XACT_ABORT ON;

	-- If the PK exists, but is missing our new column, drop and recreate it
	IF OBJECT_ID('src.PK_MedicareStatusIndicatorRuleCoverageType', 'PK') IS NOT NULL
		AND NOT EXISTS (
			SELECT 1
			FROM sys.indexes i
			INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id
				AND i.index_id = ic.index_id
			INNER JOIN sys.columns c ON ic.object_id = c.object_id
				AND ic.column_id = c.column_id
			INNER JOIN sys.objects o ON i.object_id = o.object_id
			WHERE i.is_primary_key = 1
				AND o.object_id = OBJECT_ID('src.MedicareStatusIndicatorRuleCoverageType')
				AND c.name = 'ShortName'
			)
	BEGIN
		BEGIN TRANSACTION;

		ALTER TABLE src.MedicareStatusIndicatorRuleCoverageType
		DROP CONSTRAINT PK_MedicareStatusIndicatorRuleCoverageType;

		ALTER TABLE src.MedicareStatusIndicatorRuleCoverageType ADD CONSTRAINT PK_MedicareStatusIndicatorRuleCoverageType PRIMARY KEY CLUSTERED (
			OdsPostingGroupAuditId,
			OdsCustomerId,
			MedicareStatusIndicatorRuleId,
			ShortName
			)
			WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_MedicareStatusIndicatorRuleCoverageType ON src.MedicareStatusIndicatorRuleCoverageType REBUILD
			WITH (STATISTICS_INCREMENTAL = ON);

		COMMIT TRANSACTION;
	END;
END
GO


IF OBJECT_ID('src.MedicareStatusIndicatorRulePlaceOfService', 'U') IS NULL
BEGIN
	CREATE TABLE src.MedicareStatusIndicatorRulePlaceOfService (
		OdsPostingGroupAuditId INT NOT NULL,
		OdsCustomerId INT NOT NULL,
		OdsCreateDate DATETIME2(7) NOT NULL,
		OdsSnapshotDate DATETIME2(7) NOT NULL,
		OdsRowIsCurrent BIT NOT NULL,
		OdsHashbytesValue VARBINARY(8000) NULL,
		DmlOperation CHAR(1) NOT NULL,
		MedicareStatusIndicatorRuleId INT NOT NULL,
		PlaceOfService VARCHAR(4) NOT NULL
		) ON DP_Ods_PartitionScheme (OdsCustomerId)
		WITH (DATA_COMPRESSION = PAGE);

	ALTER TABLE src.MedicareStatusIndicatorRulePlaceOfService ADD CONSTRAINT PK_MedicareStatusIndicatorRulePlaceOfService PRIMARY KEY CLUSTERED (
		OdsPostingGroupAuditId,
		OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		PlaceOfService
		)
		WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_MedicareStatusIndicatorRulePlaceOfService ON src.MedicareStatusIndicatorRulePlaceOfService REBUILD
		WITH (STATISTICS_INCREMENTAL = ON);
END
ELSE
BEGIN
	IF EXISTS (
			SELECT 1
			FROM sys.columns sc
			INNER JOIN sys.types st ON sc.user_type_id = st.user_type_id
			WHERE sc.object_id = OBJECT_ID('src.MedicareStatusIndicatorRulePlaceOfService')
				AND sc.name = 'PlaceOfService'
				AND NOT (
					st.name = 'varchar'
					AND sc.max_length = 4
					)
			)
		AND (COLUMNPROPERTY(OBJECT_ID('src.MedicareStatusIndicatorRulePlaceOfService', 'U'), 'PlaceOfService', 'AllowsNull') = 1)
	BEGIN
		ALTER TABLE src.MedicareStatusIndicatorRulePlaceOfService
		ALTER COLUMN PlaceOfService VARCHAR(4) NOT NULL;
	END;

	SET XACT_ABORT ON;

	IF OBJECT_ID('src.PK_MedicareStatusIndicatorRulePlaceOfService', 'PK') IS NOT NULL
		AND NOT EXISTS (
			SELECT 1
			FROM sys.indexes i
			INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id
				AND i.index_id = ic.index_id
			INNER JOIN sys.columns c ON ic.object_id = c.object_id
				AND ic.column_id = c.column_id
			INNER JOIN sys.objects o ON i.object_id = o.object_id
			WHERE i.is_primary_key = 1
				AND o.object_id = OBJECT_ID('src.MedicareStatusIndicatorRulePlaceOfService')
				AND c.name = 'PlaceOfService'
			)
	BEGIN
		BEGIN TRANSACTION;

		ALTER TABLE src.MedicareStatusIndicatorRulePlaceOfService
		DROP CONSTRAINT PK_MedicareStatusIndicatorRulePlaceOfService;

		ALTER TABLE src.MedicareStatusIndicatorRulePlaceOfService ADD CONSTRAINT PK_MedicareStatusIndicatorRulePlaceOfService PRIMARY KEY CLUSTERED (
			OdsPostingGroupAuditId,
			OdsCustomerId,
			MedicareStatusIndicatorRuleId,
			PlaceOfService
			)
			WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_MedicareStatusIndicatorRulePlaceOfService ON src.MedicareStatusIndicatorRulePlaceOfService REBUILD
			WITH (STATISTICS_INCREMENTAL = ON);

		COMMIT TRANSACTION;
	END;
END
GO

IF  EXISTS ( SELECT  1
			FROM    sys.columns c 
					INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
			WHERE   object_id = OBJECT_ID(N'src.MedicareStatusIndicatorRulePlaceOfService')
					AND c.name = 'PlaceOfService' 
					AND NOT ( t.name = 'VARCHAR' 
						 AND c.max_length = '4'
						   ) ) 
	BEGIN
		ALTER TABLE src.MedicareStatusIndicatorRulePlaceOfService ALTER COLUMN PlaceOfService VARCHAR(4) NOT NULL ;
	END 
GO
IF  EXISTS ( SELECT  1
			FROM    sys.columns c 
					INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
			WHERE   object_id = OBJECT_ID(N'src.MedicareStatusIndicatorRulePlaceOfService')
					AND c.name = 'PlaceOfService' 
					AND NOT ( t.name = 'VARCHAR' 
						 AND c.max_length = '4'
						   ) ) 
	BEGIN
		ALTER TABLE src.MedicareStatusIndicatorRulePlaceOfService ALTER COLUMN PlaceOfService VARCHAR(4) NOT NULL ;
	END 
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1 
                FROM sys.stats
                 WHERE name ='MedicareStatusIndicatorRulePlaceOfService' 
                 AND is_incremental = 1)  BEGIN
ALTER INDEX PK_MedicareStatusIndicatorRulePlaceOfService ON src.MedicareStatusIndicatorRulePlaceOfService   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
END ;
GO



IF OBJECT_ID('src.MedicareStatusIndicatorRuleProcedureCode', 'U') IS NULL
BEGIN
	CREATE TABLE src.MedicareStatusIndicatorRuleProcedureCode (
		OdsPostingGroupAuditId INT NOT NULL,
		OdsCustomerId INT NOT NULL,
		OdsCreateDate DATETIME2(7) NOT NULL,
		OdsSnapshotDate DATETIME2(7) NOT NULL,
		OdsRowIsCurrent BIT NOT NULL,
		OdsHashbytesValue VARBINARY(8000) NULL,
		DmlOperation CHAR(1) NOT NULL,
		MedicareStatusIndicatorRuleId INT NOT NULL,
		ProcedureCode VARCHAR(7) NOT NULL
		) ON DP_Ods_PartitionScheme (OdsCustomerId)
		WITH (DATA_COMPRESSION = PAGE);

	ALTER TABLE src.MedicareStatusIndicatorRuleProcedureCode ADD CONSTRAINT PK_MedicareStatusIndicatorRuleProcedureCode PRIMARY KEY CLUSTERED (
		OdsPostingGroupAuditId,
		OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		ProcedureCode
		)
		WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_MedicareStatusIndicatorRuleProcedureCode ON src.MedicareStatusIndicatorRuleProcedureCode REBUILD
		WITH (STATISTICS_INCREMENTAL = ON);
END
ELSE -- We should do below things only when object is not null
BEGIN
	IF COLUMNPROPERTY(OBJECT_ID('src.MedicareStatusIndicatorRuleProcedureCode', 'U'), 'ProcedureCode', 'AllowsNull') = 1
	BEGIN
		ALTER TABLE src.MedicareStatusIndicatorRuleProcedureCode
		ALTER COLUMN ProcedureCode VARCHAR(7) NOT NULL;
	END;

	SET XACT_ABORT ON;

	-- If the PK exists, but is missing our new column, drop and recreate it
	IF OBJECT_ID('src.PK_MedicareStatusIndicatorRuleProcedureCode', 'PK') IS NOT NULL
		AND NOT EXISTS (
			SELECT 1
			FROM sys.indexes i
			INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id
				AND i.index_id = ic.index_id
			INNER JOIN sys.columns c ON ic.object_id = c.object_id
				AND ic.column_id = c.column_id
			INNER JOIN sys.objects o ON i.object_id = o.object_id
			WHERE i.is_primary_key = 1
				AND o.object_id = OBJECT_ID('src.MedicareStatusIndicatorRuleProcedureCode')
				AND c.name = 'ProcedureCode'
			)
	BEGIN
		BEGIN TRANSACTION;

		ALTER TABLE src.MedicareStatusIndicatorRuleProcedureCode
		DROP CONSTRAINT PK_MedicareStatusIndicatorRuleProcedureCode;

		ALTER TABLE src.MedicareStatusIndicatorRuleProcedureCode ADD CONSTRAINT PK_MedicareStatusIndicatorRuleProcedureCode PRIMARY KEY CLUSTERED (
			OdsPostingGroupAuditId,
			OdsCustomerId,
			MedicareStatusIndicatorRuleId,
			ProcedureCode
			)
			WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_MedicareStatusIndicatorRuleProcedureCode ON src.MedicareStatusIndicatorRuleProcedureCode REBUILD
			WITH (STATISTICS_INCREMENTAL = ON);

		COMMIT TRANSACTION;
	END;
END
GO


IF OBJECT_ID('src.MedicareStatusIndicatorRuleProviderSpecialty', 'U') IS NULL
BEGIN
	CREATE TABLE src.MedicareStatusIndicatorRuleProviderSpecialty (
		OdsPostingGroupAuditId INT NOT NULL,
		OdsCustomerId INT NOT NULL,
		OdsCreateDate DATETIME2(7) NOT NULL,
		OdsSnapshotDate DATETIME2(7) NOT NULL,
		OdsRowIsCurrent BIT NOT NULL,
		OdsHashbytesValue VARBINARY(8000) NULL,
		DmlOperation CHAR(1) NOT NULL,
		MedicareStatusIndicatorRuleId INT NOT NULL,
		ProviderSpecialty VARCHAR(6) NOT NULL
		) ON DP_Ods_PartitionScheme (OdsCustomerId)
		WITH (DATA_COMPRESSION = PAGE);

	ALTER TABLE src.MedicareStatusIndicatorRuleProviderSpecialty ADD CONSTRAINT PK_MedicareStatusIndicatorRuleProviderSpecialty PRIMARY KEY CLUSTERED (
		OdsPostingGroupAuditId,
		OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		ProviderSpecialty
		)
		WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_MedicareStatusIndicatorRuleProviderSpecialty ON src.MedicareStatusIndicatorRuleProviderSpecialty REBUILD
		WITH (STATISTICS_INCREMENTAL = ON);
END
ELSE -- We should do below things only when object is not null
BEGIN
	IF COLUMNPROPERTY(OBJECT_ID('src.MedicareStatusIndicatorRuleProviderSpecialty', 'U'), 'ProviderSpecialty', 'AllowsNull') = 1
	BEGIN
		ALTER TABLE src.MedicareStatusIndicatorRuleProviderSpecialty
		ALTER COLUMN ProviderSpecialty VARCHAR(6) NOT NULL;
	END;

	SET XACT_ABORT ON;

	-- If the PK exists, but is missing our new column, drop and recreate it
	IF OBJECT_ID('src.PK_MedicareStatusIndicatorRuleProviderSpecialty', 'PK') IS NOT NULL
		AND NOT EXISTS (
			SELECT 1
			FROM sys.indexes i
			INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id
				AND i.index_id = ic.index_id
			INNER JOIN sys.columns c ON ic.object_id = c.object_id
				AND ic.column_id = c.column_id
			INNER JOIN sys.objects o ON i.object_id = o.object_id
			WHERE i.is_primary_key = 1
				AND o.object_id = OBJECT_ID('src.MedicareStatusIndicatorRuleProviderSpecialty')
				AND c.name = 'ProviderSpecialty'
			)
	BEGIN
		BEGIN TRANSACTION;

		ALTER TABLE src.MedicareStatusIndicatorRuleProviderSpecialty
		DROP CONSTRAINT PK_MedicareStatusIndicatorRuleProviderSpecialty;

		ALTER TABLE src.MedicareStatusIndicatorRuleProviderSpecialty ADD CONSTRAINT PK_MedicareStatusIndicatorRuleProviderSpecialty PRIMARY KEY CLUSTERED (
			OdsPostingGroupAuditId,
			OdsCustomerId,
			MedicareStatusIndicatorRuleId,
			ProviderSpecialty
			)
			WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_MedicareStatusIndicatorRuleProviderSpecialty ON src.MedicareStatusIndicatorRuleProviderSpecialty REBUILD
			WITH (STATISTICS_INCREMENTAL = ON);

		COMMIT TRANSACTION;
	END;
END
GO

IF OBJECT_ID('src.ModifierByState', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ModifierByState
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  State VARCHAR (2) NOT NULL ,
			  ProcedureServiceCategoryId TINYINT NOT NULL ,
			  ModifierDictionaryId INT NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ModifierByState ADD 
     CONSTRAINT PK_ModifierByState PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, State, ProcedureServiceCategoryId, ModifierDictionaryId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ModifierByState ON src.ModifierByState   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.ModifierDictionary', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ModifierDictionary
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ModifierDictionaryId INT NOT NULL ,
			  Modifier VARCHAR (2) NULL ,
			  StartDate DATETIME2 (7) NULL ,
			  EndDate DATETIME2 (7) NULL ,
			  Description VARCHAR (100) NULL ,
			  Global BIT NULL ,
			  AnesMedDirect BIT NULL ,
			  AffectsPricing BIT NULL ,
			  IsCoSurgeon BIT NULL ,
			  IsAssistantSurgery BIT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ModifierDictionary ADD 
     CONSTRAINT PK_ModifierDictionary PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ModifierDictionaryId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ModifierDictionary ON src.ModifierDictionary   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.ModifierToProcedureCode', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ModifierToProcedureCode
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ProcedureCode VARCHAR (5) NOT NULL ,
			  Modifier VARCHAR (2) NOT NULL ,
			  StartDate DATETIME2 (7) NOT NULL ,
			  EndDate DATETIME2 (7) NULL ,
			  SojFlag SMALLINT NULL ,
			  RequiresGuidelineReview BIT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ModifierToProcedureCode ADD 
     CONSTRAINT PK_ModifierToProcedureCode PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ProcedureCode, Modifier, StartDate) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ModifierToProcedureCode ON src.ModifierToProcedureCode   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.ModifierToProcedureCode')
						AND NAME = 'Reference' )
	BEGIN
		ALTER TABLE src.ModifierToProcedureCode ADD Reference VARCHAR(255) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.ModifierToProcedureCode')
						AND NAME = 'Comments' )
	BEGIN
		ALTER TABLE src.ModifierToProcedureCode ADD Comments VARCHAR(255) NULL ;
	END ; 
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1 
                FROM sys.stats
                WHERE name = 'PK_ModifierToProcedureCode' 
                AND is_incremental = 1)  
BEGIN
ALTER INDEX PK_ModifierToProcedureCode ON src.ModifierToProcedureCode   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 

END ;
GO


IF OBJECT_ID('src.NcciBodyPart', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.NcciBodyPart
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  NcciBodyPartId TINYINT NOT NULL ,
			  Description VARCHAR (100) NULL ,
			  NarrativeInformation VARCHAR (MAX) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.NcciBodyPart ADD 
     CONSTRAINT PK_NcciBodyPart PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, NcciBodyPartId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_NcciBodyPart ON src.NcciBodyPart   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.NcciBodyPartToHybridBodyPartTranslation', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.NcciBodyPartToHybridBodyPartTranslation
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  NcciBodyPartId TINYINT NOT NULL ,
			  HybridBodyPartId SMALLINT NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.NcciBodyPartToHybridBodyPartTranslation ADD 
     CONSTRAINT PK_NcciBodyPartToHybridBodyPartTranslation PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, NcciBodyPartId, HybridBodyPartId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_NcciBodyPartToHybridBodyPartTranslation ON src.NcciBodyPartToHybridBodyPartTranslation   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.Note', 'U') IS NULL
    BEGIN
        CREATE TABLE src.Note
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  NoteId int NOT NULL,
	          DateCreated datetimeoffset(7) NULL,
	          DateModified datetimeoffset(7) NULL,
	          CreatedBy varchar(15) NULL,
	          ModifiedBy varchar(15) NULL,
	          Flag tinyint NULL,
	          Content varchar(250) NULL,
	          NoteContext smallint NULL,
	          DemandClaimantId int NULL
	          
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Note ADD 
        CONSTRAINT PK_Note PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,NoteId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Note ON src.Note REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Note'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Note ON src.Note REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.ny_Pharmacy', 'U') IS NULL
    BEGIN
        CREATE TABLE src.ny_Pharmacy
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              NDCCode VARCHAR(13) NOT NULL ,
              StartDate DATETIME NOT NULL ,
              EndDate DATETIME NULL ,
              Description VARCHAR(125) NULL ,
              Fee MONEY NOT NULL ,
              TypeOfDrug SMALLINT NOT NULL 
              
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.ny_Pharmacy ADD 
        CONSTRAINT PK_ny_Pharmacy PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, NDCCode, StartDate, TypeOfDrug) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_ny_Pharmacy ON src.ny_Pharmacy REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_ny_Pharmacy'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_ny_Pharmacy ON src.ny_Pharmacy REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

IF OBJECT_ID('src.ny_specialty', 'U') IS NULL
    BEGIN
        CREATE TABLE src.ny_specialty
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,  
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              RatingCode VARCHAR(12) NOT NULL ,
              Desc_ VARCHAR(70) NULL 
            
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.ny_specialty ADD 
        CONSTRAINT PK_ny_specialty PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, RatingCode) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_ny_specialty ON src.ny_specialty REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.ny_Specialty')
						AND NAME = 'CbreSpecialtyCode' )
	BEGIN
		ALTER TABLE src.ny_Specialty ADD CbreSpecialtyCode VARCHAR(12) NULL ;
	END ; 
GO


-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_ny_specialty'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_ny_specialty ON src.ny_specialty REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

IF OBJECT_ID('src.pa_PlaceOfService', 'U') IS NULL
    BEGIN
        CREATE TABLE src.pa_PlaceOfService
            (
			OdsPostingGroupAuditId INT NOT NULL ,
			OdsCustomerId INT NOT NULL ,
			OdsCreateDate DATETIME2(7) NOT NULL ,
			OdsSnapshotDate DATETIME2(7) NOT NULL ,
			OdsRowIsCurrent BIT NOT NULL ,
			OdsHashbytesValue VARBINARY(8000) NULL ,
			DmlOperation CHAR(1) NOT NULL ,
			POS SMALLINT NOT NULL,
			Description VARCHAR(255) NULL,
			Facility SMALLINT NULL,
			MHL SMALLINT NULL,
			PlusFour SMALLINT NULL,
			Institution INT NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.pa_PlaceOfService ADD 
        CONSTRAINT PK_pa_PlaceOfService PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, POS) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_pa_PlaceOfService ON src.pa_PlaceOfService REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_pa_PlaceOfService'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_pa_PlaceOfService ON src.pa_PlaceOfService REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.PlaceOfServiceDictionary', 'U') IS NULL
    BEGIN
        CREATE TABLE src.PlaceOfServiceDictionary
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL , 
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              PlaceOfServiceCode SMALLINT NOT NULL,
			  [Description] VARCHAR(255) NULL,
	          Facility SMALLINT NULL,
	          MHL SMALLINT NULL,
	          PlusFour SMALLINT NULL,
	          Institution INT NULL,
	          StartDate DATETIME2(7) NOT NULL,
	          EndDate DATETIME2(7) NULL
             
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.PlaceOfServiceDictionary ADD 
        CONSTRAINT PK_PlaceOfServiceDictionary PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, PlaceOfServiceCode, StartDate) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_PlaceOfServiceDictionary ON src.PlaceOfServiceDictionary REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_PlaceOfServiceDictionary'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_PlaceOfServiceDictionary ON src.PlaceOfServiceDictionary REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO


IF OBJECT_ID('src.PrePpoBillInfo', 'U') IS NULL
    BEGIN
        CREATE TABLE src.PrePpoBillInfo
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              DateSentToPPO DATETIME NULL ,
              ClaimNo VARCHAR(50) NULL ,
              ClaimIDNo INT NULL ,
              CompanyID INT NULL ,
              OfficeIndex INT NULL ,
              CV_Code VARCHAR(2) NULL ,
              DateLoss DATETIME NULL ,
              Deductible MONEY NULL ,
              PaidCoPay MONEY NULL ,
              PaidDeductible MONEY NULL ,
              LossState VARCHAR(2) NULL ,
              CmtIDNo INT NULL ,
              CmtCoPaymentMax MONEY NULL ,
              CmtCoPaymentPercentage SMALLINT NULL ,
              CmtDedType SMALLINT NULL ,
              CmtDeductible MONEY NULL ,
              CmtFLCopay SMALLINT NULL ,
              CmtPolicyLimit MONEY NULL ,
              CmtStateOfJurisdiction VARCHAR(2) NULL ,
              PvdIDNo INT NULL ,
              PvdTIN VARCHAR(15) NULL ,
              PvdSPC_List VARCHAR(50) NULL ,
              PvdTitle VARCHAR(5) NULL ,
              PvdFlags INT NULL ,
              DateSaved DATETIME NULL ,
              DateRcv DATETIME NULL ,
              InvoiceDate DATETIME NULL ,
              NoLines SMALLINT NULL ,
              AmtCharged MONEY NULL ,
              AmtAllowed MONEY NULL ,
              Region VARCHAR(50) NULL ,
              FeatureID INT NULL ,
              Flags INT NULL ,
              WhoCreate VARCHAR(15) NULL ,
              WhoLast VARCHAR(15) NULL ,
              CmtPaidDeductible MONEY NULL ,
              InsPaidLimit MONEY NULL ,
              StatusFlag VARCHAR(2) NULL ,
              CmtPaidCoPay MONEY NULL ,
              Category INT NULL ,
              CatDesc VARCHAR(1000) NULL ,
              CreateDate DATETIME NULL ,
              PvdZOS VARCHAR(12) NULL ,
              AdmissionDate DATETIME NULL ,
              DischargeDate DATETIME NULL ,
              DischargeStatus SMALLINT NULL ,
              TypeOfBill VARCHAR(4) NULL ,
              PaymentDecision SMALLINT NULL ,
              PPONumberSent SMALLINT NULL ,
              BillIDNo INT NULL ,
              LINE_NO SMALLINT NULL ,
              LINE_NO_DISP SMALLINT NULL ,
              OVER_RIDE SMALLINT NULL ,
              DT_SVC DATETIME NULL ,
              PRC_CD VARCHAR(7) NULL ,
              UNITS REAL NULL ,
              TS_CD VARCHAR(14) NULL ,
              CHARGED MONEY NULL ,
              ALLOWED MONEY NULL ,
              ANALYZED MONEY NULL ,
              REF_LINE_NO SMALLINT NULL ,
              SUBNET VARCHAR(9) NULL ,
              FEE_SCHEDULE MONEY NULL ,
              POS_RevCode VARCHAR(4) NULL ,
              CTGPenalty MONEY NULL ,
              PrePPOAllowed MONEY NULL ,
              PPODate DATETIME NULL ,
              PPOCTGPenalty MONEY NULL ,
              UCRPerUnit MONEY NULL ,
              FSPerUnit MONEY NULL ,
              HCRA_Surcharge MONEY NULL ,
              NDC VARCHAR(13) NULL ,
              PriceTypeCode VARCHAR(2) NULL ,
              PharmacyLine SMALLINT NULL ,
              Endnotes VARCHAR(50) NULL ,
              SentryEN VARCHAR(250) NULL ,
              CTGEN VARCHAR(250) NULL ,
              CTGRuleType VARCHAR(250) NULL ,
              CTGRuleID VARCHAR(250) NULL ,
              OverrideEN VARCHAR(50) NULL ,
              UserId INT NULL ,
              DateOverriden DATETIME NULL ,
              AmountBeforeOverride MONEY NULL ,
              AmountAfterOverride MONEY NULL ,
              CodesOverriden VARCHAR(50) NULL ,
              NetworkID INT NULL ,
              BillSnapshot VARCHAR(30) NULL ,
              PPOSavings MONEY NULL ,
              RevisedDate DATETIME NULL ,
              ReconsideredDate DATETIME NULL ,
              TierNumber SMALLINT NULL ,
              PPOBillInfoID INT NULL ,
              PrePPOBillInfoID INT NOT NULL,
			  CtgCoPayPenalty DECIMAL(19,4) NULL,
			  PpoCtgCoPayPenalty DECIMAL(19,4) NULL,
			  CtgVunPenalty DECIMAL(19,4) NULL,
			  PpoCtgVunPenalty DECIMAL(19,4) NULL
              
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.PrePpoBillInfo ADD 
        CONSTRAINT PK_PrePpoBillInfo PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, PrePpoBillInfoId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_PrePpoBillInfo ON src.PrePpoBillInfo REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

IF EXISTS ( SELECT  1
            FROM    sys.columns c
                    INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
            WHERE   c.object_id = OBJECT_ID(N'src.PrePpoBillInfo')
                    AND c.name = 'Region'
                    AND NOT ( t.name = 'VARCHAR'
                              AND c.max_length = 50
                            ) )
    BEGIN
        ALTER TABLE src.PrePpoBillInfo ALTER COLUMN Region VARCHAR(50) NULL;
    END;
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.PrePPOBillInfo')
						AND NAME = 'CtgCoPayPenalty' )
	BEGIN
		ALTER TABLE src.PrePPOBillInfo ADD CtgCoPayPenalty DECIMAL(19,4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.PrePPOBillInfo')
						AND NAME = 'PpoCtgCoPayPenalty' )
	BEGIN
		ALTER TABLE src.PrePPOBillInfo ADD PpoCtgCoPayPenalty DECIMAL(19,4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.PrePPOBillInfo')
						AND NAME = 'CtgVunPenalty' )
	BEGIN
		ALTER TABLE src.PrePPOBillInfo ADD CtgVunPenalty DECIMAL(19,4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.PrePPOBillInfo')
						AND NAME = 'PpoCtgVunPenalty' )
	BEGIN
		ALTER TABLE src.PrePPOBillInfo ADD PpoCtgVunPenalty DECIMAL(19,4) NULL ;
	END ; 
GO


SET XACT_ABORT ON 
IF EXISTS ( SELECT  1
				FROM    sys.columns c 
				WHERE   object_id = OBJECT_ID(N'src.PrePPOBillInfo')
						AND NAME =  'PpoCtgCoPayPenalty' )
	BEGIN
		BEGIN TRANSACTION
			EXEC SP_RENAME 'src.PrePPOBillInfo.PpoCtgCoPayPenalty' ,  'PpoCtgCoPayPenaltyPercentage'  , 'COLUMN' 
		COMMIT TRANSACTION
	END
GO



SET XACT_ABORT ON 
IF EXISTS ( SELECT  1
				FROM    sys.columns c 
				WHERE   object_id = OBJECT_ID(N'src.PrePPOBillInfo')
						AND NAME =  'PpoCtgVunPenalty' )
	BEGIN
		BEGIN TRANSACTION
			EXEC SP_RENAME 'src.PrePPOBillInfo.PpoCtgVunPenalty' ,  'PpoCtgVunPenaltyPercentage'  , 'COLUMN' 
		COMMIT TRANSACTION
	END
GO


-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_PrePpoBillInfo'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_PrePpoBillInfo ON src.PrePpoBillInfo REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO



IF OBJECT_ID('src.prf_COMPANY', 'U') IS NULL
    BEGIN
        CREATE TABLE src.prf_COMPANY
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              CompanyId INT NOT NULL ,
              CompanyName VARCHAR(50) NULL ,
              LastChangedOn DATETIME NULL 
              
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.prf_COMPANY ADD 
        CONSTRAINT PK_prf_COMPANY PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, CompanyId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_prf_COMPANY ON src.prf_COMPANY REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_prf_COMPANY'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_prf_COMPANY ON src.prf_COMPANY REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.prf_CTGMaxPenaltyLines', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.prf_CTGMaxPenaltyLines
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  CTGMaxPenLineID INT NOT NULL ,
			  ProfileId INT NULL ,
			  DatesBasedOn SMALLINT NULL ,
			  MaxPenaltyPercent SMALLINT NULL ,
			  StartDate DATETIME NULL ,
			  EndDate DATETIME NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.prf_CTGMaxPenaltyLines ADD 
     CONSTRAINT PK_prf_CTGMaxPenaltyLines PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, CTGMaxPenLineID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_prf_CTGMaxPenaltyLines ON src.prf_CTGMaxPenaltyLines   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.prf_CTGPenalty', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.prf_CTGPenalty
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  CTGPenID INT NOT NULL ,
			  ProfileId INT NULL ,
			  ApplyPreCerts SMALLINT NULL ,
			  NoPrecertLogged SMALLINT NULL ,
			  MaxTotalPenalty SMALLINT NULL ,
			  TurnTimeForAppeals SMALLINT NULL ,
			  ApplyEndnoteForPercert SMALLINT NULL ,
			  ApplyEndnoteForCarePath SMALLINT NULL ,
			  ExemptPrecertPenalty SMALLINT NULL ,
			  ApplyNetworkPenalty BIT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.prf_CTGPenalty ADD 
     CONSTRAINT PK_prf_CTGPenalty PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, CTGPenID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_prf_CTGPenalty ON src.prf_CTGPenalty   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.prf_CTGPenaltyHdr', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.prf_CTGPenaltyHdr
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  CTGPenHdrID INT NOT NULL ,
			  ProfileId INT NULL ,
			  PenaltyType SMALLINT NULL ,
			  PayNegRate SMALLINT NULL ,
			  PayPPORate SMALLINT NULL ,
			  DatesBasedOn SMALLINT NULL ,
			  ApplyPenaltyToPharmacy BIT NULL ,
			  ApplyPenaltyCondition BIT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.prf_CTGPenaltyHdr ADD 
     CONSTRAINT PK_prf_CTGPenaltyHdr PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, CTGPenHdrID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_prf_CTGPenaltyHdr ON src.prf_CTGPenaltyHdr   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.prf_CTGPenaltyLines', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.prf_CTGPenaltyLines
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  CTGPenLineID INT NOT NULL ,
			  ProfileId INT NULL ,
			  PenaltyType SMALLINT NULL ,
			  FeeSchedulePercent SMALLINT NULL ,
			  StartDate DATETIME NULL ,
			  EndDate DATETIME NULL ,
			  TurnAroundTime SMALLINT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.prf_CTGPenaltyLines ADD 
     CONSTRAINT PK_prf_CTGPenaltyLines PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, CTGPenLineID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_prf_CTGPenaltyLines ON src.prf_CTGPenaltyLines   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.Prf_CustomIcdAction', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Prf_CustomIcdAction
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  CustomIcdActionId INT NOT NULL ,
			  ProfileId INT NULL ,
			  IcdVersionId TINYINT NULL ,
			  Action SMALLINT NULL ,
			  StartDate DATETIME NULL ,
			  EndDate DATETIME NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Prf_CustomIcdAction ADD 
     CONSTRAINT PK_Prf_CustomIcdAction PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, CustomIcdActionId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Prf_CustomIcdAction ON src.Prf_CustomIcdAction   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.prf_Office', 'U') IS NULL
    BEGIN
        CREATE TABLE src.prf_Office
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              CompanyId INT NULL ,
              OfficeId INT NOT NULL ,
              OfcNo VARCHAR(4) NULL ,
              OfcName VARCHAR(40) NULL ,
              OfcAddr1 VARCHAR(30) NULL ,
              OfcAddr2 VARCHAR(30) NULL ,
              OfcCity VARCHAR(30) NULL ,
              OfcState VARCHAR(2) NULL ,
              OfcZip VARCHAR(12) NULL ,
              OfcPhone VARCHAR(20) NULL ,
              OfcDefault SMALLINT NULL ,
              OfcClaimMask VARCHAR(50) NULL ,
              OfcTinMask VARCHAR(50) NULL ,
              Version SMALLINT NULL ,
              OfcEdits INT NULL ,
              OfcCOAEnabled SMALLINT NULL ,
              CTGEnabled SMALLINT NULL ,
              LastChangedOn DATETIME NULL ,
              AllowMultiCoverage BIT NULL
            )
        ON  DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.prf_Office ADD 
        CONSTRAINT PK_prf_Office PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, OfficeId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_prf_Office ON src.prf_Office REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END;
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.prf_Office')
                        AND NAME = 'AllowMultiCoverage' )
    BEGIN
        ALTER TABLE src.prf_Office ADD AllowMultiCoverage BIT NULL;
    END;
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_prf_Office'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_prf_Office ON src.prf_Office REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.Prf_OfficeUDF', 'U') IS NULL
BEGIN
    CREATE TABLE src.Prf_OfficeUDF
        (
          OdsPostingGroupAuditId INT NOT NULL ,
          OdsCustomerId INT NOT NULL ,
          OdsCreateDate DATETIME2(7) NOT NULL ,
          OdsSnapshotDate DATETIME2(7) NOT NULL ,
          OdsRowIsCurrent BIT NOT NULL ,
          OdsHashbytesValue VARBINARY(8000) NULL,
          DmlOperation CHAR(1) NOT NULL ,
          OfficeId INT NOT NULL ,
          UDFIdNo INT NOT NULL 
        ) ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (DATA_COMPRESSION = PAGE);

    ALTER TABLE src.Prf_OfficeUDF ADD 
    CONSTRAINT PK_Prf_OfficeUDF PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, OfficeId, UDFIdNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_Prf_OfficeUDF ON src.Prf_OfficeUDF REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Prf_OfficeUDF'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Prf_OfficeUDF ON src.Prf_OfficeUDF REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.prf_PPO', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.prf_PPO
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  PPOSysId INT NOT NULL ,
			  ProfileId INT NULL ,
			  PPOId INT NULL ,
			  bStatus SMALLINT NULL ,
			  StartDate DATETIME NULL ,
			  EndDate DATETIME NULL ,
			  AutoSend SMALLINT NULL ,
			  AutoResend SMALLINT NULL ,
			  BypassMatching SMALLINT NULL ,
			  UseProviderNetworkEnrollment SMALLINT NULL ,
			  TieredTypeId SMALLINT NULL ,
			  Priority SMALLINT NULL ,
			  PolicyEffectiveDate DATETIME NULL ,
			  BillFormType INT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.prf_PPO ADD 
     CONSTRAINT PK_prf_PPO PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, PPOSysId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_prf_PPO ON src.prf_PPO   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.prf_Profile', 'U') IS NULL
    BEGIN
    CREATE TABLE src.prf_Profile
        (
            OdsPostingGroupAuditId INT NOT NULL ,
            OdsCustomerId INT NOT NULL ,
            OdsCreateDate DATETIME2(7) NOT NULL ,
            OdsSnapshotDate DATETIME2(7) NOT NULL ,
            OdsRowIsCurrent BIT NOT NULL ,
            OdsHashbytesValue VARBINARY(8000) NULL ,
            DmlOperation CHAR(1) NOT NULL ,
			ProfileId INT NOT NULL,
			OfficeId INT NULL,
			CoverageId VARCHAR(2) NULL,
			StateId VARCHAR(2) NULL,
			AnHeader VARCHAR(MAX) NULL,
			AnFooter VARCHAR(MAX) NULL,
			ExHeader VARCHAR(MAX) NULL,
			ExFooter VARCHAR(MAX) NULL,
			AnalystEdits BIGINT NULL,
			DxEdits INT NULL,
			DxNonTraumaDays INT NULL,
			DxNonSpecDays INT NULL,
			PrintCopies INT NULL,
			NewPvdState VARCHAR(2) NULL,
			bDuration SMALLINT NULL,
			bLimits SMALLINT NULL,
			iDurPct SMALLINT NULL,
			iLimitPct SMALLINT NULL,
			PolicyLimit MONEY NULL,
			CoPayPercent INT NULL,
			CoPayMax MONEY NULL,
			Deductible MONEY NULL,
			PolicyWarn SMALLINT NULL,
			PolicyWarnPerc INT NULL,
			FeeSchedules INT NULL,
			DefaultProfile SMALLINT NULL,
			FeeAncillaryPct SMALLINT NULL,
			iGapdol SMALLINT NULL,
			iGapTreatmnt SMALLINT NULL,
			bGapTreatmnt SMALLINT NULL,
			bGapdol SMALLINT NULL,
			bPrintAdjustor SMALLINT NULL,
			sPrinterName VARCHAR(50) NULL,
			ErEdits INT NULL,
			ErAllowedDays INT NULL,
			UcrFsRules INT NULL,
			LogoIdNo INT NULL,
			LogoJustify SMALLINT NULL,
			BillLine VARCHAR(50) NULL,
			Version SMALLINT NULL,
			ClaimDeductible SMALLINT NULL,
			IncludeCommitted SMALLINT NULL,
			FLMedicarePercent SMALLINT NULL,
			UseLevelOfServiceUrl SMALLINT NULL,
			LevelOfServiceURL VARCHAR(250) NULL,
			CCIPrimary SMALLINT NULL,
			CCISecondary SMALLINT NULL,
			CCIMutuallyExclusive SMALLINT NULL,
			CCIComprehensiveComponent SMALLINT NULL,
			PayDRGAllowance SMALLINT NULL,
			FLHospEmPriceOn SMALLINT NULL,
			EnableBillRelease SMALLINT NULL,
			DisableSubmitBill SMALLINT NULL,
			MaxPaymentsPerBill SMALLINT NULL,
			NoOfPmtPerBill INT NULL,
			DefaultDueDate SMALLINT NULL,
			CheckForNJCarePaths SMALLINT NULL,
			NJCarePathPercentFS SMALLINT NULL,
			ApplyEndnoteForNJCarePaths SMALLINT NULL,
			FLMedicarePercent2008 SMALLINT NULL,
			RequireEndnoteDuringOverride SMALLINT NULL,
			StorePerUnitFSandUCR SMALLINT NULL,
			UseProviderNetworkEnrollment SMALLINT NULL,
			UseASCRule SMALLINT NULL,
			AsstCoSurgeonEligible SMALLINT NULL,
			LastChangedOn datetime NULL,
			IsNJPhysMedCapAfterCTG SMALLINT NULL,
			IsEligibleAmtFeeBased SMALLINT NULL,
			HideClaimTreeTotalsGrid SMALLINT NULL,
			SortBillsBy SMALLINT NULL,
			SortBillsByOrder SMALLINT NULL,
			ApplyNJEmergencyRoomBenchmarkFee SMALLINT NULL,
			AllowIcd10ForNJCarePaths SMALLINT NULL,
			EnableOverrideDeductible BIT NULL,
			AnalyzeDiagnosisPointers BIT NULL,
			MedicareFeePercent SMALLINT NULL,
			EnableSupplementalNdcData BIT NULL,
			ApplyOriginalNdcAwp BIT NULL,
			NdcAwpNotAvailable TINYINT NULL,
			PayEapgAllowance SMALLINT NULL,
			MedicareInpatientApcEnabled BIT NULL,
			MedicareOutpatientAscEnabled BIT NULL,
			MedicareAscEnabled BIT NULL,
			UseMedicareInpatientApcFee BIT NULL,
			MedicareInpatientDrgEnabled BIT NULL,
			MedicareInpatientDrgPricingType SMALLINT NULL,
			MedicarePhysicianEnabled BIT NULL,
			MedicareAmbulanceEnabled BIT NULL,
			MedicareDmeposEnabled BIT NULL,
			MedicareAspDrugAndClinicalEnabled BIT NULL,
			MedicareInpatientPricingType SMALLINT NULL,
			MedicareOutpatientPricingRulesEnabled BIT NULL,
			MedicareAscPricingRulesEnabled BIT NULL,
			NjUseAdmitTypeEnabled BIT NULL,
			MedicareClinicalLabEnabled BIT NULL,
			MedicareInpatientEnabled BIT NULL,
			MedicareOutpatientApcEnabled BIT NULL,
			MedicareAspDrugEnabled BIT NULL,
			ShowAllocationsOnEob BIT NULL,
			EmergencyCarePricingRuleId TINYINT NULL,
			OutOfStatePricingEffectiveDateId TINYINT NULL,
			PreAllocation BIT NULL,
			AssistantCoSurgeonModifiers SMALLINT NULL,
			AssistantSurgeryModifierNotMedicallyNecessary SMALLINT NULL,
			AssistantSurgeryModifierRequireAdditionalDocument SMALLINT NULL,
			CoSurgeryModifierNotMedicallyNecessary SMALLINT NULL,
			CoSurgeryModifierRequireAdditionalDocument SMALLINT NULL,
			DxNoDiagnosisDays INT NULL,
			ModifierExempted BIT NULL
            )
        ON  DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.prf_Profile ADD 
        CONSTRAINT PK_prf_Profile PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ProfileId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);
		
		ALTER INDEX PK_prf_Profile ON src.prf_Profile REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END;
GO
IF OBJECT_ID('src.ProcedureCodeGroup', 'U') IS NULL
    BEGIN
        CREATE TABLE src.ProcedureCodeGroup
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              ProcedureCode VARCHAR(7) NOT NULL ,
              MajorCategory VARCHAR(500) NULL ,
              MinorCategory VARCHAR(500) NULL 
              
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.ProcedureCodeGroup ADD 
        CONSTRAINT PK_ProcedureCodeGroup PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ProcedureCode) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_ProcedureCodeGroup ON src.ProcedureCodeGroup REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_ProcedureCodeGroup'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_ProcedureCodeGroup ON src.ProcedureCodeGroup REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.ProcedureServiceCategory', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ProcedureServiceCategory
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ProcedureServiceCategoryId TINYINT NOT NULL ,
			  ProcedureServiceCategoryName VARCHAR (50) NULL ,
			  ProcedureServiceCategoryDescription VARCHAR (100) NULL ,
			  LegacyTableName VARCHAR (100) NULL ,
			  LegacyBitValue INT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ProcedureServiceCategory ADD 
     CONSTRAINT PK_ProcedureServiceCategory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ProcedureServiceCategoryId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ProcedureServiceCategory ON src.ProcedureServiceCategory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.ProvidedLink', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ProvidedLink
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ProvidedLinkId INT NOT NULL ,
			  Title VARCHAR (100) NULL ,
			  URL VARCHAR (150) NULL ,
			  OrderIndex TINYINT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ProvidedLink ADD 
     CONSTRAINT PK_ProvidedLink PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ProvidedLinkId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ProvidedLink ON src.ProvidedLink   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.PROVIDER', 'U') IS NULL
    BEGIN
        CREATE TABLE src.PROVIDER
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,  
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              PvdIDNo INT NOT NULL ,
              PvdMID INT NULL ,
              PvdSource SMALLINT NULL ,
              PvdTIN VARCHAR(15) NULL ,
              PvdLicNo VARCHAR(30) NULL ,
              PvdCertNo VARCHAR(30) NULL ,
              PvdLastName VARCHAR(60) NULL ,
              PvdFirstName VARCHAR(35) NULL ,
              PvdMI VARCHAR(1) NULL ,
              PvdTitle VARCHAR(5) NULL ,
              PvdGroup VARCHAR(60) NULL ,
              PvdAddr1 VARCHAR(55) NULL ,
              PvdAddr2 VARCHAR(55) NULL ,
              PvdCity VARCHAR(30) NULL ,
              PvdState VARCHAR(2) NULL ,
              PvdZip VARCHAR(12) NULL ,
              PvdZipPerf VARCHAR(12) NULL ,
              PvdPhone VARCHAR(25) NULL ,
              PvdFAX VARCHAR(13) NULL ,
              PvdSPC_List VARCHAR(MAX) NULL ,
              PvdAuthNo VARCHAR(30) NULL ,
              PvdSPC_ACD VARCHAR(2) NULL ,
              PvdUpdateCounter SMALLINT NULL ,
              PvdPPO_Provider SMALLINT NULL ,
              PvdFlags INT NULL ,
              PvdERRate MONEY NULL ,
              PvdSubNet VARCHAR(4) NULL ,
              InUse VARCHAR(100) NULL ,
              PvdStatus INT NULL ,
              PvdElectroStartDate DATETIME NULL ,
              PvdElectroEndDate DATETIME NULL ,
              PvdAccredStartDate DATETIME NULL ,
              PvdAccredEndDate DATETIME NULL ,
              PvdRehabStartDate DATETIME NULL ,
              PvdRehabEndDate DATETIME NULL ,
              PvdTraumaStartDate DATETIME NULL ,
              PvdTraumaEndDate DATETIME NULL ,
              OPCERT VARCHAR(7) NULL ,
              PvdDentalStartDate DATETIME NULL ,
              PvdDentalEndDate DATETIME NULL ,
              PvdNPINo VARCHAR(10) NULL ,
              PvdCMSId VARCHAR(6) NULL ,
              CreateDate DATETIME NULL ,
              LastChangedOn DATETIME NULL 
            
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.PROVIDER ADD 
        CONSTRAINT PK_PROVIDER PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, PvdIDNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_PROVIDER ON src.PROVIDER REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO


IF  EXISTS ( SELECT  1
			FROM    sys.columns c 
					INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
			WHERE   object_id = OBJECT_ID(N'src.PROVIDER')
					AND c.name = 'PvdSPC_List' 
					AND NOT ( t.name = 'VARCHAR' 
						 AND c.max_length = '-1'
						   ) ) 
	BEGIN
		ALTER TABLE src.PROVIDER ALTER COLUMN PvdSPC_List VARCHAR(MAX) NULL ;
	END ; 
GO





-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_PROVIDER'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_PROVIDER ON src.PROVIDER REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO





IF OBJECT_ID('src.ProviderCluster', 'U') IS NULL
    BEGIN
        CREATE TABLE src.ProviderCluster
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  PvdIDNo INT NOT NULL, 
			  OrgOdsCustomerId INT NOT NULL,
			  MitchellProviderKey VARCHAR(200) NULL,
			  ProviderClusterKey VARCHAR(200) NULL,
			  ProviderType VARCHAR(30) NULL

            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.ProviderCluster ADD 
        CONSTRAINT PK_ProviderCluster PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,PvdIDNo , OrgOdsCustomerId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);
		
		ALTER INDEX PK_ProviderCluster ON src.ProviderCluster REBUILD WITH(STATISTICS_INCREMENTAL = ON);

	END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_ProviderCluster'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_ProviderCluster ON src.ProviderCluster REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.ProviderNetworkEventLog', 'U') IS NULL
BEGIN
CREATE TABLE src.ProviderNetworkEventLog(
	OdsPostingGroupAuditId int NOT NULL,
	OdsCustomerId int NOT NULL,
	OdsCreateDate datetime2(7) NOT NULL,
	OdsSnapshotDate datetime2(7) NOT NULL,
	OdsRowIsCurrent bit NOT NULL,
	OdsHashbytesValue varbinary(8000) NULL,
	DmlOperation char(1) NOT NULL,
	IDField int NOT NULL,
	LogDate datetime NULL,
	EventId int NULL,
	ClaimIdNo int NULL,
	BillIdNo int NULL,
	UserId int NULL,
	NetworkId int NULL,
	FileName varchar(255) NULL,
	ExtraText varchar(1000) NULL,
	ProcessInfo smallint NULL,
	TieredTypeID smallint NULL,
	TierNumber smallint NULL
		) ON DP_Ods_PartitionScheme (OdsCustomerId)
		WITH (DATA_COMPRESSION = PAGE);

	ALTER TABLE src.ProviderNetworkEventLog 
	ADD CONSTRAINT PK_ProviderNetworkEventLog
	PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId,OdsCustomerId,IDField)
		WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_ProviderNetworkEventLog ON src.ProviderNetworkEventLog REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_ProviderNetworkEventLog'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_ProviderNetworkEventLog ON src.ProviderNetworkEventLog REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.ProviderNumberCriteria', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ProviderNumberCriteria
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ProviderNumberCriteriaId SMALLINT NOT NULL ,
			  ProviderNumber INT NULL ,
			  Priority TINYINT NULL ,
			  FeeScheduleTable CHAR (1) NULL ,
			  StartDate DATETIME2 (7) NULL ,
			  EndDate DATETIME2 (7) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ProviderNumberCriteria ADD 
     CONSTRAINT PK_ProviderNumberCriteria PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ProviderNumberCriteriaId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ProviderNumberCriteria ON src.ProviderNumberCriteria   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.ProviderNumberCriteriaRevenueCode', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ProviderNumberCriteriaRevenueCode
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ProviderNumberCriteriaId SMALLINT NOT NULL ,
			  RevenueCode VARCHAR (4) NOT NULL ,
			  MatchingProfileNumber TINYINT NULL ,
			  AttributeMatchTypeId TINYINT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ProviderNumberCriteriaRevenueCode ADD 
     CONSTRAINT PK_ProviderNumberCriteriaRevenueCode PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ProviderNumberCriteriaId, RevenueCode) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ProviderNumberCriteriaRevenueCode ON src.ProviderNumberCriteriaRevenueCode   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.ProviderNumberCriteriaTypeOfBill', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ProviderNumberCriteriaTypeOfBill
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ProviderNumberCriteriaId SMALLINT NOT NULL ,
			  TypeOfBill VARCHAR (4) NOT NULL ,
			  MatchingProfileNumber TINYINT NULL ,
			  AttributeMatchTypeId TINYINT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ProviderNumberCriteriaTypeOfBill ADD 
     CONSTRAINT PK_ProviderNumberCriteriaTypeOfBill PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ProviderNumberCriteriaId, TypeOfBill) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ProviderNumberCriteriaTypeOfBill ON src.ProviderNumberCriteriaTypeOfBill   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.ProviderSpecialty', 'U') IS NULL
    BEGIN
        CREATE TABLE src.ProviderSpecialty
            ( OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              ProviderId INT NOT NULL ,
              SpecialtyCode VARCHAR(50) NOT NULL               
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.ProviderSpecialty ADD 
        CONSTRAINT PK_ProviderSpecialty PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ProviderId, SpecialtyCode) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_ProviderSpecialty ON src.ProviderSpecialty REBUILD WITH(STATISTICS_INCREMENTAL = ON);
    END
GO

IF  EXISTS (SELECT  1
			FROM    sys.columns c 
					INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
			WHERE   object_id = OBJECT_ID(N'src.ProviderSpecialty')
					AND c.name = 'SpecialtyCode' 
					AND t.name = 'VARCHAR' 
					AND c.max_length = '12') 
	BEGIN
		
		IF EXISTS (
		SELECT object_id
		FROM sys.indexes
		WHERE object_id = OBJECT_ID(N'src.ProviderSpecialty')
			AND NAME = N'PK_ProviderSpecialty')
			ALTER TABLE src.ProviderSpecialty  DROP CONSTRAINT PK_ProviderSpecialty;
		
		ALTER TABLE src.ProviderSpecialty ALTER COLUMN SpecialtyCode VARCHAR(50) NOT NULL;

		ALTER TABLE src.ProviderSpecialty ADD 
        CONSTRAINT PK_ProviderSpecialty PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ProviderId, SpecialtyCode) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_ProviderSpecialty ON src.ProviderSpecialty REBUILD WITH(STATISTICS_INCREMENTAL = ON);

	END ; 
GO
IF OBJECT_ID('src.ProviderSpecialtyToProvType', 'U') IS NULL
BEGIN

CREATE TABLE src.ProviderSpecialtyToProvType(
	OdsPostingGroupAuditId INT NOT NULL,
	OdsCustomerId INT NOT NULL,
	OdsCreateDate DATETIME2(7) NOT NULL,
	OdsSnapshotDate DATETIME2(7) NOT NULL,
	OdsRowIsCurrent BIT NOT NULL,
	OdsHashbytesValue VARBINARY(8000) NULL,
	DmlOperation CHAR(1) NOT NULL,
	ProviderType VARCHAR(20) NOT NULL,
	ProviderType_Desc VARCHAR(80) NULL,
	Specialty VARCHAR(20) NOT NULL,
	Specialty_Desc VARCHAR(80) NULL,
	CreateDate DATETIME NULL,
	ModifyDate DATETIME NULL,
	LogicalDelete CHAR(1) NULL
	) ON DP_Ods_PartitionScheme (OdsCustomerId)
		WITH (DATA_COMPRESSION = PAGE);

ALTER TABLE src.ProviderSpecialtyToProvType ADD CONSTRAINT PK_ProviderSpecialtyToProvType PRIMARY KEY CLUSTERED 
(
	OdsPostingGroupAuditId ASC,
	OdsCustomerId ASC,
	ProviderType ASC,
	Specialty ASC
)WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

ALTER INDEX PK_ProviderSpecialtyToProvType ON src.ProviderSpecialtyToProvType REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
Go

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_ProviderSpecialtyToProvType'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_ProviderSpecialtyToProvType ON src.ProviderSpecialtyToProvType REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO


IF OBJECT_ID('src.Provider_ClientRef', 'U') IS NULL
    BEGIN
        CREATE TABLE src.Provider_ClientRef
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              PvdIdNo INT NOT NULL,
              ClientRefId VARCHAR(50) NULL,
              ClientRefId2 VARCHAR(100) NULL,
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Provider_ClientRef ADD 
        CONSTRAINT PK_Provider_ClientRef PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, PvdIdNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Provider_ClientRef ON src.Provider_ClientRef REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Provider_ClientRef'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Provider_ClientRef ON src.Provider_ClientRef REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

IF OBJECT_ID('src.Provider_Rendering', 'U') IS NULL
BEGIN
    CREATE TABLE src.Provider_Rendering
        (
          OdsPostingGroupAuditId INT NOT NULL ,
          OdsCustomerId INT NOT NULL ,
          OdsCreateDate DATETIME2(7) NOT NULL ,
          OdsSnapshotDate DATETIME2(7) NOT NULL ,
          OdsRowIsCurrent BIT NOT NULL ,
          OdsHashbytesValue VARBINARY(8000) NULL,
          DmlOperation CHAR(1) NOT NULL ,
          PvdIDNo INT NOT NULL ,
          RenderingAddr1 VARCHAR(55) NULL ,
          RenderingAddr2 VARCHAR(55) NULL ,
          RenderingCity VARCHAR(30) NULL ,
          RenderingState VARCHAR(2) NULL ,
          RenderingZip VARCHAR(12) NULL 
        ) ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (DATA_COMPRESSION = PAGE);

    ALTER TABLE src.Provider_Rendering ADD 
    CONSTRAINT PK_Provider_Rendering PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, PvdIDNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_Provider_Rendering ON src.Provider_Rendering REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Provider_Rendering'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Provider_Rendering ON src.Provider_Rendering REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

IF OBJECT_ID('src.ReferenceBillApcLines', 'U') IS NULL
BEGIN
	CREATE TABLE src.ReferenceBillApcLines
	(
		OdsPostingGroupAuditId INT NOT NULL ,
		OdsCustomerId INT NOT NULL ,
		OdsCreateDate DATETIME2(7) NOT NULL ,
		OdsSnapshotDate DATETIME2(7) NOT NULL ,
		OdsRowIsCurrent BIT NOT NULL ,
		OdsHashbytesValue VARBINARY(8000) NULL ,
		DmlOperation CHAR(1) NOT NULL ,
		BillIdNo INT NOT NULL,
		Line_No SMALLINT NOT NULL,
		PaymentAPC VARCHAR(5) NULL,
		ServiceIndicator VARCHAR(2) NULL,
		PaymentIndicator VARCHAR(1) NULL,
		OutlierAmount DECIMAL(19,4) NULL,
		PricerAllowed DECIMAL(19,4) NULL,
		MedicareAmount DECIMAL(19,4) NULL
	)ON DP_Ods_PartitionScheme(OdsCustomerId)
		WITH (
		DATA_COMPRESSION = PAGE);
		
	ALTER TABLE src.ReferenceBillApcLines
	ADD CONSTRAINT PK_ReferenceBillApcLines
	PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIdNo, Line_No)
	WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);
	
	ALTER INDEX PK_ReferenceBillApcLines ON src.ReferenceBillApcLines REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END

GO

IF OBJECT_ID('src.ReferenceSupplementBillApcLines', 'U') IS NULL
BEGIN
	CREATE TABLE src.ReferenceSupplementBillApcLines (
		OdsPostingGroupAuditId INT NOT NULL ,
		OdsCustomerId INT NOT NULL ,
		OdsCreateDate DATETIME2(7) NOT NULL ,
		OdsSnapshotDate DATETIME2(7) NOT NULL ,
		OdsRowIsCurrent BIT NOT NULL ,
		OdsHashbytesValue VARBINARY(8000) NULL ,
		DmlOperation CHAR(1) NOT NULL ,
		BillIdNo INT NOT NULL,
		SeqNo SMALLINT NOT NULL,
		Line_No SMALLINT NOT NULL,
		PaymentAPC VARCHAR(5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		ServiceIndicator VARCHAR(2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		PaymentIndicator VARCHAR(1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		OutlierAmount DECIMAL(19,4) NULL,
		PricerAllowed DECIMAL(19,4) NULL,
		MedicareAmount DECIMAL(19,4) NULL	
		)ON DP_Ods_PartitionScheme(OdsCustomerId)
		WITH (
		DATA_COMPRESSION = PAGE);


	ALTER TABLE src.ReferenceSupplementBillApcLines ADD CONSTRAINT PK_ReferenceSupplementBillApcLines PRIMARY KEY CLUSTERED (
		OdsPostingGroupAuditId, 
		OdsCustomerId, 
		BillIdNo,
		SeqNo,
		Line_No
		)WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_ReferenceSupplementBillApcLines ON src.ReferenceSupplementBillApcLines REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END

GO
IF OBJECT_ID('src.RenderingNpiStates', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.RenderingNpiStates
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ApplicationSettingsId INT NOT NULL ,
			  State VARCHAR (2) NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.RenderingNpiStates ADD 
     CONSTRAINT PK_RenderingNpiStates PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ApplicationSettingsId, State) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_RenderingNpiStates ON src.RenderingNpiStates   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.RevenueCode', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.RevenueCode
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  RevenueCode VARCHAR (4) NOT NULL ,
			  RevenueCodeSubCategoryId TINYINT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.RevenueCode ADD 
     CONSTRAINT PK_RevenueCode PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, RevenueCode) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_RevenueCode ON src.RevenueCode   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.RevenueCodeCategory', 'U') IS NULL
BEGIN
	CREATE TABLE src.RevenueCodeCategory
		(
			OdsPostingGroupAuditId INT NOT NULL ,
			OdsCustomerId INT NOT NULL , 
			OdsCreateDate DATETIME2(7) NOT NULL ,
			OdsSnapshotDate DATETIME2(7) NOT NULL ,
			OdsRowIsCurrent BIT NOT NULL ,
			OdsHashbytesValue VARBINARY(8000) NULL,
			DmlOperation CHAR(1) NOT NULL ,
			RevenueCodeCategoryId TINYINT NOT NULL,
			Description VARCHAR(100) NULL,
			NarrativeInformation VARCHAR(1000) NULL

			)ON DP_Ods_PartitionScheme(OdsCustomerId)
						WITH (
						 DATA_COMPRESSION = PAGE);

		ALTER TABLE src.RevenueCodeCategory ADD 
		CONSTRAINT PK_RevenueCodeCategory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,RevenueCodeCategoryId ASC) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_RevenueCodeCategory ON src.RevenueCodeCategory REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO
IF OBJECT_ID('src.RevenueCodeSubcategory', 'U') IS NULL
	BEGIN
		CREATE TABLE src.RevenueCodeSubcategory
			(
			OdsPostingGroupAuditId INT NOT NULL ,
			OdsCustomerId INT NOT NULL ,
			OdsCreateDate DATETIME2(7) NOT NULL ,
			OdsSnapshotDate DATETIME2(7) NOT NULL ,
			OdsRowIsCurrent BIT NOT NULL ,
			OdsHashbytesValue VARBINARY(8000) NULL ,
			DmlOperation CHAR(1) NOT NULL ,
			RevenueCodeSubcategoryId TINYINT NOT NULL,
			RevenueCodeCategoryId TINYINT NULL,
			Description VARCHAR(100) NULL,
			NarrativeInformation VARCHAR(1000) NULL
			)ON DP_Ods_PartitionScheme(OdsCustomerId)
						WITH (
							 DATA_COMPRESSION = PAGE);

		ALTER TABLE src.RevenueCodeSubcategory ADD 
		CONSTRAINT PK_RevenueCodeSubcategory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, RevenueCodeSubcategoryId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_RevenueCodeSubcategory ON src.RevenueCodeSubcategory REBUILD WITH(STATISTICS_INCREMENTAL = ON);
	END
GO
IF OBJECT_ID('src.RPT_RsnCategories', 'U') IS NULL
    BEGIN
        CREATE TABLE src.RPT_RsnCategories
            (
			OdsPostingGroupAuditId INT NOT NULL ,
			OdsCustomerId INT NOT NULL ,
			OdsCreateDate DATETIME2(7) NOT NULL ,
			OdsSnapshotDate DATETIME2(7) NOT NULL ,
			OdsRowIsCurrent BIT NOT NULL ,
			OdsHashbytesValue VARBINARY(8000) NULL ,
			DmlOperation CHAR(1) NOT NULL ,
			CategoryIdNo SMALLINT NOT NULL,
			CatDesc VARCHAR(50) NULL,
			Priority SMALLINT NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.RPT_RsnCategories ADD 
        CONSTRAINT PK_RPT_RsnCategories PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, CategoryIdNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_RPT_RsnCategories ON src.RPT_RsnCategories REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_RPT_RsnCategories'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_RPT_RsnCategories ON src.RPT_RsnCategories REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.rsn_Override', 'U') IS NULL
BEGIN
	CREATE TABLE src.rsn_Override (
		OdsPostingGroupAuditId INT NOT NULL
		,OdsCustomerId INT NOT NULL
		,OdsCreateDate DATETIME2(7) NOT NULL
		,OdsSnapshotDate DATETIME2(7) NOT NULL
		,OdsRowIsCurrent BIT NOT NULL
		,OdsHashbytesValue VARBINARY(8000) NULL
		,DmlOperation CHAR(1) NOT NULL
		,ReasonNumber INT NOT NULL
		,ShortDesc VARCHAR(50) NULL
		,LongDesc VARCHAR(max) NULL
		,CategoryIdNo SMALLINT NULL
		,ClientSpec SMALLINT NULL
		,COAIndex SMALLINT NULL
		,NJPenaltyPct DECIMAL(9, 6) NULL
		,NetworkID INT NULL
		,SpecialProcessing BIT NULL
		) ON DP_Ods_PartitionScheme (OdsCustomerId)
		WITH (DATA_COMPRESSION = PAGE);

	ALTER TABLE src.rsn_Override ADD CONSTRAINT PK_rsn_Override PRIMARY KEY CLUSTERED (
		OdsPostingGroupAuditId
		,OdsCustomerId
		,ReasonNumber
		)
		WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_rsn_Override ON src.rsn_Override REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_rsn_Override'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_rsn_Override ON src.rsn_Override REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.rsn_REASONS', 'U') IS NULL
    BEGIN
        CREATE TABLE src.rsn_REASONS
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              ReasonNumber INT NOT NULL ,
              CV_Type VARCHAR(2) NULL ,
              ShortDesc VARCHAR(50) NULL ,
              LongDesc VARCHAR(MAX) NULL ,
              CategoryIdNo INT NULL ,
              COAIndex SMALLINT NULL ,
              OverrideEndnote INT NULL ,
              HardEdit SMALLINT NULL ,
              SpecialProcessing BIT NULL ,
              EndnoteActionId TINYINT NULL ,
              RetainForEapg BIT NULL
            )
        ON  DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.rsn_REASONS ADD 
        CONSTRAINT PK_rsn_REASONS PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ReasonNumber) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_rsn_REASONS ON src.rsn_REASONS REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END;
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.rsn_REASONS')
                        AND NAME = 'EndnoteActionId' )
    BEGIN
        ALTER TABLE src.rsn_REASONS ADD EndnoteActionId TINYINT NULL;
    END;
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.rsn_REASONS')
                        AND NAME = 'RetainForEapg' )
    BEGIN
        ALTER TABLE src.rsn_REASONS ADD RetainForEapg BIT NULL;
    END;
GO

IF EXISTS ( SELECT  1
            FROM    sys.columns c
                    INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
            WHERE   c.object_id = OBJECT_ID(N'src.rsn_REASONS')
                    AND c.name = 'ShortDesc'
                    AND NOT ( t.name = 'VARCHAR'
                              AND c.max_length = 50
                            ) )
    BEGIN
        ALTER TABLE src.rsn_REASONS ALTER COLUMN ShortDesc VARCHAR(50) NULL;
    END;
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_rsn_REASONS'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_rsn_REASONS ON src.rsn_REASONS REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

IF OBJECT_ID ('src.Rsn_Reasons_3rdParty', 'U') IS NULL
	BEGIN
		CREATE TABLE src.Rsn_Reasons_3rdParty
			(
			  OdsPostingGroupAuditId INT NOT NULL ,
			  OdsCustomerId INT NOT NULL ,
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL ,
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,
			  ReasonNumber INT NOT NULL,
			  ShortDesc VARCHAR(50) NULL,
			  LongDesc VARCHAR(MAX) NULL
			)
		ON DP_Ods_PartitionScheme(OdsCustomerId)
			WITH (
				DATA_COMPRESSION = PAGE);

		ALTER TABLE src.Rsn_Reasons_3rdParty ADD 
		CONSTRAINT PK_Rsn_Reasons_3rdParty PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ReasonNumber) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);


		ALTER INDEX PK_Rsn_Reasons_3rdParty ON src.Rsn_Reasons_3rdParty REBUILD WITH(STATISTICS_INCREMENTAL = ON);

	END
GO
IF OBJECT_ID('src.RuleType', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.RuleType
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  RuleTypeID INT NOT NULL ,
			  Name VARCHAR (50) NULL ,
			  Description VARCHAR (150) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.RuleType ADD 
     CONSTRAINT PK_RuleType PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, RuleTypeID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_RuleType ON src.RuleType   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.ScriptAdvisorBillSource', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ScriptAdvisorBillSource
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  BillSourceId TINYINT NOT NULL ,
			  BillSource VARCHAR (15) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ScriptAdvisorBillSource ADD 
     CONSTRAINT PK_ScriptAdvisorBillSource PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillSourceId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ScriptAdvisorBillSource ON src.ScriptAdvisorBillSource   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.ScriptAdvisorSettings', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ScriptAdvisorSettings
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ScriptAdvisorSettingsId TINYINT NOT NULL ,
			  IsPharmacyEligible BIT NULL ,
			  EnableSendCardToClaimant BIT NULL ,
			  EnableBillSource BIT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ScriptAdvisorSettings ADD 
     CONSTRAINT PK_ScriptAdvisorSettings PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ScriptAdvisorSettingsId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ScriptAdvisorSettings ON src.ScriptAdvisorSettings   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.ScriptAdvisorSettingsCoverageType', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ScriptAdvisorSettingsCoverageType
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ScriptAdvisorSettingsId TINYINT NOT NULL ,
			  CoverageType VARCHAR (2) NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ScriptAdvisorSettingsCoverageType ADD 
     CONSTRAINT PK_ScriptAdvisorSettingsCoverageType PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ScriptAdvisorSettingsId, CoverageType) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ScriptAdvisorSettingsCoverageType ON src.ScriptAdvisorSettingsCoverageType   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.SEC_RightGroups', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.SEC_RightGroups
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  RightGroupId INT NOT NULL ,
			  RightGroupName VARCHAR (50) NULL ,
			  RightGroupDescription VARCHAR (150) NULL ,
			  CreatedDate DATETIME NULL ,
			  CreatedBy VARCHAR (50) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.SEC_RightGroups ADD 
     CONSTRAINT PK_SEC_RightGroups PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, RightGroupId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_SEC_RightGroups ON src.SEC_RightGroups   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.SEC_Users', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.SEC_Users
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  UserId INT NOT NULL ,
			  LoginName VARCHAR (15) NULL ,
			  Password VARCHAR (30) NULL ,
			  CreatedBy VARCHAR (50) NULL ,
			  CreatedDate DATETIME NULL ,
			  UserStatus INT NULL ,
			  FirstName VARCHAR (20) NULL ,
			  LastName VARCHAR (20) NULL ,
			  AccountLocked SMALLINT NULL ,
			  LockedCounter SMALLINT NULL ,
			  PasswordCreateDate DATETIME NULL ,
			  PasswordCaseFlag SMALLINT NULL ,
			  ePassword VARCHAR (30) NULL ,
			  CurrentSettings VARCHAR (MAX) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.SEC_Users ADD 
     CONSTRAINT PK_SEC_Users PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, UserId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_SEC_Users ON src.SEC_Users   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.SEC_User_OfficeGroups', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.SEC_User_OfficeGroups
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  SECUserOfficeGroupId INT NOT NULL ,
			  UserId INT NULL ,
			  OffcGroupId INT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.SEC_User_OfficeGroups ADD 
     CONSTRAINT PK_SEC_User_OfficeGroups PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, SECUserOfficeGroupId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_SEC_User_OfficeGroups ON src.SEC_User_OfficeGroups   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.SEC_User_RightGroups', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.SEC_User_RightGroups
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  SECUserRightGroupId INT NOT NULL ,
			  UserId INT NULL ,
			  RightGroupId INT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.SEC_User_RightGroups ADD 
     CONSTRAINT PK_SEC_User_RightGroups PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, SECUserRightGroupId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_SEC_User_RightGroups ON src.SEC_User_RightGroups   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.SentryRuleTypeCriteria', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.SentryRuleTypeCriteria
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  RuleTypeId INT NOT NULL ,
			  CriteriaId INT NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.SentryRuleTypeCriteria ADD 
     CONSTRAINT PK_SentryRuleTypeCriteria PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, RuleTypeId, CriteriaId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_SentryRuleTypeCriteria ON src.SentryRuleTypeCriteria   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.SENTRY_ACTION', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.SENTRY_ACTION
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ActionID INT NOT NULL ,
			  Name VARCHAR (50) NULL ,
			  Description VARCHAR (100) NULL ,
			  CompatibilityKey VARCHAR (50) NULL ,
			  PredefinedValues VARCHAR (MAX) NULL ,
			  ValueDataType VARCHAR (50) NULL ,
			  ValueFormat VARCHAR (250) NULL ,
			  BillLineAction INT NULL ,
			  AnalyzeFlag SMALLINT NULL ,
			  ActionCategoryIDNo INT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.SENTRY_ACTION ADD 
     CONSTRAINT PK_SENTRY_ACTION PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ActionID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_SENTRY_ACTION ON src.SENTRY_ACTION   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.SENTRY_ACTION_CATEGORY', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.SENTRY_ACTION_CATEGORY
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ActionCategoryIDNo INT NOT NULL ,
			  Description VARCHAR (60) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.SENTRY_ACTION_CATEGORY ADD 
     CONSTRAINT PK_SENTRY_ACTION_CATEGORY PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ActionCategoryIDNo) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_SENTRY_ACTION_CATEGORY ON src.SENTRY_ACTION_CATEGORY   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.SENTRY_CRITERIA', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.SENTRY_CRITERIA
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  CriteriaID INT NOT NULL ,
			  ParentName VARCHAR (50) NULL ,
			  Name VARCHAR (50) NULL ,
			  Description VARCHAR (150) NULL ,
			  Operators VARCHAR (50) NULL ,
			  PredefinedValues VARCHAR (MAX) NULL ,
			  ValueDataType VARCHAR (50) NULL ,
			  ValueFormat VARCHAR (250) NULL ,
			  NullAllowed SMALLINT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.SENTRY_CRITERIA ADD 
     CONSTRAINT PK_SENTRY_CRITERIA PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, CriteriaID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_SENTRY_CRITERIA ON src.SENTRY_CRITERIA   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.SENTRY_PROFILE_RULE', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.SENTRY_PROFILE_RULE
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ProfileID INT NOT NULL ,
			  RuleID INT NOT NULL ,
			  Priority INT NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.SENTRY_PROFILE_RULE ADD 
     CONSTRAINT PK_SENTRY_PROFILE_RULE PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ProfileID, RuleID, Priority) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_SENTRY_PROFILE_RULE ON src.SENTRY_PROFILE_RULE   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.SENTRY_RULE', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.SENTRY_RULE
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  RuleID INT NOT NULL ,
			  Name VARCHAR (50) NULL ,
			  Description VARCHAR (MAX) NULL ,
			  CreatedBy VARCHAR (50) NULL ,
			  CreationDate DATETIME NULL ,
			  PostFixNotation VARCHAR (MAX) NULL ,
			  Priority INT NULL ,
			  RuleTypeID SMALLINT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.SENTRY_RULE ADD 
     CONSTRAINT PK_SENTRY_RULE PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, RuleID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_SENTRY_RULE ON src.SENTRY_RULE   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.SENTRY_RULE_ACTION_DETAIL', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.SENTRY_RULE_ACTION_DETAIL
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  RuleID INT NOT NULL ,
			  LineNumber INT NOT NULL ,
			  ActionID INT NULL ,
			  ActionValue VARCHAR (1000) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.SENTRY_RULE_ACTION_DETAIL ADD 
     CONSTRAINT PK_SENTRY_RULE_ACTION_DETAIL PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, RuleID, LineNumber) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_SENTRY_RULE_ACTION_DETAIL ON src.SENTRY_RULE_ACTION_DETAIL   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.SENTRY_RULE_ACTION_HEADER', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.SENTRY_RULE_ACTION_HEADER
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  RuleID INT NOT NULL ,
			  EndnoteShort VARCHAR (50) NULL ,
			  EndnoteLong VARCHAR (MAX) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.SENTRY_RULE_ACTION_HEADER ADD 
     CONSTRAINT PK_SENTRY_RULE_ACTION_HEADER PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, RuleID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_SENTRY_RULE_ACTION_HEADER ON src.SENTRY_RULE_ACTION_HEADER   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.SENTRY_RULE_CONDITION', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.SENTRY_RULE_CONDITION
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  RuleID INT NOT NULL ,
			  LineNumber INT NOT NULL ,
			  GroupFlag VARCHAR (50) NULL ,
			  CriteriaID INT NULL ,
			  Operator VARCHAR (50) NULL ,
			  ConditionValue VARCHAR (60) NULL ,
			  AndOr VARCHAR (50) NULL ,
			  UdfConditionId INT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.SENTRY_RULE_CONDITION ADD 
     CONSTRAINT PK_SENTRY_RULE_CONDITION PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, RuleID, LineNumber) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_SENTRY_RULE_CONDITION ON src.SENTRY_RULE_CONDITION   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.SPECIALTY', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.SPECIALTY
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  SpcIdNo INT NULL ,
			  Code VARCHAR (50) NOT NULL ,
			  Description VARCHAR (70) NULL ,
			  PayeeSubTypeID INT NULL ,
			  TieredTypeID SMALLINT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.SPECIALTY ADD 
     CONSTRAINT PK_SPECIALTY PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Code) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_SPECIALTY ON src.SPECIALTY   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.StateSettingMedicare', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.StateSettingMedicare
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  StateSettingMedicareId INT NOT NULL ,
			  PayPercentOfMedicareFee BIT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.StateSettingMedicare ADD 
     CONSTRAINT PK_StateSettingMedicare PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, StateSettingMedicareId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_StateSettingMedicare ON src.StateSettingMedicare   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.StateSettingsFlorida', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.StateSettingsFlorida
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  StateSettingsFloridaId INT NOT NULL ,
			  ClaimantInitialServiceOption SMALLINT NULL ,
			  ClaimantInitialServiceDays SMALLINT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.StateSettingsFlorida ADD 
     CONSTRAINT PK_StateSettingsFlorida PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, StateSettingsFloridaId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_StateSettingsFlorida ON src.StateSettingsFlorida   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.StateSettingsHawaii', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.StateSettingsHawaii
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  StateSettingsHawaiiId INT NOT NULL ,
			  PhysicalMedicineLimitOption SMALLINT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.StateSettingsHawaii ADD 
     CONSTRAINT PK_StateSettingsHawaii PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, StateSettingsHawaiiId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_StateSettingsHawaii ON src.StateSettingsHawaii   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.StateSettingsNewJersey', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.StateSettingsNewJersey
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  StateSettingsNewJerseyId INT NOT NULL ,
			  ByPassEmergencyServices BIT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.StateSettingsNewJersey ADD 
     CONSTRAINT PK_StateSettingsNewJersey PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, StateSettingsNewJerseyId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_StateSettingsNewJersey ON src.StateSettingsNewJersey   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.StateSettingsNewJerseyPolicyPreference', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.StateSettingsNewJerseyPolicyPreference
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  PolicyPreferenceId INT NOT NULL ,
			  ShareCoPayMaximum BIT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.StateSettingsNewJerseyPolicyPreference ADD 
     CONSTRAINT PK_StateSettingsNewJerseyPolicyPreference PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, PolicyPreferenceId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_StateSettingsNewJerseyPolicyPreference ON src.StateSettingsNewJerseyPolicyPreference   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.StateSettingsNewYorkPolicyPreference', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.StateSettingsNewYorkPolicyPreference
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  PolicyPreferenceId INT NOT NULL ,
			  ShareCoPayMaximum BIT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.StateSettingsNewYorkPolicyPreference ADD 
     CONSTRAINT PK_StateSettingsNewYorkPolicyPreference PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, PolicyPreferenceId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_StateSettingsNewYorkPolicyPreference ON src.StateSettingsNewYorkPolicyPreference   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.StateSettingsNY', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.StateSettingsNY
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  StateSettingsNYID INT NOT NULL ,
			  NF10PrintDate BIT NULL ,
			  NF10CheckBox1 BIT NULL ,
			  NF10CheckBox18 BIT NULL ,
			  NF10UseUnderwritingCompany BIT NULL ,
			  UnderwritingCompanyUdfId INT NULL ,
			  NaicUdfId INT NULL ,
			  DisplayNYPrintOptionsWhenZosOrSojIsNY BIT NULL ,
			  NF10DuplicatePrint BIT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.StateSettingsNY ADD 
     CONSTRAINT PK_StateSettingsNY PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, StateSettingsNYID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_StateSettingsNY ON src.StateSettingsNY   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.StateSettingsNyRoomRate', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.StateSettingsNyRoomRate
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  StateSettingsNyRoomRateId INT NOT NULL ,
			  StartDate DATETIME NULL ,
			  EndDate DATETIME NULL ,
			  RoomRate MONEY NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.StateSettingsNyRoomRate ADD 
     CONSTRAINT PK_StateSettingsNyRoomRate PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, StateSettingsNyRoomRateId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_StateSettingsNyRoomRate ON src.StateSettingsNyRoomRate   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO

IF OBJECT_ID('src.StateSettingsOregon', 'U') IS NULL
    BEGIN
        CREATE TABLE src.StateSettingsOregon
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  StateSettingsOregonId TINYINT NOT NULL,
			  ApplyOregonFeeSchedule BIT NULL
              
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.StateSettingsOregon ADD 
        CONSTRAINT PK_StateSettingsOregon PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, StateSettingsOregonId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_StateSettingsOregon ON src.StateSettingsOregon REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO


IF OBJECT_ID('src.StateSettingsOregonCoverageType', 'U') IS NULL
    BEGIN
        CREATE TABLE src.StateSettingsOregonCoverageType
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  StateSettingsOregonId TINYINT NOT NULL,
			  CoverageType VARCHAR(2) NOT NULL
              
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.StateSettingsOregonCoverageType ADD 
        CONSTRAINT PK_StateSettingsOregonCoverageType PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, StateSettingsOregonId, CoverageType) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_StateSettingsOregonCoverageType ON src.StateSettingsOregonCoverageType REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

IF OBJECT_ID('src.SupplementBillApportionmentEndnote', 'U') IS NULL
    BEGIN
        CREATE TABLE src.SupplementBillApportionmentEndnote
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              BillId INT NOT NULL,
			  SequenceNumber SMALLINT NOT NULL,
              LineNumber SMALLINT NOT NULL,
              Endnote INT NOT NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.SupplementBillApportionmentEndnote ADD 
        CONSTRAINT PK_SupplementBillApportionmentEndnote PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillId , SequenceNumber, LineNumber, Endnote) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_SupplementBillApportionmentEndnote ON src.SupplementBillApportionmentEndnote REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

IF OBJECT_ID('src.SupplementBillCustomEndnote', 'U') IS NULL
    BEGIN
        CREATE TABLE src.SupplementBillCustomEndnote
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              BillId INT NOT NULL,
			  SequenceNumber SMALLINT NOT NULL ,
              LineNumber SMALLINT NOT NULL,
              Endnote INT NOT NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.SupplementBillCustomEndnote ADD 
        CONSTRAINT PK_SupplementBillCustomEndnote PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillId, SequenceNumber, LineNumber, Endnote) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_SupplementBillCustomEndnote ON src.SupplementBillCustomEndnote REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO



IF OBJECT_ID('src.SupplementBill_Pharm_ApportionmentEndnote', 'U') IS NULL
    BEGIN
        CREATE TABLE src.SupplementBill_Pharm_ApportionmentEndnote
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              BillId INT NOT NULL,
			  SequenceNumber SMALLINT NOT NULL,
              LineNumber SMALLINT NOT NULL,
              Endnote INT NOT NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.SupplementBill_Pharm_ApportionmentEndnote ADD 
        CONSTRAINT PK_SupplementBill_Pharm_ApportionmentEndnote PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillId , SequenceNumber, LineNumber, Endnote) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_SupplementBill_Pharm_ApportionmentEndnote ON src.SupplementBill_Pharm_ApportionmentEndnote REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO
IF OBJECT_ID('src.SupplementPreCtgDeniedLinesEligibleToPenalty', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.SupplementPreCtgDeniedLinesEligibleToPenalty
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  BillIdNo INT NOT NULL ,
			  LineNumber SMALLINT NOT NULL ,
			  CtgPenaltyTypeId TINYINT NOT NULL ,
			  SeqNo SMALLINT NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.SupplementPreCtgDeniedLinesEligibleToPenalty ADD 
     CONSTRAINT PK_SupplementPreCtgDeniedLinesEligibleToPenalty PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIdNo, LineNumber, CtgPenaltyTypeId, SeqNo) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_SupplementPreCtgDeniedLinesEligibleToPenalty ON src.SupplementPreCtgDeniedLinesEligibleToPenalty   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.SurgicalModifierException', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.SurgicalModifierException
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  Modifier VARCHAR (2) NOT NULL ,
			  State VARCHAR (2) NOT NULL ,
			  CoverageType VARCHAR (2) NOT NULL ,
			  StartDate DATETIME2 (7) NOT NULL ,
			  EndDate DATETIME2 (7) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.SurgicalModifierException ADD 
     CONSTRAINT PK_SurgicalModifierException PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Modifier, State, CoverageType, StartDate) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_SurgicalModifierException ON src.SurgicalModifierException   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.Tag', 'U') IS NULL
    BEGIN
        CREATE TABLE src.Tag
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  TagId int NOT NULL,
	          NAME varchar(50) NULL,
	          DateCreated datetimeoffset(7) NULL,
	          DateModified datetimeoffset(7) NULL,
	          CreatedBy varchar(15) NULL,
	          ModifiedBy varchar(15) NULL
	          
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Tag ADD 
        CONSTRAINT PK_Tag PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,TagId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Tag ON src.Tag REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Tag'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Tag ON src.Tag REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.TreatmentCategory', 'U') IS NULL
    BEGIN
        CREATE TABLE src.TreatmentCategory
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  TreatmentCategoryId tinyint NOT NULL,
	          Category varchar(50) NULL,
	          Metadata nvarchar(max) NULL
	          
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.TreatmentCategory ADD 
        CONSTRAINT PK_TreatmentCategoryId PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,TreatmentCategoryId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_TreatmentCategoryId ON src.TreatmentCategory REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_TreatmentCategoryId'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_TreatmentCategoryId ON src.TreatmentCategory REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.TreatmentCategoryRange', 'U') IS NULL
    BEGIN
        CREATE TABLE src.TreatmentCategoryRange
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  TreatmentCategoryRangeId int NOT NULL,
	          TreatmentCategoryId tinyint NULL,
	          StartRange varchar(7) NULL,
	          EndRange varchar(7) NULL
	          
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.TreatmentCategoryRange ADD 
        CONSTRAINT PK_TreatmentCategoryRangeId PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,TreatmentCategoryRangeId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_TreatmentCategoryRangeId ON src.TreatmentCategoryRange REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_TreatmentCategoryRangeId'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_TreatmentCategoryRangeId ON src.TreatmentCategoryRange REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.Ub_Apc_Dict', 'U') IS NULL
    BEGIN
        CREATE TABLE src.Ub_Apc_Dict
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              StartDate DATETIME NOT NULL ,
              EndDate DATETIME NULL ,
              APC VARCHAR(5) NOT NULL ,
              Description VARCHAR(255) NULL
              
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Ub_Apc_Dict ADD 
        CONSTRAINT PK_Ub_Apc_Dict PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, APC, StartDate) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Ub_Apc_Dict ON src.Ub_Apc_Dict REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Ub_Apc_Dict'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Ub_Apc_Dict ON src.Ub_Apc_Dict REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.UB_BillType', 'U') IS NULL
    BEGIN
        CREATE TABLE src.UB_BillType
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              TOB VARCHAR(4) NOT NULL ,
              Description VARCHAR(MAX) NULL ,
              Flag INT NULL ,
              UB_BillTypeID INT NULL 
              
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.UB_BillType ADD 
        CONSTRAINT PK_UB_BillType PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, TOB) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_UB_BillType ON src.UB_BillType REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_UB_BillType'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_UB_BillType ON src.UB_BillType REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.UB_RevenueCodes', 'U') IS NULL
    BEGIN
        CREATE TABLE src.UB_RevenueCodes
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL , 
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              RevenueCode VARCHAR(4) NOT NULL,
			  StartDate DATETIME NOT NULL,
			  EndDate DATETIME NULL,
			  PRC_DESC VARCHAR(MAX) NULL,
			  Flags INT NULL,
			  Vague VARCHAR(1) NULL,
			  PerVisit SMALLINT NULL,
			  PerClaimant SMALLINT NULL,
			  PerProvider SMALLINT NULL,
			  BodyFlags INT NULL,
			  DrugFlag SMALLINT NULL,
			  CurativeFlag SMALLINT NULL,
			  RevenueCodeSubCategoryId TINYINT NULL
             
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.UB_RevenueCodes ADD 
        CONSTRAINT PK_UB_RevenueCodes PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, RevenueCode, StartDate) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_UB_RevenueCodes ON src.UB_RevenueCodes REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.UB_RevenueCodes')
                        AND NAME = 'RevenueCodeSubCategoryId' )
    BEGIN
        ALTER TABLE src.UB_RevenueCodes ADD RevenueCodeSubCategoryId TINYINT NULL;
    END;
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_UB_RevenueCodes'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_UB_RevenueCodes ON src.UB_RevenueCodes REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO


IF OBJECT_ID('src.UDFBill', 'U') IS NULL
BEGIN
    CREATE TABLE src.UDFBill
        (
          OdsPostingGroupAuditId INT NOT NULL ,
          OdsCustomerId INT NOT NULL ,
          OdsCreateDate DATETIME2(7) NOT NULL ,
          OdsSnapshotDate DATETIME2(7) NOT NULL ,
          OdsRowIsCurrent BIT NOT NULL ,
          OdsHashbytesValue VARBINARY(8000) NULL,
          DmlOperation CHAR(1) NOT NULL ,
          BillIdNo INT NOT NULL ,
          UDFIdNo INT NOT NULL ,
          UDFValueText VARCHAR(255) NULL ,
          UDFValueDecimal DECIMAL(19, 4) NULL ,
          UDFValueDate DATETIME NULL 
        ) ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (DATA_COMPRESSION = PAGE);

    ALTER TABLE src.UDFBill ADD 
    CONSTRAINT PK_UDFBill PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIdNo, UDFIdNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_UDFBill ON src.UDFBill REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

IF EXISTS ( SELECT  *
            FROM    sys.columns c
                    INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
            WHERE   c.object_id = OBJECT_ID(N'src.UDFBill')
                    AND c.name = 'UDFValueDecimal'
                    AND NOT ( t.name = 'DECIMAL'
                              AND c.precision = 19 AND c.scale = 4
                            ) )
    BEGIN
        ALTER TABLE src.UDFBill ALTER COLUMN UDFValueDecimal DECIMAL(19, 4) NULL;
    END;
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_UDFBill'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_UDFBill ON src.UDFBill REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

IF OBJECT_ID('src.UDFClaim', 'U') IS  NULL
BEGIN
    CREATE TABLE src.UDFClaim
        (
          OdsPostingGroupAuditId INT NOT NULL ,
          OdsCustomerId INT NOT NULL ,
          OdsCreateDate DATETIME2(7) NOT NULL ,
          OdsSnapshotDate DATETIME2(7) NOT NULL ,
          OdsRowIsCurrent BIT NOT NULL ,
          OdsHashbytesValue VARBINARY(8000) NULL,
          DmlOperation CHAR(1) NOT NULL ,
          ClaimIdNo INT NOT NULL ,
          UDFIdNo INT NOT NULL ,
          UDFValueText VARCHAR(255) NULL ,
          UDFValueDecimal DECIMAL(19, 4) NULL ,
          UDFValueDate DATETIME NULL 
        ) ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (DATA_COMPRESSION = PAGE);

    ALTER TABLE src.UDFClaim ADD 
    CONSTRAINT PK_UDFClaim PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClaimIdNo, UDFIdNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_UDFClaim ON src.UDFClaim REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

IF EXISTS ( SELECT  *
            FROM    sys.columns c
                    INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
            WHERE   c.object_id = OBJECT_ID(N'src.UDFClaim')
                    AND c.name = 'UDFValueDecimal'
                    AND NOT ( t.name = 'DECIMAL'
                              AND c.precision = 19 AND c.scale = 4
                            ) )
    BEGIN
        ALTER TABLE src.UDFClaim ALTER COLUMN UDFValueDecimal DECIMAL(19, 4) NULL;
    END;
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_UDFClaim'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_UDFClaim ON src.UDFClaim REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

IF OBJECT_ID('src.UDFClaimant', 'U') IS NULL
BEGIN
    CREATE TABLE src.UDFClaimant
        (
          OdsPostingGroupAuditId INT NOT NULL ,
          OdsCustomerId INT NOT NULL ,
          OdsCreateDate DATETIME2(7) NOT NULL ,
          OdsSnapshotDate DATETIME2(7) NOT NULL ,
          OdsRowIsCurrent BIT NOT NULL ,
          OdsHashbytesValue VARBINARY(8000) NULL,
          DmlOperation CHAR(1) NOT NULL ,
          CmtIdNo INT NOT NULL ,
          UDFIdNo INT NOT NULL ,
          UDFValueText VARCHAR(255) NULL ,
          UDFValueDecimal DECIMAL(19, 4) NULL ,
          UDFValueDate DATETIME NULL 
        ) ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (DATA_COMPRESSION = PAGE);

    ALTER TABLE src.UDFClaimant ADD 
    CONSTRAINT PK_UDFClaimant PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, CmtIdNo, UDFIdNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_UDFClaimant ON src.UDFClaimant REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

IF EXISTS ( SELECT  *
            FROM    sys.columns c
                    INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
            WHERE   c.object_id = OBJECT_ID(N'src.UDFClaimant')
                    AND c.name = 'UDFValueDecimal'
                    AND NOT ( t.name = 'DECIMAL'
                              AND c.precision = 19 AND c.scale = 4
                            ) )
    BEGIN
        ALTER TABLE src.UDFClaimant ALTER COLUMN UDFValueDecimal DECIMAL(19, 4) NULL;
    END;
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_UDFClaimant'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_UDFClaimant ON src.UDFClaimant REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

IF OBJECT_ID('src.UdfDataFormat', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.UdfDataFormat
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  UdfDataFormatId SMALLINT NOT NULL ,
			  DataFormatName VARCHAR (30) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.UdfDataFormat ADD 
     CONSTRAINT PK_UdfDataFormat PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, UdfDataFormatId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_UdfDataFormat ON src.UdfDataFormat   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO

IF OBJECT_ID('src.UDFLevelChangeTracking', 'U') IS NULL
    BEGIN
        CREATE TABLE src.UDFLevelChangeTracking
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  UDFLevelChangeTrackingId INT NOT NULL,
			  EntityType INT NULL,
			  EntityId INT NULL,
			  CorrelationId VARCHAR(50) NULL,
			  UDFId INT NULL,  
			  PreviousValue VARCHAR(MAX) NULL,
			  UpdatedValue VARCHAR(MAX) NULL,
              UserId INT NULL,
			  ChangeDate DATETIME2 NULL              
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.UDFLevelChangeTracking ADD 
        CONSTRAINT PK_UDFLevelChangeTracking PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, UDFLevelChangeTrackingId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_UDFLevelChangeTracking ON src.UDFLevelChangeTracking REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO
IF OBJECT_ID('src.UDFLibrary', 'U') IS NULL
BEGIN
    CREATE TABLE src.UDFLibrary
        (
          OdsPostingGroupAuditId INT NOT NULL ,
          OdsCustomerId INT NOT NULL ,
          OdsCreateDate DATETIME2(7) NOT NULL ,
          OdsSnapshotDate DATETIME2(7) NOT NULL ,
          OdsRowIsCurrent BIT NOT NULL ,
          OdsHashbytesValue VARBINARY(8000) NULL,
          DmlOperation CHAR(1) NOT NULL ,
          UDFIdNo INT NOT NULL ,
          UDFName VARCHAR(50) NULL ,
          ScreenType SMALLINT NULL ,
          UDFDescription VARCHAR(1000) NULL ,
          DataFormat SMALLINT NULL ,
          RequiredField SMALLINT NULL ,
          ReadOnly SMALLINT NULL ,
          Invisible SMALLINT NULL ,
          TextMaxLength SMALLINT NULL ,
          TextMask VARCHAR(50) NULL ,
          TextEnforceLength SMALLINT NULL ,
          RestrictRange SMALLINT NULL ,
          MinValDecimal REAL NULL ,
          MaxValDecimal REAL NULL ,
          MinValDate DATETIME NULL ,
          MaxValDate DATETIME NULL ,
          ListAllowMultiple SMALLINT NULL ,
          DefaultValueText VARCHAR(100) NULL ,
          DefaultValueDecimal REAL NULL ,
          DefaultValueDate DATETIME NULL ,
          UseDefault SMALLINT NULL ,
          ReqOnSubmit SMALLINT NULL ,
          IncludeDateButton BIT NULL 
        ) ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (DATA_COMPRESSION = PAGE);

    ALTER TABLE src.UDFLibrary ADD 
    CONSTRAINT PK_UDFLibrary PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, UDFIdNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_UDFLibrary ON src.UDFLibrary REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_UDFLibrary'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_UDFLibrary ON src.UDFLibrary REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

IF OBJECT_ID('src.UDFListValues', 'U') IS NULL
BEGIN
    CREATE TABLE src.UDFListValues
        (
          OdsPostingGroupAuditId INT NOT NULL ,
          OdsCustomerId INT NOT NULL ,
          OdsCreateDate DATETIME2(7) NOT NULL ,
          OdsSnapshotDate DATETIME2(7) NOT NULL ,
          OdsRowIsCurrent BIT NOT NULL ,
          OdsHashbytesValue VARBINARY(8000) NULL,
          DmlOperation CHAR(1) NOT NULL ,
          ListValueIdNo INT NOT NULL ,
          UDFIdNo INT NULL ,
          SeqNo SMALLINT NULL ,
          ListValue VARCHAR(50) NULL ,
          DefaultValue SMALLINT NULL 
        ) ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (DATA_COMPRESSION = PAGE);

    ALTER TABLE src.UDFListValues ADD 
    CONSTRAINT PK_UDFListValues PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ListValueIdNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_UDFListValues ON src.UDFListValues REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_UDFListValues'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_UDFListValues ON src.UDFListValues REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.UDFProvider', 'U') IS NULL
BEGIN
    CREATE TABLE src.UDFProvider
        (
          OdsPostingGroupAuditId INT NOT NULL ,
          OdsCustomerId INT NOT NULL ,
          OdsCreateDate DATETIME2(7) NOT NULL ,
          OdsSnapshotDate DATETIME2(7) NOT NULL ,
          OdsRowIsCurrent BIT NOT NULL ,
          OdsHashbytesValue VARBINARY(8000) NULL,
          DmlOperation CHAR(1) NOT NULL ,
          PvdIdNo INT NOT NULL ,
          UDFIdNo INT NOT NULL ,
          UDFValueText VARCHAR(255) NULL ,
          UDFValueDecimal DECIMAL(19, 4) NULL ,
          UDFValueDate DATETIME NULL 
        ) ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (DATA_COMPRESSION = PAGE);

    ALTER TABLE src.UDFProvider ADD 
    CONSTRAINT PK_UDFProvider PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, PvdIdNo, UDFIdNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_UDFProvider ON src.UDFProvider  REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

IF EXISTS ( SELECT  *
            FROM    sys.columns c
                    INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
            WHERE   c.object_id = OBJECT_ID(N'src.UDFProvider')
                    AND c.name = 'UDFValueDecimal'
                    AND NOT ( t.name = 'DECIMAL'
                              AND c.precision = 19 AND c.scale = 4
                            ) )
    BEGIN
        ALTER TABLE src.UDFProvider ALTER COLUMN UDFValueDecimal DECIMAL(19, 4) NULL;
    END;
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_UDFProvider'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_UDFProvider ON src.UDFProvider  REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

IF OBJECT_ID('src.UDFViewOrder', 'U') IS NULL
BEGIN
    CREATE TABLE src.UDFViewOrder
        (
          OdsPostingGroupAuditId INT NOT NULL ,
          OdsCustomerId INT NOT NULL ,
          OdsCreateDate DATETIME2(7) NOT NULL ,
          OdsSnapshotDate DATETIME2(7) NOT NULL ,
          OdsRowIsCurrent BIT NOT NULL ,
          OdsHashbytesValue VARBINARY(8000) NULL,
          DmlOperation CHAR(1) NOT NULL ,
          OfficeId INT NOT NULL ,
          UDFIdNo INT NOT NULL ,
          ViewOrder SMALLINT NULL 
        ) ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (DATA_COMPRESSION = PAGE);

    ALTER TABLE src.UDFViewOrder ADD 
    CONSTRAINT PK_UDFViewOrder PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, OfficeId, UDFIdNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_UDFViewOrder ON src.UDFViewOrder REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_UDFViewOrder'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_UDFViewOrder ON src.UDFViewOrder REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.UDF_Sentry_Criteria', 'U') IS NULL
BEGIN
    CREATE TABLE src.UDF_Sentry_Criteria
        (
          OdsPostingGroupAuditId INT NOT NULL ,
          OdsCustomerId INT NOT NULL ,
          OdsCreateDate DATETIME2(7) NOT NULL ,
          OdsSnapshotDate DATETIME2(7) NOT NULL ,
          OdsRowIsCurrent BIT NOT NULL ,
          OdsHashbytesValue VARBINARY(8000) NULL,
          DmlOperation CHAR(1) NOT NULL ,
          UdfIdNo INT NULL ,
          CriteriaID INT NOT NULL ,
          ParentName VARCHAR(50) NULL ,
          Name VARCHAR(50) NULL ,
          Description VARCHAR(1000) NULL ,
          Operators VARCHAR(50) NULL ,
          PredefinedValues VARCHAR(MAX) NULL ,
          ValueDataType VARCHAR(50) NULL ,
          ValueFormat VARCHAR(50) NULL 
        ) ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (DATA_COMPRESSION = PAGE);

    ALTER TABLE src.UDF_Sentry_Criteria ADD 
    CONSTRAINT PK_UDF_Sentry_Criteria PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, CriteriaID) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_UDF_Sentry_Criteria ON src.UDF_Sentry_Criteria REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_UDF_Sentry_Criteria'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_UDF_Sentry_Criteria ON src.UDF_Sentry_Criteria REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.Vpn', 'U') IS NULL
BEGIN
	CREATE TABLE src.Vpn (
		OdsPostingGroupAuditId INT NOT NULL
		,OdsCustomerId INT NOT NULL
		,OdsCreateDate DATETIME2(7) NOT NULL
		,OdsSnapshotDate DATETIME2(7) NOT NULL
		,OdsRowIsCurrent BIT NOT NULL
		,OdsHashbytesValue VARBINARY(8000) NULL
		,DmlOperation CHAR(1) NOT NULL
		,VpnId SMALLINT NOT NULL
		,NetworkName VARCHAR(50) NULL
		,PendAndSend BIT NULL
		,BypassMatching BIT NULL
		,AllowsResends BIT NULL
		,OdsEligible BIT NULL
		) ON DP_Ods_PartitionScheme (OdsCustomerId)
		WITH (DATA_COMPRESSION = PAGE);

	ALTER TABLE src.Vpn ADD CONSTRAINT PK_Vpn PRIMARY KEY CLUSTERED (
		OdsPostingGroupAuditId
		,OdsCustomerId
		,VpnId
		)
		WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_Vpn ON src.Vpn REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Vpn'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Vpn ON src.Vpn REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.VPNActivityFlag', 'U') IS NULL
BEGIN
	CREATE TABLE src.VPNActivityFlag(
		OdsPostingGroupAuditId INT NOT NULL ,
		OdsCustomerId INT NOT NULL ,
		OdsCreateDate DATETIME2(7) NOT NULL ,
		OdsSnapshotDate DATETIME2(7) NOT NULL ,
		OdsRowIsCurrent BIT NOT NULL ,
		OdsHashbytesValue VARBINARY(8000) NULL,
		DmlOperation CHAR(1) NOT NULL ,
		Activity_Flag VARCHAR(1) NOT NULL ,
	    AF_Description VARCHAR(50) NULL ,
	    AF_ShortDesc VARCHAR(50) NULL ,
		Data_Source VARCHAR(5) NULL ,
		Default_Billable BIT NULL ,
		Credit BIT NULL
	)ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (DATA_COMPRESSION = PAGE);
        
 ALTER TABLE src.VPNActivityFlag ADD 
 CONSTRAINT PK_VPNActivityFlag PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,Activity_Flag) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);
 
 ALTER INDEX PK_VPNActivityFlag ON src.VPNActivityFlag REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_VPNActivityFlag'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_VPNActivityFlag ON src.VPNActivityFlag REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO



IF OBJECT_ID('src.VPNBillableFlags', 'U') IS NULL
BEGIN
	CREATE TABLE src.VPNBillableFlags(
		OdsPostingGroupAuditId INT NOT NULL ,
		OdsCustomerId INT NOT NULL ,
		OdsCreateDate DATETIME2(7) NOT NULL ,
		OdsSnapshotDate DATETIME2(7) NOT NULL ,
		OdsRowIsCurrent BIT NOT NULL ,
		OdsHashbytesValue VARBINARY(8000) NULL,
		DmlOperation CHAR(1) NOT NULL ,
		SOJ nchar(2) NOT NULL,
		NetworkID int NOT NULL,
		ActivityFlag nchar(2) NOT NULL,
		Billable nchar(1) NULL,
		CompanyCode varchar(10) NOT NULL,
		CompanyName varchar(100) NULL,
	)ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (DATA_COMPRESSION = PAGE);
        
 ALTER TABLE src.VPNBillableFlags ADD 
 CONSTRAINT PK_VPNBillableFlags PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,CompanyCode,SOJ,NetworkID,ActivityFlag) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);
 
 ALTER INDEX PK_VPNBillableFlags ON src.VPNBillableFlags REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_VPNBillableFlags'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_VPNBillableFlags ON src.VPNBillableFlags REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

IF OBJECT_ID('src.VpnBillingCategory', 'U') IS NULL
BEGIN
	CREATE TABLE src.VpnBillingCategory (
		OdsPostingGroupAuditId int NOT NULL,
		OdsCustomerId int NOT NULL,
		OdsCreateDate datetime2(7) NOT NULL,
		OdsSnapshotDate datetime2(7) NOT NULL,
		OdsRowIsCurrent bit NOT NULL,
		OdsHashbytesValue varbinary(8000) NULL,
		DmlOperation char(1) NOT NULL,
		VpnBillingCategoryCode char(1) NOT NULL,
		VpnBillingCategoryDescription varchar(30) NULL
		) ON DP_Ods_PartitionScheme (OdsCustomerId)
		WITH (DATA_COMPRESSION = PAGE);

	ALTER TABLE src.VpnBillingCategory 
	ADD CONSTRAINT PK_VpnBillingCategory 
	PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId,OdsCustomerId,VpnBillingCategoryCode)
		WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_VpnBillingCategory ON src.VpnBillingCategory REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_VpnBillingCategory'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_VpnBillingCategory ON src.VpnBillingCategory REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.VpnLedger', 'U') IS NULL
BEGIN
	CREATE TABLE src.VpnLedger (
		OdsPostingGroupAuditId INT NOT NULL
		,OdsCustomerId INT NOT NULL
		,OdsCreateDate DATETIME2(7) NOT NULL
		,OdsSnapshotDate DATETIME2(7) NOT NULL
		,OdsRowIsCurrent BIT NOT NULL
		,OdsHashbytesValue VARBINARY(8000) NULL
		,DmlOperation CHAR(1) NOT NULL
		,TransactionID BIGINT NOT NULL
		,TransactionTypeID INT NULL
		,BillIdNo INT NULL
		,Line_No SMALLINT NULL
		,Charged MONEY NULL
		,DPAllowed MONEY NULL
		,VPNAllowed MONEY NULL
		,Savings MONEY NULL
		,Credits MONEY NULL
		,HasOverride BIT NULL
		,EndNotes NVARCHAR(200)
		,NetworkIdNo INT NULL
		,ProcessFlag SMALLINT NULL
		,LineType INT NULL
		,DateTimeStamp DATETIME NULL
		,SeqNo INT NULL
		,VPN_Ref_Line_No SMALLINT NULL
		,SpecialProcessing BIT NULL
		,CreateDate DATETIME2 NULL
		,LastChangedOn DATETIME2 NULL
		) ON DP_Ods_PartitionScheme (OdsCustomerId)
		WITH (DATA_COMPRESSION = PAGE);

	ALTER TABLE src.VpnLedger ADD CONSTRAINT PK_VpnLedger PRIMARY KEY CLUSTERED (
		OdsPostingGroupAuditId
		,OdsCustomerId
		,TransactionID
		)
		WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_VpnLedger ON src.VpnLedger REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.VpnLedger')
						AND NAME = 'AdjustedCharged' )
	BEGIN
		ALTER TABLE src.VpnLedger ADD AdjustedCharged DECIMAL(19,4) NULL ;
	END ; 
GO


-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_VpnLedger'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_VpnLedger ON src.VpnLedger REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO


IF OBJECT_ID('src.VpnProcessFlagType', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.VpnProcessFlagType
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  VpnProcessFlagTypeId SMALLINT NOT NULL ,
			  VpnProcessFlagType VARCHAR (50) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.VpnProcessFlagType ADD 
     CONSTRAINT PK_VpnProcessFlagType PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, VpnProcessFlagTypeId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_VpnProcessFlagType ON src.VpnProcessFlagType   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.VpnSavingTransactionType', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.VpnSavingTransactionType
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  VpnSavingTransactionTypeId INT NOT NULL ,
			  VpnSavingTransactionType VARCHAR (50) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.VpnSavingTransactionType ADD 
     CONSTRAINT PK_VpnSavingTransactionType PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, VpnSavingTransactionTypeId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_VpnSavingTransactionType ON src.VpnSavingTransactionType   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.Vpn_Billing_History', 'U') IS NULL
BEGIN

CREATE TABLE src.Vpn_Billing_History(
	OdsPostingGroupAuditId int NOT NULL,
	OdsCustomerId int NOT NULL,
	OdsCreateDate datetime2(7) NOT NULL,
	OdsSnapshotDate datetime2(7) NOT NULL,
	OdsRowIsCurrent bit NOT NULL,
	OdsHashbytesValue varbinary(8000) NULL,
	DmlOperation char(1) NOT NULL,
	Customer varchar(50) NULL,
	TransactionID bigint NOT NULL,
	Period datetime NOT NULL,
	ActivityFlag varchar(1) NULL,
	BillableFlag varchar(1) NULL,
	Void varchar(4) NULL,
	CreditType varchar(10) NULL,
	Network varchar(50) NULL,
	BillIdNo int NULL,
	Line_No smallint NULL,
	TransactionDate datetime NULL,
	RepriceDate datetime NULL,
	ClaimNo varchar(50) NULL,
	ProviderCharges money NULL,
	DPAllowed money NULL,
	VPNAllowed money NULL,
	Savings money NULL,
	Credits money NULL,
	NetSavings money NULL,
	SOJ varchar(2) NULL,
	seqno int NULL,
	CompanyCode varchar(10) NULL,
	VpnId smallint NULL,
	ProcessFlag smallint NULL,
	SK int NULL,
	DATABASE_NAME varchar(100) NULL,
	SubmittedToFinance bit NULL,
	IsInitialLoad bit NULL,
	VpnBillingCategoryCode char(1) NULL
		) ON DP_Ods_PartitionScheme (OdsCustomerId)
		WITH (DATA_COMPRESSION = PAGE);

	ALTER TABLE src.Vpn_Billing_History 
	ADD CONSTRAINT PK_Vpn_Billing_History 
	PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId,OdsCustomerId,TransactionID,Period)
		WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_Vpn_Billing_History ON src.Vpn_Billing_History REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Vpn_Billing_History'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Vpn_Billing_History ON src.Vpn_Billing_History REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.WeekEndsAndHolidays', 'U') IS NULL
BEGIN
	CREATE TABLE src.WeekEndsAndHolidays (
		OdsPostingGroupAuditId INT NOT NULL,
		OdsCustomerId INT NOT NULL,
		OdsCreateDate DATETIME2(7) NOT NULL,
		OdsSnapshotDate DATETIME2(7) NOT NULL,
		OdsRowIsCurrent BIT NOT NULL,
		OdsHashbytesValue VARBINARY(8000) NULL,
		DmlOperation CHAR(1) NOT NULL,
		DayOfWeekDate datetime NULL,
		DayName char(3) NULL,
		WeekEndsAndHolidayId int NOT NULL
		) ON DP_Ods_PartitionScheme (OdsCustomerId)
		WITH (DATA_COMPRESSION = PAGE);

	ALTER TABLE src.WeekEndsAndHolidays 
	ADD CONSTRAINT PK_WeekEndsAndHolidays
	PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId,OdsCustomerId,WeekEndsAndHolidayId)
		WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_WeekEndsAndHolidays ON src.WeekEndsAndHolidays REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_WeekEndsAndHolidays'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_WeekEndsAndHolidays ON src.WeekEndsAndHolidays REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.Zip2County', 'U') IS NULL
BEGIN
    CREATE TABLE src.Zip2County
        (
            OdsPostingGroupAuditId INT NOT NULL ,
            OdsCustomerId INT NOT NULL ,
            OdsCreateDate DATETIME2(7) NOT NULL ,
            OdsSnapshotDate DATETIME2(7) NOT NULL ,
            OdsRowIsCurrent BIT NOT NULL ,
            OdsHashbytesValue VARBINARY(8000) NULL,
            DmlOperation CHAR(1) NOT NULL ,
            Zip VARCHAR(5) NOT NULL ,
            County VARCHAR(50) NULL ,
            State VARCHAR(2) NULL 
            
        )ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (DATA_COMPRESSION = PAGE);

    ALTER TABLE src.Zip2County ADD 
    CONSTRAINT PK_Zip2County PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Zip) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_Zip2County ON src.Zip2County REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Zip2County'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Zip2County ON src.Zip2County REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('src.ZipCode', 'U') IS NULL
    BEGIN
        CREATE TABLE src.ZipCode
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              ZipCode VARCHAR(5) NOT NULL ,
              PrimaryRecord BIT NULL ,
              STATE VARCHAR(2) NULL ,
              City VARCHAR(30) NULL ,
              CityAlias VARCHAR(30) NOT NULL ,
              County VARCHAR(30) NULL ,
              Cbsa VARCHAR(5) NULL ,
              CbsaType VARCHAR(5) NULL ,
              ZipCodeRegionId TINYINT NULL
            )
        ON  DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.ZipCode ADD CONSTRAINT PK_ZipCode PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ZipCode, CityAlias)
        WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_ZipCode ON src.ZipCode REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END;
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.ZipCode')
                        AND NAME = 'ZipCodeRegionId' )
    BEGIN
        ALTER TABLE src.ZipCode ADD ZipCodeRegionId TINYINT NULL;
    END;
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_ZipCode'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_ZipCode ON src.ZipCode REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
IF OBJECT_ID('stg.AcceptedTreatmentDate', 'U') IS NOT NULL
DROP TABLE stg.AcceptedTreatmentDate
BEGIN
	CREATE TABLE stg.AcceptedTreatmentDate (
		AcceptedTreatmentDateId int NULL
	   ,DemandClaimantId int  NULL
	   ,TreatmentDate datetimeoffset(7) NULL
	   ,Comments varchar(255) NULL
	   ,TreatmentCategoryId tinyint NULL
	   ,LastUpdatedBy varchar(15) NULL
	   ,LastUpdatedDate datetimeoffset(7) NULL
	   ,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.Adjustment3603rdPartyEndNoteSubCategory', 'U') IS NOT NULL 
	DROP TABLE stg.Adjustment3603rdPartyEndNoteSubCategory  
BEGIN
	CREATE TABLE stg.Adjustment3603rdPartyEndNoteSubCategory
		(
		  ReasonNumber INT NULL,
		  SubCategoryId INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.Adjustment360ApcEndNoteSubCategory', 'U') IS NOT NULL 
	DROP TABLE stg.Adjustment360ApcEndNoteSubCategory  
BEGIN
	CREATE TABLE stg.Adjustment360ApcEndNoteSubCategory
		(
		  ReasonNumber INT NULL,
		  SubCategoryId INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.Adjustment360Category', 'U') IS NOT NULL 
	DROP TABLE stg.Adjustment360Category  
BEGIN
	CREATE TABLE stg.Adjustment360Category
		(
		  Adjustment360CategoryId INT NULL,
		  Name VARCHAR (50) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.Adjustment360EndNoteSubCategory', 'U') IS NOT NULL 
	DROP TABLE stg.Adjustment360EndNoteSubCategory  
BEGIN
	CREATE TABLE stg.Adjustment360EndNoteSubCategory
		(
		  ReasonNumber INT NULL,
		  SubCategoryId INT NULL,
		  EndnoteTypeId TINYINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.Adjustment360OverrideEndNoteSubCategory', 'U') IS NOT NULL 
	DROP TABLE stg.Adjustment360OverrideEndNoteSubCategory  
BEGIN
	CREATE TABLE stg.Adjustment360OverrideEndNoteSubCategory
		(
		  ReasonNumber INT NULL,
		  SubCategoryId INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.Adjustment360SubCategory', 'U') IS NOT NULL 
	DROP TABLE stg.Adjustment360SubCategory  
BEGIN
	CREATE TABLE stg.Adjustment360SubCategory
		(
		  Adjustment360SubCategoryId INT NULL,
		  Name VARCHAR (50) NULL,
		  Adjustment360CategoryId INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.Adjustment3rdPartyEndnoteSubCategory', 'U') IS NOT NULL 
	DROP TABLE stg.Adjustment3rdPartyEndnoteSubCategory  
BEGIN
	CREATE TABLE stg.Adjustment3rdPartyEndnoteSubCategory
		(
		  ReasonNumber INT NULL,
		  SubCategoryId VARCHAR (100) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.AdjustmentApcEndNoteSubCategory', 'U') IS NOT NULL 
	DROP TABLE stg.AdjustmentApcEndNoteSubCategory  
BEGIN
	CREATE TABLE stg.AdjustmentApcEndNoteSubCategory
		(
		  ReasonNumber INT NULL,
		  SubCategoryId VARCHAR (100) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.AdjustmentEndNoteSubCategory', 'U') IS NOT NULL 
	DROP TABLE stg.AdjustmentEndNoteSubCategory  
BEGIN
	CREATE TABLE stg.AdjustmentEndNoteSubCategory
		(
		  ReasonNumber INT NULL,
		  SubCategoryId VARCHAR (100) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.AdjustmentOverrideEndNoteSubCategory', 'U') IS NOT NULL 
	DROP TABLE stg.AdjustmentOverrideEndNoteSubCategory  
BEGIN
	CREATE TABLE stg.AdjustmentOverrideEndNoteSubCategory
		(
		  ReasonNumber INT NULL,
		  SubCategoryId VARCHAR (100) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.Adjustor', 'U') IS NOT NULL
    DROP TABLE stg.Adjustor;
BEGIN
    CREATE TABLE stg.Adjustor
        (
          lAdjIdNo INT NULL ,
          IDNumber VARCHAR(15) NULL ,
          Lastname VARCHAR(30) NULL ,
          FirstName VARCHAR(30) NULL ,
          Address1 VARCHAR(30) NULL ,
          Address2 VARCHAR(30) NULL ,
          City VARCHAR(30) NULL ,
          State VARCHAR(2) NULL ,
          ZipCode VARCHAR(12) NULL ,
          Phone VARCHAR(25) NULL ,
          Fax VARCHAR(25) NULL ,
          Office VARCHAR(120) NULL ,
          EMail VARCHAR(60) NULL ,
          InUse VARCHAR(100) NULL ,
          OfficeIdNo INT NULL ,
          UserId INT NULL ,
          CreateDate DATETIME NULL ,
          LastChangedOn DATETIME NULL ,
		  DmlOperation CHAR(1) NOT NULL
        );
END
GO

-- Alter Office Column size to increase from 30 to 120
ALTER TABLE stg.Adjustor
ALTER COLUMN Office VARCHAR(120);
GO

IF OBJECT_ID('stg.AnalysisGroup', 'U') IS NOT NULL
DROP TABLE stg.AnalysisGroup
BEGIN
	CREATE TABLE stg.AnalysisGroup (
		AnalysisGroupId int NULL
	   ,GroupName varchar(200) NULL
	   ,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.AnalysisRule', 'U') IS NOT NULL
    DROP TABLE stg.AnalysisRule;
BEGIN
    CREATE TABLE stg.AnalysisRule
        (
         AnalysisRuleId INT NULL
        ,Title VARCHAR(200) NULL
        ,AssemblyQualifiedName VARCHAR(200) NULL
        ,MethodToInvoke VARCHAR(50) NULL
        ,DisplayMessage NVARCHAR(200) NULL
        ,DisplayOrder INT NULL
        ,IsActive BIT NULL
        ,CreateDate DATETIMEOFFSET(7) NULL
        ,LastChangedOn DATETIMEOFFSET(7) NULL
        ,MessageToken NVARCHAR(200) NULL
        ,DmlOperation CHAR(1) NOT NULL
        );
END;
GO
IF OBJECT_ID('stg.AnalysisRuleGroup', 'U') IS NOT NULL
DROP TABLE stg.AnalysisRuleGroup
BEGIN
	CREATE TABLE stg.AnalysisRuleGroup (
		AnalysisRuleGroupId int NULL
	   ,AnalysisRuleId int NULL
	   ,AnalysisGroupId int NULL
	   ,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.AnalysisRuleThreshold', 'U') IS NOT NULL
DROP TABLE stg.AnalysisRuleThreshold
BEGIN
	CREATE TABLE stg.AnalysisRuleThreshold (
	   AnalysisRuleThresholdId int NULL
      ,AnalysisRuleId int NULL
      ,ThresholdKey varchar(50) NULL
      ,ThresholdValue varchar(100) NULL
      ,CreateDate datetimeoffset(7) NULL
      ,LastChangedOn datetimeoffset(7) NULL
	  ,DmlOperation CHAR(1) NOT NULL
		)
END
GO

IF OBJECT_ID('stg.ApportionmentEndnote', 'U') IS NOT NULL
DROP TABLE stg.ApportionmentEndnote
BEGIN
	CREATE TABLE stg.ApportionmentEndnote (
		ApportionmentEndnote INT NULL,
        ShortDescription VARCHAR(50) NULL,
        LongDescription VARCHAR(500) NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.BillAdjustment', 'U') IS NOT NULL
DROP TABLE stg.BillAdjustment
BEGIN
	CREATE TABLE stg.BillAdjustment (
		BillLineAdjustmentId BIGINT NULL
		,BillIdNo INT NULL
		,LineNumber INT NULL
		,Adjustment MONEY NULL
		,EndNote INT NULL
		,EndNoteTypeId INT NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO

IF OBJECT_ID('stg.BillApportionmentEndnote', 'U') IS NOT NULL
DROP TABLE stg.BillApportionmentEndnote
BEGIN
	CREATE TABLE stg.BillApportionmentEndnote (
		BillId INT NULL,
        LineNumber SMALLINT NULL,
        Endnote INT NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO

IF OBJECT_ID('stg.BillCustomEndnote', 'U') IS NOT NULL
DROP TABLE stg.BillCustomEndnote
BEGIN
	CREATE TABLE stg.BillCustomEndnote (
		BillId INT NULL,
        LineNumber SMALLINT NULL,
		Endnote INT NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO


IF OBJECT_ID('stg.BillExclusionLookUpTable', 'U') IS NOT NULL
DROP TABLE stg.BillExclusionLookUpTable
BEGIN
	CREATE TABLE stg.BillExclusionLookUpTable (
		  ReportID tinyint  NULL
	     ,ReportName nvarchar(100)  NULL
		 ,DmlOperation CHAR(1)  NULL
		)
END
GO
IF OBJECT_ID('stg.Bills', 'U') IS NOT NULL 
	DROP TABLE stg.Bills  
BEGIN
	CREATE TABLE stg.Bills
		(
		  BillIDNo INT NULL,
		  LINE_NO SMALLINT NULL,
		  LINE_NO_DISP SMALLINT NULL,
		  OVER_RIDE SMALLINT NULL,
		  DT_SVC DATETIME NULL,
		  PRC_CD VARCHAR (7) NULL,
		  UNITS REAL NULL,
		  TS_CD VARCHAR (14) NULL,
		  CHARGED MONEY NULL,
		  ALLOWED MONEY NULL,
		  ANALYZED MONEY NULL,
		  REASON1 INT NULL,
		  REASON2 INT NULL,
		  REASON3 INT NULL,
		  REASON4 INT NULL,
		  REASON5 INT NULL,
		  REASON6 INT NULL,
		  REASON7 INT NULL,
		  REASON8 INT NULL,
		  REF_LINE_NO SMALLINT NULL,
		  SUBNET VARCHAR (9) NULL,
		  OverrideReason SMALLINT NULL,
		  FEE_SCHEDULE MONEY NULL,
		  POS_RevCode VARCHAR (4) NULL,
		  CTGPenalty MONEY NULL,
		  PrePPOAllowed MONEY NULL,
		  PPODate DATETIME NULL,
		  PPOCTGPenalty MONEY NULL,
		  UCRPerUnit MONEY NULL,
		  FSPerUnit MONEY NULL,
		  HCRA_Surcharge MONEY NULL,
		  EligibleAmt MONEY NULL,
		  DPAllowed MONEY NULL,
		  EndDateOfService DATETIME NULL,
		  AnalyzedCtgPenalty DECIMAL (19,4) NULL,
		  AnalyzedCtgPpoPenalty DECIMAL (19,4) NULL,
		  RepackagedNdc VARCHAR (13) NULL,
		  OriginalNdc VARCHAR (13) NULL,
		  UnitOfMeasureId TINYINT NULL,
		  PackageTypeOriginalNdc VARCHAR (2) NULL,
		  ServiceCode VARCHAR (25) NULL,
		  PreApportionedAmount DECIMAL (19,4) NULL,
		  DeductibleApplied DECIMAL (19,4) NULL,
		  BillReviewResults DECIMAL (19,4) NULL,
		  PreOverriddenDeductible DECIMAL (19,4) NULL,
		  RemainingBalance DECIMAL (19,4) NULL,
		  CtgCoPayPenalty DECIMAL(19,4) NULL,
		  PpoCtgCoPayPenaltyPercentage DECIMAL(19,4) NULL,
		  AnalyzedCtgCoPayPenalty DECIMAL(19,4) NULL,
		  AnalyzedPpoCtgCoPayPenaltyPercentage DECIMAL(19,4) NULL,
		  CtgVunPenalty DECIMAL(19,4) NULL,
		  PpoCtgVunPenaltyPercentage DECIMAL(19,4) NULL,
		  AnalyzedCtgVunPenalty DECIMAL(19,4) NULL,
		  AnalyzedPpoCtgVunPenaltyPercentage DECIMAL(19,4) NULL,
		  RenderingNpi VARCHAR (15) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.BillsOverride', 'U') IS NOT NULL
DROP TABLE stg.BillsOverride
BEGIN
	CREATE TABLE stg.BillsOverride(
		BillsOverrideID INT NULL,
		BillIDNo INT NULL,
		LINE_NO SMALLINT NULL,
		UserId INT NULL,
		DateSaved DATETIME NULL,
		AmountBefore MONEY NULL,
		AmountAfter MONEY NULL,
		CodesOverrode VARCHAR(50) NULL,
		SeqNo INT NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.BillsProviderNetwork', 'U') IS NOT NULL
DROP TABLE stg.BillsProviderNetwork
BEGIN
	CREATE TABLE stg.BillsProviderNetwork (
		BillIdNo INT NULL
		,NetworkId INT NULL
		,NetworkName VARCHAR(50) NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.BILLS_CTG_Endnotes', 'U') IS NOT NULL
DROP TABLE stg.BILLS_CTG_EndNotes
BEGIN
	CREATE TABLE stg.BILLS_CTG_Endnotes (
		BillIdNo INT NULL
		,Line_No SMALLINT NULL
		,Endnote INT NULL
		,RuleType VARCHAR(2) NULL
		,RuleId INT NULL
		,PreCertAction SMALLINT NULL
		,PercentDiscount REAL NULL
		,ActionId SMALLINT NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.BILLS_DRG', 'U') IS NOT NULL 
	DROP TABLE stg.BILLS_DRG  
BEGIN
	CREATE TABLE stg.BILLS_DRG
		(
		  BillIdNo INT NULL,
		  PricerPassThru MONEY NULL,
		  PricerCapital_Outlier_Amt MONEY NULL,
		  PricerCapital_OldHarm_Amt MONEY NULL,
		  PricerCapital_IME_Amt MONEY NULL,
		  PricerCapital_HSP_Amt MONEY NULL,
		  PricerCapital_FSP_Amt MONEY NULL,
		  PricerCapital_Exceptions_Amt MONEY NULL,
		  PricerCapital_DSH_Amt MONEY NULL,
		  PricerCapitalPayment MONEY NULL,
		  PricerDSH MONEY NULL,
		  PricerIME MONEY NULL,
		  PricerCostOutlier MONEY NULL,
		  PricerHSP MONEY NULL,
		  PricerFSP MONEY NULL,
		  PricerTotalPayment MONEY NULL,
		  PricerReturnMsg VARCHAR (255) NULL,
		  ReturnDRG VARCHAR (3) NULL,
		  ReturnDRGDesc VARCHAR (125) NULL,
		  ReturnMDC VARCHAR (3) NULL,
		  ReturnMDCDesc VARCHAR (100) NULL,
		  ReturnDRGWt REAL NULL,
		  ReturnDRGALOS REAL NULL,
		  ReturnADX VARCHAR (8) NULL,
		  ReturnSDX VARCHAR (8) NULL,
		  ReturnMPR VARCHAR (8) NULL,
		  ReturnPR2 VARCHAR (8) NULL,
		  ReturnPR3 VARCHAR (8) NULL,
		  ReturnNOR VARCHAR (8) NULL,
		  ReturnNO2 VARCHAR (8) NULL,
		  ReturnCOM VARCHAR (255) NULL,
		  ReturnCMI SMALLINT NULL,
		  ReturnDCC VARCHAR (8) NULL,
		  ReturnDX1 VARCHAR (8) NULL,
		  ReturnDX2 VARCHAR (8) NULL,
		  ReturnDX3 VARCHAR (8) NULL,
		  ReturnMCI SMALLINT NULL,
		  ReturnOR1 VARCHAR (8) NULL,
		  ReturnOR2 VARCHAR (8) NULL,
		  ReturnOR3 VARCHAR (8) NULL,
		  ReturnTRI SMALLINT NULL,
		  SOJ VARCHAR (2) NULL,
		  OPCERT VARCHAR (7) NULL,
		  BlendCaseInclMalp REAL NULL,
		  CapitalCost REAL NULL,
		  HospBadDebt REAL NULL,
		  ExcessPhysMalp REAL NULL,
		  SparcsPerCase REAL NULL,
		  AltLevelOfCare REAL NULL,
		  DRGWgt REAL NULL,
		  TransferCapital REAL NULL,
		  NYDrgType SMALLINT NULL,
		  LOS SMALLINT NULL,
		  TrimPoint SMALLINT NULL,
		  GroupBlendPercentage REAL NULL,
		  AdjustmentFactor REAL NULL,
		  HospLongStayGroupPrice REAL NULL,
		  TotalDRGCharge MONEY NULL,
		  BlendCaseAdj REAL NULL,
		  CapitalCostAdj REAL NULL,
		  NonMedicareCaseMix REAL NULL,
		  HighCostChargeConverter REAL NULL,
		  DischargeCasePaymentRate MONEY NULL,
		  DirectMedicalEducation MONEY NULL,
		  CasePaymentCapitalPerDiem MONEY NULL,
		  HighCostOutlierThreshold MONEY NULL,
		  ISAF REAL NULL,
		  ReturnSOI SMALLINT NULL,
		  CapitalCostPerDischarge MONEY NULL,
		  ReturnSOIDesc VARCHAR (20) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.BILLS_Endnotes', 'U') IS NOT NULL 
	DROP TABLE stg.BILLS_Endnotes  
BEGIN
	CREATE TABLE stg.BILLS_Endnotes
		(
		  BillIDNo INT NULL,
		  LINE_NO SMALLINT NULL,
		  EndNote SMALLINT NULL,
		  Referral VARCHAR (200) NULL,
		  PercentDiscount REAL NULL,
		  ActionId SMALLINT NULL,
		  EndnoteTypeId TINYINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.BILLS_OverrideEndnotes', 'U') IS NOT NULL
DROP TABLE stg.BILLS_OverrideEndnotes
BEGIN
	CREATE TABLE stg.BILLS_OverrideEndnotes (
		OverrideEndNoteID INT NULL
		,BillIdNo INT NULL
		,Line_No SMALLINT NULL
		,OverrideEndNote SMALLINT NULL
		,PercentDiscount REAL NULL
		,ActionId SMALLINT NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.Bills_Pharm', 'U') IS NOT NULL 
	DROP TABLE stg.Bills_Pharm  
BEGIN
	CREATE TABLE stg.Bills_Pharm
		(
		  BillIdNo INT NULL,
		  Line_No SMALLINT NULL,
		  LINE_NO_DISP SMALLINT NULL,
		  DateOfService DATETIME NULL,
		  NDC VARCHAR (13) NULL,
		  PriceTypeCode VARCHAR (2) NULL,
		  Units REAL NULL,
		  Charged MONEY NULL,
		  Allowed MONEY NULL,
		  EndNote VARCHAR (20) NULL,
		  Override SMALLINT NULL,
		  Override_Rsn VARCHAR (10) NULL,
		  Analyzed MONEY NULL,
		  CTGPenalty MONEY NULL,
		  PrePPOAllowed MONEY NULL,
		  PPODate DATETIME NULL,
		  POS_RevCode VARCHAR (4) NULL,
		  DPAllowed MONEY NULL,
		  HCRA_Surcharge MONEY NULL,
		  EndDateOfService DATETIME NULL,
		  RepackagedNdc VARCHAR (13) NULL,
		  OriginalNdc VARCHAR (13) NULL,
		  UnitOfMeasureId TINYINT NULL,
		  PackageTypeOriginalNdc VARCHAR (2) NULL,
		  PpoCtgPenalty DECIMAL (19,4) NULL,
		  ServiceCode VARCHAR (25) NULL,
		  PreApportionedAmount DECIMAL (19,4) NULL,
		  DeductibleApplied DECIMAL (19,4) NULL,
		  BillReviewResults DECIMAL (19,4) NULL,
		  PreOverriddenDeductible DECIMAL (19,4) NULL,
		  RemainingBalance DECIMAL (19,4) NULL,
		  CtgCoPayPenalty DECIMAL (19,4) NULL,
		  PpoCtgCoPayPenaltyPercentage DECIMAL (19,4) NULL,
		  CtgVunPenalty DECIMAL (19,4) NULL,
		  PpoCtgVunPenaltyPercentage DECIMAL (19,4) NULL,
		  RenderingNpi VARCHAR (15) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.Bills_Pharm_CTG_Endnotes', 'U') IS NOT NULL
DROP TABLE stg.Bills_Pharm_CTG_Endnotes
BEGIN
	CREATE TABLE stg.Bills_Pharm_CTG_Endnotes (
		BillIDNo INT NULL
		,LINE_NO SMALLINT NULL
		,EndNote SMALLINT NULL
		,RuleType VARCHAR(2) NULL
		,RuleId INT NULL
		,PreCertAction SMALLINT NULL
		,PercentDiscount REAL NULL
		,ActionId SMALLINT NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.Bills_Pharm_Endnotes', 'U') IS NOT NULL 
	DROP TABLE stg.Bills_Pharm_Endnotes  
BEGIN
	CREATE TABLE stg.Bills_Pharm_Endnotes
		(
		  BillIDNo INT NULL,
		  LINE_NO SMALLINT NULL,
		  EndNote SMALLINT NULL,
		  Referral VARCHAR (200) NULL,
		  PercentDiscount REAL NULL,
		  ActionId SMALLINT NULL,
		  EndnoteTypeId TINYINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.Bills_Pharm_OverrideEndnotes', 'U') IS NOT NULL
DROP TABLE stg.Bills_Pharm_OverrideEndnotes
BEGIN
	CREATE TABLE stg.Bills_Pharm_OverrideEndnotes (
		OverrideEndNoteID INT NULL
		,BillIdNo INT NULL
		,Line_No SMALLINT NULL
		,OverrideEndNote SMALLINT NULL
		,PercentDiscount REAL NULL
		,ActionId SMALLINT NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO   
IF OBJECT_ID('stg.Bills_Tax', 'U') IS NOT NULL
DROP TABLE stg.Bills_Tax
BEGIN
	CREATE TABLE stg.Bills_Tax (
		BillsTaxId INT  NULL,
		TableType SMALLINT  NULL,
		BillIdNo INT  NULL,
		Line_No SMALLINT  NULL,
		SeqNo SMALLINT NULL,
		TaxTypeId SMALLINT  NULL,
		ImportTaxRate DECIMAL(5, 5) NULL,
		Tax MONEY NULL,
		OverridenTax MONEY NULL,
		ImportTaxAmount MONEY NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.BILL_HDR', 'U') IS NOT NULL 
	DROP TABLE stg.BILL_HDR  
BEGIN
	CREATE TABLE stg.BILL_HDR
		(
		  BillIDNo INT NULL,
		  CMT_HDR_IDNo INT NULL,
		  DateSaved DATETIME NULL,
		  DateRcv DATETIME NULL,
		  InvoiceNumber VARCHAR (40) NULL,
		  InvoiceDate DATETIME NULL,
		  FileNumber VARCHAR (50) NULL,
		  Note VARCHAR (20) NULL,
		  NoLines SMALLINT NULL,
		  AmtCharged MONEY NULL,
		  AmtAllowed MONEY NULL,
		  ReasonVersion SMALLINT NULL,
		  Region VARCHAR (50) NULL,
		  PvdUpdateCounter SMALLINT NULL,
		  FeatureID INT NULL,
		  ClaimDateLoss DATETIME NULL,
		  CV_Type VARCHAR (2) NULL,
		  Flags INT NULL,
		  WhoCreate VARCHAR (15) NULL,
		  WhoLast VARCHAR (15) NULL,
		  AcceptAssignment SMALLINT NULL,
		  EmergencyService SMALLINT NULL,
		  CmtPaidDeductible MONEY NULL,
		  InsPaidLimit MONEY NULL,
		  StatusFlag VARCHAR (2) NULL,
		  OfficeId INT NULL,
		  CmtPaidCoPay MONEY NULL,
		  AmbulanceMethod SMALLINT NULL,
		  StatusDate DATETIME NULL,
		  Category INT NULL,
		  CatDesc VARCHAR (1000) NULL,
		  AssignedUser VARCHAR (15) NULL,
		  CreateDate DATETIME NULL,
		  PvdZOS VARCHAR (12) NULL,
		  PPONumberSent SMALLINT NULL,
		  AdmissionDate DATETIME NULL,
		  DischargeDate DATETIME NULL,
		  DischargeStatus SMALLINT NULL,
		  TypeOfBill VARCHAR (4) NULL,
		  SentryMessage VARCHAR (1000) NULL,
		  AmbulanceZipOfPickup VARCHAR (12) NULL,
		  AmbulanceNumberOfPatients SMALLINT NULL,
		  WhoCreateID INT NULL,
		  WhoLastId INT NULL,
		  NYRequestDate DATETIME NULL,
		  NYReceivedDate DATETIME NULL,
		  ImgDocId VARCHAR (50) NULL,
		  PaymentDecision SMALLINT NULL,
		  PvdCMSId VARCHAR (6) NULL,
		  PvdNPINo VARCHAR (15) NULL,
		  DischargeHour VARCHAR (2) NULL,
		  PreCertChanged SMALLINT NULL,
		  DueDate DATETIME NULL,
		  AttorneyIDNo INT NULL,
		  AssignedGroup INT NULL,
		  LastChangedOn DATETIME NULL,
		  PrePPOAllowed MONEY NULL,
		  PPSCode SMALLINT NULL,
		  SOI SMALLINT NULL,
		  StatementStartDate DATETIME NULL,
		  StatementEndDate DATETIME NULL,
		  DeductibleOverride BIT NULL,
		  AdmissionType TINYINT NULL,
		  CoverageType VARCHAR (2) NULL,
		  PricingProfileId INT NULL,
		  DesignatedPricingState VARCHAR (2) NULL,
		  DateAnalyzed DATETIME NULL,
		  SentToPpoSysId INT NULL,
		  PricingState VARCHAR (2) NULL,
		  BillVpnEligible BIT NULL,
		  ApportionmentPercentage DECIMAL (5,2) NULL,
		  BillSourceId TINYINT NULL,
		  OutOfStateProviderNumber INT NULL,
		  FloridaDeductibleRuleEligible BIT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.Bill_History', 'U') IS NOT NULL
DROP TABLE stg.Bill_History
BEGIN
	CREATE TABLE stg.Bill_History (
		BillIdNo INT NULL
		,SeqNo INT NULL
		,DateCommitted DATETIME NULL
		,AmtCommitted MONEY NULL
		,UserId VARCHAR(15) NULL
		,AmtCoPay MONEY NULL
		,AmtDeductible MONEY NULL
		,Flags INT NULL
		,AmtSalesTax MONEY NULL
		,AmtOtherTax MONEY NULL
		,DeductibleOverride BIT NULL
		,PricingState VARCHAR(2) NULL
		,ApportionmentPercentage DECIMAL(5,2) NULL
		,FloridaDeductibleRuleEligible BIT NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.Bill_Payment_Adjustments', 'U') IS NOT NULL
DROP TABLE stg.Bill_Payment_Adjustments
BEGIN
	CREATE TABLE stg.Bill_Payment_Adjustments (
		Bill_Payment_Adjustment_ID INT  NULL,
		BillIDNo INT NULL,
		SeqNo SMALLINT NULL,
		InterestFlags INT NULL,
		DateInterestStarts DATETIME NULL,
		DateInterestEnds DATETIME NULL,
		InterestAdditionalInfoReceived DATETIME NULL,
		Interest MONEY NULL,
		Comments VARCHAR(1000) NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO

IF OBJECT_ID('stg.Bill_Pharm_ApportionmentEndnote', 'U') IS NOT NULL
DROP TABLE stg.Bill_Pharm_ApportionmentEndnote
BEGIN
	CREATE TABLE stg.Bill_Pharm_ApportionmentEndnote (
		BillId INT NULL,
        LineNumber SMALLINT NULL,
        Endnote INT NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.BILL_SENTRY_ENDNOTE', 'U') IS NOT NULL
    DROP TABLE stg.BILL_SENTRY_ENDNOTE;
BEGIN
    CREATE TABLE stg.BILL_SENTRY_ENDNOTE
        (
          BillID INT NULL ,
          Line INT NULL ,
          RuleID INT NULL ,
          PercentDiscount REAL NULL ,
          ActionId SMALLINT NULL ,
		  DmlOperation CHAR(1) NOT NULL
        );
END
GO
IF OBJECT_ID('stg.BIReportAdjustmentCategory', 'U') IS NOT NULL 
	DROP TABLE stg.BIReportAdjustmentCategory  
BEGIN
	CREATE TABLE stg.BIReportAdjustmentCategory
		(
		  BIReportAdjustmentCategoryId INT NULL,
		  Name VARCHAR (50) NULL,
		  Description VARCHAR (500) NULL,
		  DisplayPriority INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.BIReportAdjustmentCategoryMapping', 'U') IS NOT NULL 
	DROP TABLE stg.BIReportAdjustmentCategoryMapping  
BEGIN
	CREATE TABLE stg.BIReportAdjustmentCategoryMapping
		(
		  BIReportAdjustmentCategoryId INT NULL,
		  Adjustment360SubCategoryId INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.Bitmasks', 'U') IS NOT NULL
DROP TABLE stg.Bitmasks
BEGIN
	CREATE TABLE stg.Bitmasks (
		TableProgramUsed VARCHAR(50) NULL
		,AttributeUsed VARCHAR(50) NULL
		,DECIMAL BIGINT NULL
		,ConstantName VARCHAR(50) NULL
		,BIT VARCHAR(50) NULL
		,Hex VARCHAR(20) NULL
		,Description VARCHAR(250) NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.CbreToDpEndnoteMapping', 'U') IS NOT NULL 
	DROP TABLE stg.CbreToDpEndnoteMapping  
BEGIN
	CREATE TABLE stg.CbreToDpEndnoteMapping
		(
		  Endnote INT NULL,
		  EndnoteTypeId TINYINT NULL,
		  CbreEndnote SMALLINT NULL,
		  PricingState VARCHAR (2) NULL,
		  PricingMethodId TINYINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.CLAIMANT', 'U') IS NOT NULL 
	DROP TABLE stg.CLAIMANT  
BEGIN
	CREATE TABLE stg.CLAIMANT
		(
		  CmtIDNo INT NULL,
		  ClaimIDNo INT NULL,
		  CmtSSN VARCHAR (11) NULL,
		  CmtLastName VARCHAR (60) NULL,
		  CmtFirstName VARCHAR (35) NULL,
		  CmtMI VARCHAR (1) NULL,
		  CmtDOB DATETIME NULL,
		  CmtSEX VARCHAR (1) NULL,
		  CmtAddr1 VARCHAR (55) NULL,
		  CmtAddr2 VARCHAR (55) NULL,
		  CmtCity VARCHAR (30) NULL,
		  CmtState VARCHAR (2) NULL,
		  CmtZip VARCHAR (12) NULL,
		  CmtPhone VARCHAR (25) NULL,
		  CmtOccNo VARCHAR (11) NULL,
		  CmtAttorneyNo INT NULL,
		  CmtPolicyLimit MONEY NULL,
		  CmtStateOfJurisdiction VARCHAR (2) NULL,
		  CmtDeductible MONEY NULL,
		  CmtCoPaymentPercentage SMALLINT NULL,
		  CmtCoPaymentMax MONEY NULL,
		  CmtPPO_Eligible SMALLINT NULL,
		  CmtCoordBenefits SMALLINT NULL,
		  CmtFLCopay SMALLINT NULL,
		  CmtCOAExport DATETIME NULL,
		  CmtPGFirstName VARCHAR (30) NULL,
		  CmtPGLastName VARCHAR (30) NULL,
		  CmtDedType SMALLINT NULL,
		  ExportToClaimIQ SMALLINT NULL,
		  CmtInactive SMALLINT NULL,
		  CmtPreCertOption SMALLINT NULL,
		  CmtPreCertState VARCHAR (2) NULL,
		  CreateDate DATETIME NULL,
		  LastChangedOn DATETIME NULL,
		  OdsParticipant BIT NULL,
		  CoverageType VARCHAR (2) NULL,
		  DoNotDisplayCoverageTypeOnEOB BIT NULL,
		  ShowAllocationsOnEob BIT NULL,
		  SetPreAllocation BIT NULL,
		  PharmacyEligible TINYINT NULL,
		  SendCardToClaimant TINYINT NULL,
		  ShareCoPayMaximum BIT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.ClaimantManualProviderSummary', 'U') IS NOT NULL 
	DROP TABLE stg.ClaimantManualProviderSummary  
BEGIN
	CREATE TABLE stg.ClaimantManualProviderSummary
		(
		  ManualProviderId INT NULL,
		  DemandClaimantId INT NULL,
		  FirstDateOfService DATETIME2 (7) NULL,
		  LastDateOfService DATETIME2 (7) NULL,
		  Visits INT NULL,
		  ChargedAmount DECIMAL NULL,
		  EvaluatedAmount DECIMAL NULL,
		  MinimumEvaluatedAmount DECIMAL NULL,
		  MaximumEvaluatedAmount DECIMAL NULL,
		  Comments VARCHAR (255) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.ClaimantProviderSummaryEvaluation', 'U') IS NOT NULL
    DROP TABLE stg.ClaimantProviderSummaryEvaluation;
BEGIN
    CREATE TABLE stg.ClaimantProviderSummaryEvaluation
        (
         ClaimantProviderSummaryEvaluationId INT NULL
        ,ClaimantHeaderId INT NULL
        ,EvaluatedAmount DECIMAL(19, 4) NULL
        ,MinimumEvaluatedAmount DECIMAL(19, 4) NULL
        ,MaximumEvaluatedAmount DECIMAL(19, 4) NULL
        ,Comments VARCHAR(255) NULL
        ,DmlOperation CHAR(1) NOT NULL
        );
END;
GO
IF OBJECT_ID('stg.Claimant_ClientRef', 'U') IS NOT NULL
DROP TABLE stg.Claimant_ClientRef
BEGIN
	CREATE TABLE stg.Claimant_ClientRef (
		CmtIdNo INT NULL,
		CmtSuffix VARCHAR(50) NULL,
		ClaimIdNo INT NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.CLAIMS', 'U') IS NOT NULL
    DROP TABLE stg.CLAIMS;
BEGIN
    CREATE TABLE stg.CLAIMS
        (
         ClaimIDNo INT NULL
        ,ClaimNo VARCHAR(MAX) NULL
        ,DateLoss DATETIME NULL
        ,CV_Code VARCHAR(2) NULL
        ,DiaryIndex INT NULL
        ,LastSaved DATETIME NULL
        ,PolicyNumber VARCHAR(50) NULL
        ,PolicyHoldersName VARCHAR(30) NULL
        ,PaidDeductible MONEY NULL
        ,STATUS VARCHAR(1) NULL
        ,InUse VARCHAR(100) NULL
        ,CompanyID INT NULL
        ,OfficeIndex INT NULL
        ,AdjIdNo INT NULL
        ,PaidCoPay MONEY NULL
        ,AssignedUser VARCHAR(15) NULL
        ,Privatized SMALLINT NULL
        ,PolicyEffDate DATETIME NULL
        ,Deductible MONEY NULL
        ,LossState VARCHAR(2) NULL
        ,AssignedGroup INT NULL
        ,CreateDate DATETIME NULL
        ,LastChangedOn DATETIME NULL
        ,AllowMultiCoverage BIT NULL
        ,DmlOperation CHAR(1) NOT NULL
        );
END; 
GO
IF OBJECT_ID('stg.Claims_ClientRef', 'U') IS NOT NULL
DROP TABLE stg.Claims_ClientRef
BEGIN
	CREATE TABLE stg.Claims_ClientRef (
		ClaimIdNo INT NULL,
		ClientRefId VARCHAR(50) NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.CMS_Zip2Region', 'U') IS NOT NULL 
	DROP TABLE stg.CMS_Zip2Region  
BEGIN
	CREATE TABLE stg.CMS_Zip2Region
		(
		  StartDate DATETIME NULL,
		  EndDate DATETIME NULL,
		  ZIP_Code VARCHAR (5) NULL,
		  State VARCHAR (2) NULL,
		  Region VARCHAR (2) NULL,
		  AmbRegion VARCHAR (2) NULL,
		  RuralFlag SMALLINT NULL,
		  ASCRegion SMALLINT NULL,
		  PlusFour SMALLINT NULL,
		  CarrierId INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.CMT_DX', 'U') IS NOT NULL
DROP TABLE stg.CMT_DX
BEGIN
	CREATE TABLE stg.CMT_DX (
		BillIDNo INT NULL
		,DX VARCHAR(8) NULL
		,SeqNum SMALLINT NULL
		,POA VARCHAR(1) NULL
		,IcdVersion TINYINT NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END 
GO   
IF OBJECT_ID('stg.CMT_HDR', 'U') IS NOT NULL
DROP TABLE stg.CMT_HDR
BEGIN
	CREATE TABLE stg.CMT_HDR (
		CMT_HDR_IDNo INT NULL
		,CmtIDNo INT NULL
		,PvdIDNo INT NULL
		,LastChangedOn DATETIME NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.CMT_ICD9', 'U') IS NOT NULL
DROP TABLE stg.CMT_ICD9
BEGIN
	CREATE TABLE stg.CMT_ICD9 (
		BillIDNo INT NULL
		,SeqNo SMALLINT NULL
		,ICD9 VARCHAR(7) NULL
		,IcdVersion TINYINT NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.CoverageType', 'U') IS NOT NULL 
	DROP TABLE stg.CoverageType  
BEGIN
	CREATE TABLE stg.CoverageType
		(
		  LongName VARCHAR (30) NULL,
		  ShortName VARCHAR (2) NULL,
		  CbreCoverageTypeCode VARCHAR (2) NULL,
		  CoverageTypeCategoryCode VARCHAR(4) NULL,
		  PricingMethodId TINYINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.cpt_DX_DICT', 'U') IS NOT NULL
DROP TABLE stg.cpt_DX_DICT
BEGIN
	CREATE TABLE stg.cpt_DX_DICT (
		ICD9 VARCHAR(6) NULL
		,StartDate DATETIME NULL
		,EndDate DATETIME NULL
		,Flags SMALLINT NULL
		,NonSpecific VARCHAR(1) NULL
		,AdditionalDigits VARCHAR(1) NULL
		,Traumatic VARCHAR(1) NULL
		,DX_DESC VARCHAR(max) NULL
		,Duration SMALLINT NULL
		,Colossus SMALLINT NULL
		,DiagnosisFamilyId TINYINT NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.cpt_PRC_DICT', 'U') IS NOT NULL
DROP TABLE stg.cpt_PRC_DICT
BEGIN
	CREATE TABLE stg.cpt_PRC_DICT (
		PRC_CD VARCHAR(7) NULL
		,StartDate DATETIME NULL
		,EndDate DATETIME NULL
		,PRC_DESC VARCHAR(max) NULL
		,Flags INT NULL
		,Vague VARCHAR(1) NULL
		,PerVisit SMALLINT NULL
		,PerClaimant SMALLINT NULL
		,PerProvider SMALLINT NULL
		,BodyFlags INT NULL
		,Colossus SMALLINT NULL
		,CMS_Status VARCHAR(1) NULL
		,DrugFlag SMALLINT NULL
		,CurativeFlag SMALLINT NULL
		,ExclPolicyLimit SMALLINT NULL
		,SpecNetFlag SMALLINT NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.CreditReason', 'U') IS NOT NULL
DROP TABLE stg.CreditReason
BEGIN
	CREATE TABLE stg.CreditReason (
		CreditReasonId INT NULL
		,CreditReasonDesc VARCHAR(100) NULL
		,IsVisible BIT NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.CreditReasonOverrideENMap', 'U') IS NOT NULL
DROP TABLE stg.CreditReasonOverrideENMap
BEGIN
	CREATE TABLE stg.CreditReasonOverrideENMap (
		CreditReasonOverrideENMapId INT NULL
		,CreditReasonId INT NULL
		,OverrideEndnoteId SMALLINT NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.CriticalAccessHospitalInpatientRevenueCode', 'U') IS NOT NULL 
	DROP TABLE stg.CriticalAccessHospitalInpatientRevenueCode  
BEGIN
	CREATE TABLE stg.CriticalAccessHospitalInpatientRevenueCode
		(
		  RevenueCode VARCHAR (4) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.CTG_Endnotes', 'U') IS NOT NULL 
	DROP TABLE stg.CTG_Endnotes  
BEGIN
	CREATE TABLE stg.CTG_Endnotes
		(
		  Endnote INT NULL,
		  ShortDesc VARCHAR (50) NULL,
		  LongDesc VARCHAR (500) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.CustomBillStatuses', 'U') IS NOT NULL
DROP TABLE stg.CustomBillStatuses
BEGIN
	CREATE TABLE stg.CustomBillStatuses (
		StatusId INT NULL,
		StatusName VARCHAR(50) NULL,
		StatusDescription VARCHAR(300) NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO

IF OBJECT_ID('stg.CustomEndnote', 'U') IS NOT NULL
DROP TABLE stg.CustomEndnote
BEGIN
	CREATE TABLE stg.CustomEndnote (
		CustomEndnote INT NULL,
        ShortDescription VARCHAR(50) NULL,
        LongDescription VARCHAR(500) NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO


IF OBJECT_ID('stg.CustomerBillExclusion', 'U') IS NOT NULL
DROP TABLE stg.CustomerBillExclusion
BEGIN
	CREATE TABLE stg.CustomerBillExclusion (
		  BillIdNo int  NULL
	     ,Customer nvarchar(50)  NULL
	     ,ReportID tinyint  NULL
		 ,CreateDate datetime  NULL
		 ,DmlOperation CHAR(1)  NULL
		)
END
GO
IF OBJECT_ID('stg.DeductibleRuleCriteria', 'U') IS NOT NULL 
	DROP TABLE stg.DeductibleRuleCriteria  
BEGIN
	CREATE TABLE stg.DeductibleRuleCriteria
		(
		  DeductibleRuleCriteriaId INT NULL,
		  PricingRuleDateCriteriaId TINYINT NULL,
		  StartDate DATETIME NULL,
		  EndDate DATETIME NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.DeductibleRuleCriteriaCoverageType', 'U') IS NOT NULL 
	DROP TABLE stg.DeductibleRuleCriteriaCoverageType  
BEGIN
	CREATE TABLE stg.DeductibleRuleCriteriaCoverageType
		(
		  DeductibleRuleCriteriaId INT NULL,
		  CoverageType VARCHAR (5) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.DeductibleRuleExemptEndnote', 'U') IS NOT NULL 
	DROP TABLE stg.DeductibleRuleExemptEndnote  
BEGIN
	CREATE TABLE stg.DeductibleRuleExemptEndnote
		(
		  Endnote INT NULL,
		  EndnoteTypeId TINYINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.DemandClaimant', 'U') IS NOT NULL
DROP TABLE stg.DemandClaimant
BEGIN
	CREATE TABLE stg.DemandClaimant (
	   DemandClaimantId int NULL
	  ,ExternalClaimantId int NULL
	  ,OrganizationId nvarchar(100) NULL
	  ,HeightInInches smallint NULL
	  ,[Weight] smallint NULL
	  ,Occupation varchar(50) NULL
	  ,BiReportStatus smallint NULL
	  ,HasDemandPackage int NULL
	  ,FactsOfLoss varchar(250) NULL
	  ,PreExistingConditions varchar(100) NULL
	  ,Archived bit NULL
	  ,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.DemandPackage', 'U') IS NOT NULL
DROP TABLE stg.DemandPackage
BEGIN
	CREATE TABLE stg.DemandPackage (
	   DemandPackageId int NULL
	  ,DemandClaimantId int NULL
	  ,RequestedByUserName varchar(15) NULL
	  ,DateTimeReceived datetimeoffset(7) NULL
	  ,CorrelationId varchar(36) NULL
	  ,[PageCount] smallint NULL
	  ,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.DemandPackageRequestedService', 'U') IS NOT NULL
DROP TABLE stg.DemandPackageRequestedService
BEGIN
	CREATE TABLE stg.DemandPackageRequestedService (
		DemandPackageRequestedServiceId int NULL
	   ,DemandPackageId int NULL
	   ,ReviewRequestOptions nvarchar(max) NULL
	   ,DmlOperation CHAR(1) NOT NULL
		)
END
GO

IF OBJECT_ID('stg.DemandPackageUploadedFile', 'U') IS NOT NULL
DROP TABLE stg.DemandPackageUploadedFile
BEGIN
	CREATE TABLE stg.DemandPackageUploadedFile (
		DemandPackageUploadedFileId int NULL
	   ,DemandPackageId int NULL
	   ,[FileName] varchar(255) NULL
	   ,Size int NULL
	   ,DocStoreId varchar(50) NULL
	   ,DmlOperation CHAR(1) NOT NULL
		)
END
GO


IF OBJECT_ID('stg.DiagnosisCodeGroup', 'U') IS NOT NULL
DROP TABLE stg.DiagnosisCodeGroup
BEGIN
	CREATE TABLE stg.DiagnosisCodeGroup (
		DiagnosisCode VARCHAR(8) NULL
		,StartDate DATETIME NULL
		,EndDate DATETIME NULL
		,MajorCategory VARCHAR(500) NULL
		,MinorCategory VARCHAR(500) NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.EncounterType', 'U') IS NULL
    BEGIN
        CREATE TABLE stg.EncounterType
            (
			  EncounterTypeId TINYINT NULL
	           ,EncounterTypePriority TINYINT NULL
	           ,[Description] VARCHAR(100) NULL
	           ,NarrativeInformation VARCHAR(max) NULL
			 ,DmlOperation CHAR(1) NOT NULL
          	)
END
GO




IF OBJECT_ID('stg.EndnoteSubCategory', 'U') IS NOT NULL 
	DROP TABLE stg.EndnoteSubCategory  
BEGIN
	CREATE TABLE stg.EndnoteSubCategory
		(
		  EndnoteSubCategoryId TINYINT NULL,
		  Description VARCHAR (50) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.Esp_Ppo_Billing_Data_Self_Bill', 'U') IS NOT NULL 
	DROP TABLE stg.Esp_Ppo_Billing_Data_Self_Bill  
BEGIN
	CREATE TABLE stg.Esp_Ppo_Billing_Data_Self_Bill
		(
		  COMPANYCODE VARCHAR (10) NULL,
		  TRANSACTIONTYPE VARCHAR (10) NULL,
		  BILL_HDR_AMTALLOWED NUMERIC (15,2) NULL,
		  BILL_HDR_AMTCHARGED NUMERIC (15,2) NULL,
		  BILL_HDR_BILLIDNO INT NULL,
		  BILL_HDR_CMT_HDR_IDNO INT NULL,
		  BILL_HDR_CREATEDATE DATETIME NULL,
		  BILL_HDR_CV_TYPE VARCHAR (5) NULL,
		  BILL_HDR_FORM_TYPE VARCHAR (8) NULL,
		  BILL_HDR_NOLINES INT NULL,
		  BILLS_ALLOWED NUMERIC (15,2) NULL,
		  BILLS_ANALYZED NUMERIC (15,2) NULL,
		  BILLS_CHARGED NUMERIC (15,2) NULL,
		  BILLS_DT_SVC DATETIME NULL,
		  BILLS_LINE_NO INT NULL,
		  CLAIMANT_CLIENTREF_CMTSUFFIX VARCHAR (50) NULL,
		  CLAIMANT_CMTFIRST_NAME VARCHAR (50) NULL,
		  CLAIMANT_CMTIDNO VARCHAR (20) NULL,
		  CLAIMANT_CMTLASTNAME VARCHAR (60) NULL,
		  CMTSTATEOFJURISDICTION VARCHAR (2) NULL,
		  CLAIMS_COMPANYID INT NULL,
		  CLAIMS_CLAIMNO VARCHAR (50) NULL,
		  CLAIMS_DATELOSS DATETIME NULL,
		  CLAIMS_OFFICEINDEX INT NULL,
		  CLAIMS_POLICYHOLDERSNAME VARCHAR (100) NULL,
		  CLAIMS_POLICYNUMBER VARCHAR (50) NULL,
		  PNETWKEVENTLOG_EVENTID INT NULL,
		  PNETWKEVENTLOG_LOGDATE DATETIME NULL,
		  PNETWKEVENTLOG_NETWORKID INT NULL,
		  ACTIVITY_FLAG VARCHAR (1) NULL,
		  PPO_AMTALLOWED NUMERIC (15,2) NULL,
		  PREPPO_AMTALLOWED NUMERIC (15,2) NULL,
		  PREPPO_ALLOWED_FS VARCHAR (1) NULL,
		  PRF_COMPANY_COMPANYNAME VARCHAR (50) NULL,
		  PRF_OFFICE_OFCNAME VARCHAR (50) NULL,
		  PRF_OFFICE_OFCNO VARCHAR (25) NULL,
		  PROVIDER_PVDFIRSTNAME VARCHAR (60) NULL,
		  PROVIDER_PVDGROUP VARCHAR (60) NULL,
		  PROVIDER_PVDLASTNAME VARCHAR (60) NULL,
		  PROVIDER_PVDTIN VARCHAR (15) NULL,
		  PROVIDER_STATE VARCHAR (5) NULL,
		  UDFCLAIM_UDFVALUETEXT VARCHAR (255) NULL,
		  ENTRY_DATE DATETIME NULL,
		  UDFCLAIMANT_UDFVALUETEXT VARCHAR (255) NULL,
		  SOURCE_DB VARCHAR (20) NULL,
		  CLAIMS_CV_CODE VARCHAR (5) NULL,
		  VPN_TRANSACTIONID BIGINT NULL,
		  VPN_TRANSACTIONTYPEID INT NULL,
		  VPN_BILLIDNO INT NULL,
		  VPN_LINE_NO SMALLINT NULL,
		  VPN_CHARGED MONEY NULL,
		  VPN_DPALLOWED MONEY NULL,
		  VPN_VPNALLOWED MONEY NULL,
		  VPN_SAVINGS MONEY NULL,
		  VPN_CREDITS MONEY NULL,
		  VPN_HASOVERRIDE BIT NULL,
		  VPN_ENDNOTES NVARCHAR (200) NULL,
		  VPN_NETWORKIDNO INT NULL,
		  VPN_PROCESSFLAG SMALLINT NULL,
		  VPN_LINETYPE INT NULL,
		  VPN_DATETIMESTAMP DATETIME NULL,
		  VPN_SEQNO INT NULL,
		  VPN_VPN_REF_LINE_NO SMALLINT NULL,
		  VPN_NETWORKNAME VARCHAR (50) NULL,
		  VPN_SOJ VARCHAR (2) NULL,
		  VPN_CAT3 INT NULL,
		  VPN_PPODATESTAMP DATETIME NULL,
		  VPN_NINTEYDAYS INT NULL,
		  VPN_BILL_TYPE CHAR (1) NULL,
		  VPN_NET_SAVINGS MONEY NULL,
		  CREDIT BIT NULL,
		  RECON BIT NULL,
		  DELETED BIT NULL,
		  STATUS_FLAG VARCHAR (2) NULL,
		  DATE_SAVED DATETIME NULL,
		  SUB_NETWORK VARCHAR (50) NULL,
		  INVALID_CREDIT BIT NULL,
		  PROVIDER_SPECIALTY VARCHAR (50) NULL,
		  ADJUSTOR_IDNUMBER VARCHAR (25) NULL,
		  ACP_FLAG VARCHAR (1) NULL,
		  OVERRIDE_ENDNOTES VARCHAR (MAX) NULL,
		  OVERRIDE_ENDNOTES_DESC VARCHAR (MAX) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.ETL_ControlFiles', 'U') IS NOT NULL
DROP TABLE stg.ETL_ControlFiles
BEGIN
	CREATE TABLE stg.ETL_ControlFiles
		(ControlFileName VARCHAR(255) NOT NULL,
		 OltpPostingGroupAuditId INT NOT NULL,
		 SnapshotDate Datetime NOT NULL,
		 DataFileName VARCHAR(255) NOT NULL,
		 TargetTableName VARCHAR(100) NOT NULL,
		 RowsExtracted INT NULL,
		 TotalRowCount BIGINT NULL,
		 OdsVersion VARCHAR(20)
		 );
 END
 GO
 IF OBJECT_ID('stg.EvaluationSummary', 'U') IS NOT NULL 
	DROP TABLE stg.EvaluationSummary  
BEGIN
	CREATE TABLE stg.EvaluationSummary
		(
		  DemandClaimantId INT NULL,
		  Details NVARCHAR (MAX) NULL,
		  CreatedBy NVARCHAR (50) NULL,
		  CreatedDate DATETIMEOFFSET NULL,
		  ModifiedBy NVARCHAR (50) NULL,
		  ModifiedDate DATETIMEOFFSET NULL,
		  EvaluationSummaryTemplateVersionId INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.EvaluationSummaryHistory', 'U') IS NOT NULL 
	DROP TABLE stg.EvaluationSummaryHistory  
BEGIN
	CREATE TABLE stg.EvaluationSummaryHistory
		(
		  EvaluationSummaryHistoryId INT NULL,
		  DemandClaimantId INT NULL,
		  EvaluationSummary NVARCHAR (MAX) NULL,
		  CreatedBy NVARCHAR (50) NULL,
		  CreatedDate DATETIMEOFFSET NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.EvaluationSummaryTemplateVersion', 'U') IS NOT NULL 
	DROP TABLE stg.EvaluationSummaryTemplateVersion  
BEGIN
	CREATE TABLE stg.EvaluationSummaryTemplateVersion
		(
		  EvaluationSummaryTemplateVersionId INT NULL,
		  Template NVARCHAR (MAX) NULL,
		  TemplateHash VARBINARY(32) NULL,
		  CreatedDate DATETIMEOFFSET NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.EventLog', 'U') IS NOT NULL
DROP TABLE stg.EventLog
BEGIN
	CREATE TABLE stg.EventLog (
	   EventLogId int NULL
      ,ObjectName varchar(50) NULL
      ,ObjectId int NULL
      ,UserName varchar(15) NULL
      ,LogDate datetimeoffset(7) NULL
      ,ActionName varchar(20) NULL
      ,OrganizationId nvarchar(100) NULL
	  ,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.EventLogDetail', 'U') IS NOT NULL
DROP TABLE stg.EventLogDetail
BEGIN
	CREATE TABLE stg.EventLogDetail (
	   EventLogDetailId int NULL
	  ,EventLogId int NULL
	  ,PropertyName varchar(50) NULL
	  ,OldValue varchar(max) NULL
	  ,NewValue varchar(max) NULL
	  ,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.ExtractCat', 'U') IS NOT NULL
DROP TABLE stg.ExtractCat
BEGIN
	CREATE TABLE stg.ExtractCat (
		CatIdNo INT NULL
		,Description VARCHAR(50) NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.GeneralInterestRuleBaseType', 'U') IS NOT NULL
    DROP TABLE stg.GeneralInterestRuleBaseType;

CREATE TABLE stg.GeneralInterestRuleBaseType
(
    GeneralInterestRuleBaseTypeId TINYINT NULL,
    GeneralInterestRuleBaseTypeName VARCHAR(50) NULL,
    DmlOperation CHAR(1) NOT NULL
);

GO
IF OBJECT_ID('stg.GeneralInterestRuleSetting', 'U') IS NOT NULL
    DROP TABLE stg.GeneralInterestRuleSetting;
BEGIN
    CREATE TABLE stg.GeneralInterestRuleSetting
        (
         GeneralInterestRuleBaseTypeId TINYINT NULL
        ,DmlOperation CHAR(1) NOT NULL
        );
END;
GO

IF OBJECT_ID('stg.Icd10DiagnosisVersion', 'U') IS NOT NULL
DROP TABLE stg.Icd10DiagnosisVersion
BEGIN
	CREATE TABLE stg.Icd10DiagnosisVersion (
		DiagnosisCode VARCHAR(8) NULL
		,StartDate DATETIME NULL
		,EndDate DATETIME NULL
		,NonSpecific BIT NULL
		,Traumatic BIT NULL
		,Duration SMALLINT NULL
		,Description VARCHAR(max) NULL
		,DiagnosisFamilyId TINYINT NULL
		,TotalCharactersRequired TINYINT NULL
		,PlaceholderRequired BIT NULL 
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.ICD10ProcedureCode', 'U') IS NOT NULL
DROP TABLE stg.ICD10ProcedureCode
BEGIN
	CREATE TABLE stg.ICD10ProcedureCode (
		ICDProcedureCode VARCHAR(7) NULL
		,StartDate DATETIME NULL
		,EndDate DATETIME NULL
		,Description VARCHAR(300) NULL
		,PASGrpNo SMALLINT NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO   
IF OBJECT_ID('stg.IcdDiagnosisCodeDictionary', 'U') IS NOT NULL
DROP TABLE stg.IcdDiagnosisCodeDictionary
BEGIN
	CREATE TABLE stg.IcdDiagnosisCodeDictionary (
	   DiagnosisCode VARCHAR(8) NULL
	   ,IcdVersion TINYINT NULL
	   ,StartDate DATETIME2(7) NULL
	   ,EndDate DATETIME2(7) NULL
	   ,NonSpecific BIT NULL
	   ,Traumatic BIT NULL
	   ,Duration TINYINT NULL
	   ,[Description] VARCHAR(max) NULL
	   ,DiagnosisFamilyId TINYINT NULL
	   ,DiagnosisSeverityId TINYINT NULL
	   ,LateralityId TINYINT NULL
	   ,TotalCharactersRequired TINYINT NULL
	   ,PlaceholderRequired BIT NULL
	   ,Flags SMALLINT NULL
	   ,AdditionalDigits BIT NULL
	   ,Colossus SMALLINT NULL
	   ,InjuryNatureId TINYINT NULL
	   ,EncounterSubcategoryId TINYINT NULL
	   ,DmlOperation CHAR(1) NOT NULL
		)
END
GO





IF OBJECT_ID('stg.IcdDiagnosisCodeDictionaryBodyPart', 'U') IS NOT NULL 
	DROP TABLE stg.IcdDiagnosisCodeDictionaryBodyPart  
BEGIN
	CREATE TABLE stg.IcdDiagnosisCodeDictionaryBodyPart
		(
		  DiagnosisCode VARCHAR (8) NULL,
		  IcdVersion TINYINT NULL,
		  StartDate DATETIME2 (7) NULL,
		  NcciBodyPartId TINYINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.InjuryNature', 'U') IS NULL
    BEGIN
        CREATE TABLE stg.InjuryNature
            (
			  InjuryNatureId TINYINT NULL
	           ,InjuryNaturePriority TINYINT NULL
	           ,[Description] VARCHAR(100) NULL
	           ,NarrativeInformation VARCHAR(max) NULL
			 ,DmlOperation CHAR(1) NOT NULL
          	)
END
GO




IF OBJECT_ID('stg.lkp_SPC', 'U') IS NOT NULL 
	DROP TABLE stg.lkp_SPC  
BEGIN
	CREATE TABLE stg.lkp_SPC
		(
		  lkp_SpcId INT NULL,
		  LongName VARCHAR (50) NULL,
		  ShortName VARCHAR (4) NULL,
		  Mult MONEY NULL,
		  NCD92 SMALLINT NULL,
		  NCD93 SMALLINT NULL,
		  PlusFour SMALLINT NULL,
		  CbreSpecialtyCode VARCHAR (12) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.lkp_TS', 'U') IS NOT NULL 
	DROP TABLE stg.lkp_TS  
BEGIN
	CREATE TABLE stg.lkp_TS
		(
		  ShortName VARCHAR (2) NULL,
		  StartDate DATETIME2 (7) NULL,
		  EndDate DATETIME2 (7) NULL,
		  LongName VARCHAR (100) NULL,
		  GLOBAL SMALLINT NULL,
		  AnesMedDirect SMALLINT NULL,
		  AffectsPricing SMALLINT NULL,
		  IsAssistantSurgery BIT NULL,
		  IsCoSurgeon BIT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.ManualProvider', 'U') IS NOT NULL 
	DROP TABLE stg.ManualProvider  
BEGIN
	CREATE TABLE stg.ManualProvider
		(
		  ManualProviderId INT NULL,
		  TIN VARCHAR (15) NULL,
		  LastName VARCHAR (60) NULL,
		  FirstName VARCHAR (35) NULL,
		  GroupName VARCHAR (60) NULL,
		  Address1 VARCHAR (55) NULL,
		  Address2 VARCHAR (55) NULL,
		  City VARCHAR (30) NULL,
		  State VARCHAR (2) NULL,
		  Zip VARCHAR (12) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.ManualProviderSpecialty', 'U') IS NOT NULL 
	DROP TABLE stg.ManualProviderSpecialty  
BEGIN
	CREATE TABLE stg.ManualProviderSpecialty
		(
		  ManualProviderId INT NULL,
		  Specialty VARCHAR (12) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.MedicalCodeCutOffs', 'U') IS NOT NULL
DROP TABLE stg.MedicalCodeCutOffs
BEGIN
	CREATE TABLE stg.MedicalCodeCutOffs (
		CodeTypeID INT NULL
       ,CodeType VARCHAR(50) NULL
       ,Code VARCHAR(50) NULL
       ,FormType VARCHAR(10) NULL
       ,MaxChargedPerUnit FLOAT NULL
       ,MaxUnitsPerEncounter FLOAT NULL
	   ,DmlOperation CHAR(1) NOT NULL
		)
END
GO

IF OBJECT_ID('stg.MedicareStatusIndicatorRule', 'U') IS NOT NULL
DROP TABLE stg.MedicareStatusIndicatorRule
BEGIN
	CREATE TABLE stg.MedicareStatusIndicatorRule (
		MedicareStatusIndicatorRuleId INT NULL ,
        MedicareStatusIndicatorRuleName VARCHAR(50) NULL ,
        StatusIndicator VARCHAR(500) NULL ,
	    StartDate DATETIME2(7) NULL,
	    EndDate DATETIME2(7) NULL,
	    Endnote INT NULL,
	    EditActionId TINYINT NULL,
	    Comments VARCHAR(1000) NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO



IF OBJECT_ID('stg.MedicareStatusIndicatorRuleCoverageType', 'U') IS NOT NULL
DROP TABLE stg.MedicareStatusIndicatorRuleCoverageType
BEGIN
	CREATE TABLE stg.MedicareStatusIndicatorRuleCoverageType (
		MedicareStatusIndicatorRuleId INT NULL,
        ShortName VARCHAR(2) NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO


IF OBJECT_ID('stg.MedicareStatusIndicatorRulePlaceOfService', 'U') IS NOT NULL 
	DROP TABLE stg.MedicareStatusIndicatorRulePlaceOfService  
BEGIN
	CREATE TABLE stg.MedicareStatusIndicatorRulePlaceOfService
		(
		  MedicareStatusIndicatorRuleId INT NULL,
		  PlaceOfService VARCHAR (4) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO


IF OBJECT_ID('stg.MedicareStatusIndicatorRuleProcedureCode', 'U') IS NOT NULL
DROP TABLE stg.MedicareStatusIndicatorRuleProcedureCode
BEGIN
	CREATE TABLE stg.MedicareStatusIndicatorRuleProcedureCode (
		MedicareStatusIndicatorRuleId INT NULL,
        ProcedureCode VARCHAR(7) NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO



IF OBJECT_ID('stg.MedicareStatusIndicatorRuleProviderSpecialty', 'U') IS NOT NULL
DROP TABLE stg.MedicareStatusIndicatorRuleProviderSpecialty
BEGIN
	CREATE TABLE stg.MedicareStatusIndicatorRuleProviderSpecialty (
		MedicareStatusIndicatorRuleId INT NULL,
        ProviderSpecialty VARCHAR(6) NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO


IF OBJECT_ID('stg.ModifierByState', 'U') IS NOT NULL 
	DROP TABLE stg.ModifierByState  
BEGIN
	CREATE TABLE stg.ModifierByState
		(
		  State VARCHAR (2) NULL,
		  ProcedureServiceCategoryId TINYINT NULL,
		  ModifierDictionaryId INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.ModifierDictionary', 'U') IS NOT NULL 
	DROP TABLE stg.ModifierDictionary  
BEGIN
	CREATE TABLE stg.ModifierDictionary
		(
		  ModifierDictionaryId INT NULL,
		  Modifier VARCHAR (2) NULL,
		  StartDate DATETIME2 (7) NULL,
		  EndDate DATETIME2 (7) NULL,
		  Description VARCHAR (100) NULL,
		  Global BIT NULL,
		  AnesMedDirect BIT NULL,
		  AffectsPricing BIT NULL,
		  IsCoSurgeon BIT NULL,
		  IsAssistantSurgery BIT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.ModifierToProcedureCode', 'U') IS NOT NULL 
	DROP TABLE stg.ModifierToProcedureCode  
BEGIN
	CREATE TABLE stg.ModifierToProcedureCode
		(
		  ProcedureCode VARCHAR (5) NULL,
		  Modifier VARCHAR (2) NULL,
		  StartDate DATETIME2 (7) NULL,
		  EndDate DATETIME2 (7) NULL,
		  SojFlag SMALLINT NULL,
		  RequiresGuidelineReview BIT NULL,
		  Reference VARCHAR (255) NULL,
		  Comments VARCHAR (255) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.NcciBodyPart', 'U') IS NOT NULL 
	DROP TABLE stg.NcciBodyPart  
BEGIN
	CREATE TABLE stg.NcciBodyPart
		(
		  NcciBodyPartId TINYINT NULL,
		  Description VARCHAR (100) NULL,
		  NarrativeInformation VARCHAR (MAX) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.NcciBodyPartToHybridBodyPartTranslation', 'U') IS NOT NULL 
	DROP TABLE stg.NcciBodyPartToHybridBodyPartTranslation  
BEGIN
	CREATE TABLE stg.NcciBodyPartToHybridBodyPartTranslation
		(
		  NcciBodyPartId TINYINT NULL,
		  HybridBodyPartId SMALLINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.Note', 'U') IS NOT NULL
DROP TABLE stg.Note
BEGIN
	CREATE TABLE stg.Note (
	   NoteId int NULL
      ,DateCreated datetimeoffset(7) NULL
      ,DateModified datetimeoffset(7) NULL
      ,CreatedBy varchar(15) NULL
      ,ModifiedBy varchar(15) NULL
      ,Flag tinyint NULL
      ,Content varchar(250) NULL
      ,NoteContext smallint NULL
      ,DemandClaimantId int NULL
	  ,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.ny_pharmacy', 'U') IS NOT NULL
DROP TABLE stg.ny_pharmacy
BEGIN
	CREATE TABLE stg.ny_pharmacy (
		NDCCode VARCHAR(13) NULL
		,StartDate DATETIME NULL
		,EndDate DATETIME NULL
		,Description VARCHAR(125) NULL
		,Fee MONEY NULL
		,TypeOfDrug SMALLINT NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.ny_Specialty', 'U') IS NOT NULL 
	DROP TABLE stg.ny_Specialty  
BEGIN
	CREATE TABLE stg.ny_Specialty
		(
		  RatingCode VARCHAR (12) NULL,
		  Desc_ VARCHAR (70) NULL,
		  CbreSpecialtyCode VARCHAR (12) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.pa_PlaceOfService', 'U') IS NOT NULL
DROP TABLE stg.pa_PlaceOfService
BEGIN
	CREATE TABLE stg.pa_PlaceOfService (
		POS SMALLINT NULL,
		Description VARCHAR(255) NULL,
		Facility SMALLINT NULL,
		MHL SMALLINT NULL,
		PlusFour SMALLINT NULL,
		Institution INT NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.PlaceOfServiceDictionary','U') IS NOT NULL
DROP TABLE stg.PlaceOfServiceDictionary
BEGIN
	CREATE TABLE stg.PlaceOfServiceDictionary (
		PlaceOfServiceCode SMALLINT NULL
	    ,[Description] VARCHAR(255) NULL
	    ,Facility SMALLINT NULL
	    ,MHL SMALLINT NULL
	    ,PlusFour SMALLINT NULL
	    ,Institution INT NULL
	    ,StartDate DATETIME2(7) NULL
	    ,EndDate DATETIME2(7) NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END 
GO


IF OBJECT_ID('stg.PrePPOBillInfo', 'U') IS NOT NULL 
	DROP TABLE stg.PrePPOBillInfo  
BEGIN
	CREATE TABLE stg.PrePPOBillInfo
		(
		  DateSentToPPO DATETIME NULL,
		  ClaimNo VARCHAR (50) NULL,
		  ClaimIDNo INT NULL,
		  CompanyID INT NULL,
		  OfficeIndex INT NULL,
		  CV_Code VARCHAR (2) NULL,
		  DateLoss DATETIME NULL,
		  Deductible MONEY NULL,
		  PaidCoPay MONEY NULL,
		  PaidDeductible MONEY NULL,
		  LossState VARCHAR (2) NULL,
		  CmtIDNo INT NULL,
		  CmtCoPaymentMax MONEY NULL,
		  CmtCoPaymentPercentage SMALLINT NULL,
		  CmtDedType SMALLINT NULL,
		  CmtDeductible MONEY NULL,
		  CmtFLCopay SMALLINT NULL,
		  CmtPolicyLimit MONEY NULL,
		  CmtStateOfJurisdiction VARCHAR (2) NULL,
		  PvdIDNo INT NULL,
		  PvdTIN VARCHAR (15) NULL,
		  PvdSPC_List VARCHAR (50) NULL,
		  PvdTitle VARCHAR (5) NULL,
		  PvdFlags INT NULL,
		  DateSaved DATETIME NULL,
		  DateRcv DATETIME NULL,
		  InvoiceDate DATETIME NULL,
		  NoLines SMALLINT NULL,
		  AmtCharged MONEY NULL,
		  AmtAllowed MONEY NULL,
		  Region VARCHAR (50) NULL,
		  FeatureID INT NULL,
		  Flags INT NULL,
		  WhoCreate VARCHAR (15) NULL,
		  WhoLast VARCHAR (15) NULL,
		  CmtPaidDeductible MONEY NULL,
		  InsPaidLimit MONEY NULL,
		  StatusFlag VARCHAR (2) NULL,
		  CmtPaidCoPay MONEY NULL,
		  Category INT NULL,
		  CatDesc VARCHAR (1000) NULL,
		  CreateDate DATETIME NULL,
		  PvdZOS VARCHAR (12) NULL,
		  AdmissionDate DATETIME NULL,
		  DischargeDate DATETIME NULL,
		  DischargeStatus SMALLINT NULL,
		  TypeOfBill VARCHAR (4) NULL,
		  PaymentDecision SMALLINT NULL,
		  PPONumberSent SMALLINT NULL,
		  BillIDNo INT NULL,
		  LINE_NO SMALLINT NULL,
		  LINE_NO_DISP SMALLINT NULL,
		  OVER_RIDE SMALLINT NULL,
		  DT_SVC DATETIME NULL,
		  PRC_CD VARCHAR (7) NULL,
		  UNITS REAL NULL,
		  TS_CD VARCHAR (14) NULL,
		  CHARGED MONEY NULL,
		  ALLOWED MONEY NULL,
		  ANALYZED MONEY NULL,
		  REF_LINE_NO SMALLINT NULL,
		  SUBNET VARCHAR (9) NULL,
		  FEE_SCHEDULE MONEY NULL,
		  POS_RevCode VARCHAR (4) NULL,
		  CTGPenalty MONEY NULL,
		  PrePPOAllowed MONEY NULL,
		  PPODate DATETIME NULL,
		  PPOCTGPenalty MONEY NULL,
		  UCRPerUnit MONEY NULL,
		  FSPerUnit MONEY NULL,
		  HCRA_Surcharge MONEY NULL,
		  NDC VARCHAR (13) NULL,
		  PriceTypeCode VARCHAR (2) NULL,
		  PharmacyLine SMALLINT NULL,
		  Endnotes VARCHAR (50) NULL,
		  SentryEN VARCHAR (250) NULL,
		  CTGEN VARCHAR (250) NULL,
		  CTGRuleType VARCHAR (250) NULL,
		  CTGRuleID VARCHAR (250) NULL,
		  OverrideEN VARCHAR (50) NULL,
		  UserId INT NULL,
		  DateOverriden DATETIME NULL,
		  AmountBeforeOverride MONEY NULL,
		  AmountAfterOverride MONEY NULL,
		  CodesOverriden VARCHAR (50) NULL,
		  NetworkID INT NULL,
		  BillSnapshot VARCHAR (30) NULL,
		  PPOSavings MONEY NULL,
		  RevisedDate DATETIME NULL,
		  ReconsideredDate DATETIME NULL,
		  TierNumber SMALLINT NULL,
		  PPOBillInfoID INT NULL,
		  PrePPOBillInfoID INT NULL,
		  CtgCoPayPenalty DECIMAL (19,4) NULL,
		  PpoCtgCoPayPenaltyPercentage DECIMAL (19,4) NULL,
		  CtgVunPenalty DECIMAL (19,4) NULL,
		  PpoCtgVunPenaltyPercentage DECIMAL (19,4) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.prf_COMPANY', 'U') IS NOT NULL
DROP TABLE stg.prf_COMPANY
BEGIN
	CREATE TABLE stg.prf_COMPANY (
		CompanyId INT NULL
		,CompanyName VARCHAR(50) NULL
		,LastChangedOn DATETIME NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.prf_CTGMaxPenaltyLines', 'U') IS NOT NULL 
	DROP TABLE stg.prf_CTGMaxPenaltyLines  
BEGIN
	CREATE TABLE stg.prf_CTGMaxPenaltyLines
		(
		  CTGMaxPenLineID INT NULL,
		  ProfileId INT NULL,
		  DatesBasedOn SMALLINT NULL,
		  MaxPenaltyPercent SMALLINT NULL,
		  StartDate DATETIME NULL,
		  EndDate DATETIME NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.prf_CTGPenalty', 'U') IS NOT NULL 
	DROP TABLE stg.prf_CTGPenalty  
BEGIN
	CREATE TABLE stg.prf_CTGPenalty
		(
		  CTGPenID INT NULL,
		  ProfileId INT NULL,
		  ApplyPreCerts SMALLINT NULL,
		  NoPrecertLogged SMALLINT NULL,
		  MaxTotalPenalty SMALLINT NULL,
		  TurnTimeForAppeals SMALLINT NULL,
		  ApplyEndnoteForPercert SMALLINT NULL,
		  ApplyEndnoteForCarePath SMALLINT NULL,
		  ExemptPrecertPenalty SMALLINT NULL,
		  ApplyNetworkPenalty BIT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.prf_CTGPenaltyHdr', 'U') IS NOT NULL 
	DROP TABLE stg.prf_CTGPenaltyHdr  
BEGIN
	CREATE TABLE stg.prf_CTGPenaltyHdr
		(
		  CTGPenHdrID INT NULL,
		  ProfileId INT NULL,
		  PenaltyType SMALLINT NULL,
		  PayNegRate SMALLINT NULL,
		  PayPPORate SMALLINT NULL,
		  DatesBasedOn SMALLINT NULL,
		  ApplyPenaltyToPharmacy BIT NULL,
		  ApplyPenaltyCondition BIT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.prf_CTGPenaltyLines', 'U') IS NOT NULL 
	DROP TABLE stg.prf_CTGPenaltyLines  
BEGIN
	CREATE TABLE stg.prf_CTGPenaltyLines
		(
		  CTGPenLineID INT NULL,
		  ProfileId INT NULL,
		  PenaltyType SMALLINT NULL,
		  FeeSchedulePercent SMALLINT NULL,
		  StartDate DATETIME NULL,
		  EndDate DATETIME NULL,
		  TurnAroundTime SMALLINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.Prf_CustomIcdAction', 'U') IS NOT NULL 
	DROP TABLE stg.Prf_CustomIcdAction  
BEGIN
	CREATE TABLE stg.Prf_CustomIcdAction
		(
		  CustomIcdActionId INT NULL,
		  ProfileId INT NULL,
		  IcdVersionId TINYINT NULL,
		  Action SMALLINT NULL,
		  StartDate DATETIME NULL,
		  EndDate DATETIME NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.prf_Office', 'U') IS NOT NULL
    DROP TABLE stg.prf_Office;
BEGIN
    CREATE TABLE stg.prf_Office
        (
         CompanyId INT NULL
        ,OfficeId INT NULL
        ,OfcNo VARCHAR(4) NULL
        ,OfcName VARCHAR(40) NULL
        ,OfcAddr1 VARCHAR(30) NULL
        ,OfcAddr2 VARCHAR(30) NULL
        ,OfcCity VARCHAR(30) NULL
        ,OfcState VARCHAR(2) NULL
        ,OfcZip VARCHAR(12) NULL
        ,OfcPhone VARCHAR(20) NULL
        ,OfcDefault SMALLINT NULL
        ,OfcClaimMask VARCHAR(50) NULL
        ,OfcTinMask VARCHAR(50) NULL
        ,Version SMALLINT NULL
        ,OfcEdits INT NULL
        ,OfcCOAEnabled SMALLINT NULL
        ,CTGEnabled SMALLINT NULL
        ,LastChangedOn DATETIME NULL
        ,AllowMultiCoverage BIT NULL
        ,DmlOperation CHAR(1) NOT NULL
        );
END;
GO
IF OBJECT_ID('stg.Prf_OfficeUDF', 'U') IS NOT NULL
    DROP TABLE stg.Prf_OfficeUDF;
BEGIN
    CREATE TABLE stg.Prf_OfficeUDF
        (
          OfficeId INT NULL ,
          UDFIdNo INT NULL ,
		  DmlOperation CHAR(1) NOT NULL
        );
END
GO
IF OBJECT_ID('stg.prf_PPO', 'U') IS NOT NULL 
	DROP TABLE stg.prf_PPO  
BEGIN
	CREATE TABLE stg.prf_PPO
		(
		  PPOSysId INT NULL,
		  ProfileId INT NULL,
		  PPOId INT NULL,
		  bStatus SMALLINT NULL,
		  StartDate DATETIME NULL,
		  EndDate DATETIME NULL,
		  AutoSend SMALLINT NULL,
		  AutoResend SMALLINT NULL,
		  BypassMatching SMALLINT NULL,
		  UseProviderNetworkEnrollment SMALLINT NULL,
		  TieredTypeId SMALLINT NULL,
		  Priority SMALLINT NULL,
		  PolicyEffectiveDate DATETIME NULL,
		  BillFormType INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.prf_Profile', 'U') IS NOT NULL 
	DROP TABLE stg.prf_Profile  
BEGIN
	CREATE TABLE stg.prf_Profile
		(
			ProfileId INT NULL,
			OfficeId INT NULL,
			CoverageId VARCHAR(2) NULL,
			StateId VARCHAR(2) NULL,
			AnHeader VARCHAR(MAX) NULL,
			AnFooter VARCHAR(MAX) NULL,
			ExHeader VARCHAR(MAX) NULL,
			ExFooter VARCHAR(MAX) NULL,
			AnalystEdits BIGINT NULL,
			DxEdits INT NULL,
			DxNonTraumaDays INT NULL,
			DxNonSpecDays INT NULL,
			PrintCopies INT NULL,
			NewPvdState VARCHAR(2) NULL,
			bDuration SMALLINT NULL,
			bLimits SMALLINT NULL,
			iDurPct SMALLINT NULL,
			iLimitPct SMALLINT NULL,
			PolicyLimit MONEY NULL,
			CoPayPercent INT NULL,
			CoPayMax MONEY NULL,
			Deductible MONEY NULL,
			PolicyWarn SMALLINT NULL,
			PolicyWarnPerc INT NULL,
			FeeSchedules INT NULL,
			DefaultProfile SMALLINT NULL,
			FeeAncillaryPct SMALLINT NULL,
			iGapdol SMALLINT NULL,
			iGapTreatmnt SMALLINT NULL,
			bGapTreatmnt SMALLINT NULL,
			bGapdol SMALLINT NULL,
			bPrintAdjustor SMALLINT NULL,
			sPrinterName VARCHAR(50) NULL,
			ErEdits INT NULL,
			ErAllowedDays INT NULL,
			UcrFsRules INT NULL,
			LogoIdNo INT NULL,
			LogoJustify SMALLINT NULL,
			BillLine VARCHAR(50) NULL,
			Version SMALLINT NULL,
			ClaimDeductible SMALLINT NULL,
			IncludeCommitted SMALLINT NULL,
			FLMedicarePercent SMALLINT NULL,
			UseLevelOfServiceUrl SMALLINT NULL,
			LevelOfServiceURL VARCHAR(250) NULL,
			CCIPrimary SMALLINT NULL,
			CCISecondary SMALLINT NULL,
			CCIMutuallyExclusive SMALLINT NULL,
			CCIComprehensiveComponent SMALLINT NULL,
			PayDRGAllowance SMALLINT NULL,
			FLHospEmPriceOn SMALLINT NULL,
			EnableBillRelease SMALLINT NULL,
			DisableSubmitBill SMALLINT NULL,
			MaxPaymentsPerBill SMALLINT NULL,
			NoOfPmtPerBill INT NULL,
			DefaultDueDate SMALLINT NULL,
			CheckForNJCarePaths SMALLINT NULL,
			NJCarePathPercentFS SMALLINT NULL,
			ApplyEndnoteForNJCarePaths SMALLINT NULL,
			FLMedicarePercent2008 SMALLINT NULL,
			RequireEndnoteDuringOverride SMALLINT NULL,
			StorePerUnitFSandUCR SMALLINT NULL,
			UseProviderNetworkEnrollment SMALLINT NULL,
			UseASCRule SMALLINT NULL,
			AsstCoSurgeonEligible SMALLINT NULL,
			LastChangedOn datetime NULL,
			IsNJPhysMedCapAfterCTG SMALLINT NULL,
			IsEligibleAmtFeeBased SMALLINT NULL,
			HideClaimTreeTotalsGrid SMALLINT NULL,
			SortBillsBy SMALLINT NULL,
			SortBillsByOrder SMALLINT NULL,
			ApplyNJEmergencyRoomBenchmarkFee SMALLINT NULL,
			AllowIcd10ForNJCarePaths SMALLINT NULL,
			EnableOverrideDeductible BIT NULL,
			AnalyzeDiagnosisPointers BIT NULL,
			MedicareFeePercent SMALLINT NULL,
			EnableSupplementalNdcData BIT NULL,
			ApplyOriginalNdcAwp BIT NULL,
			NdcAwpNotAvailable TINYINT NULL,
			PayEapgAllowance SMALLINT NULL,
			MedicareInpatientApcEnabled BIT NULL,
			MedicareOutpatientAscEnabled BIT NULL,
			MedicareAscEnabled BIT NULL,
			UseMedicareInpatientApcFee BIT NULL,
			MedicareInpatientDrgEnabled BIT NULL,
			MedicareInpatientDrgPricingType SMALLINT NULL,
			MedicarePhysicianEnabled BIT NULL,
			MedicareAmbulanceEnabled BIT NULL,
			MedicareDmeposEnabled BIT NULL,
			MedicareAspDrugAndClinicalEnabled BIT NULL,
			MedicareInpatientPricingType SMALLINT NULL,
			MedicareOutpatientPricingRulesEnabled BIT NULL,
			MedicareAscPricingRulesEnabled BIT NULL,
			NjUseAdmitTypeEnabled BIT NULL,
			MedicareClinicalLabEnabled BIT NULL,
			MedicareInpatientEnabled BIT NULL,
			MedicareOutpatientApcEnabled BIT NULL,
			MedicareAspDrugEnabled BIT NULL,
			ShowAllocationsOnEob BIT NULL,
			EmergencyCarePricingRuleId TINYINT NULL,
			OutOfStatePricingEffectiveDateId TINYINT NULL,
			PreAllocation BIT NULL,
			AssistantCoSurgeonModifiers SMALLINT NULL,
			AssistantSurgeryModifierNotMedicallyNecessary SMALLINT NULL,
			AssistantSurgeryModifierRequireAdditionalDocument SMALLINT NULL,
			CoSurgeryModifierNotMedicallyNecessary SMALLINT NULL,
			CoSurgeryModifierRequireAdditionalDocument SMALLINT NULL,
			DxNoDiagnosisDays INT NULL,
			ModifierExempted BIT NULL,
		    DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO
IF OBJECT_ID('stg.ProcedureCodeGroup', 'U') IS NOT NULL
DROP TABLE stg.ProcedureCodeGroup
BEGIN
	CREATE TABLE stg.ProcedureCodeGroup (
		ProcedureCode VARCHAR(7) NULL
		,MajorCategory VARCHAR(500) NULL
		,MinorCategory VARCHAR(500) NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.ProcedureServiceCategory', 'U') IS NOT NULL 
	DROP TABLE stg.ProcedureServiceCategory  
BEGIN
	CREATE TABLE stg.ProcedureServiceCategory
		(
		  ProcedureServiceCategoryId TINYINT NULL,
		  ProcedureServiceCategoryName VARCHAR (50) NULL,
		  ProcedureServiceCategoryDescription VARCHAR (100) NULL,
		  LegacyTableName VARCHAR (100) NULL,
		  LegacyBitValue INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.ProvidedLink', 'U') IS NOT NULL 
	DROP TABLE stg.ProvidedLink  
BEGIN
	CREATE TABLE stg.ProvidedLink
		(
		  ProvidedLinkId INT NULL,
		  Title VARCHAR (100) NULL,
		  URL VARCHAR (150) NULL,
		  OrderIndex TINYINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.PROVIDER', 'U') IS NOT NULL 
	DROP TABLE stg.PROVIDER  
BEGIN
	CREATE TABLE stg.PROVIDER
		(
		  PvdIDNo INT NULL,
		  PvdMID INT NULL,
		  PvdSource SMALLINT NULL,
		  PvdTIN VARCHAR (15) NULL,
		  PvdLicNo VARCHAR (30) NULL,
		  PvdCertNo VARCHAR (30) NULL,
		  PvdLastName VARCHAR (60) NULL,
		  PvdFirstName VARCHAR (35) NULL,
		  PvdMI VARCHAR (1) NULL,
		  PvdTitle VARCHAR (5) NULL,
		  PvdGroup VARCHAR (60) NULL,
		  PvdAddr1 VARCHAR (55) NULL,
		  PvdAddr2 VARCHAR (55) NULL,
		  PvdCity VARCHAR (30) NULL,
		  PvdState VARCHAR (2) NULL,
		  PvdZip VARCHAR (12) NULL,
		  PvdZipPerf VARCHAR (12) NULL,
		  PvdPhone VARCHAR (25) NULL,
		  PvdFAX VARCHAR (13) NULL,
		  PvdSPC_List VARCHAR (MAX) NULL,
		  PvdAuthNo VARCHAR (30) NULL,
		  PvdSPC_ACD VARCHAR (2) NULL,
		  PvdUpdateCounter SMALLINT NULL,
		  PvdPPO_Provider SMALLINT NULL,
		  PvdFlags INT NULL,
		  PvdERRate MONEY NULL,
		  PvdSubNet VARCHAR (4) NULL,
		  InUse VARCHAR (100) NULL,
		  PvdStatus INT NULL,
		  PvdElectroStartDate DATETIME NULL,
		  PvdElectroEndDate DATETIME NULL,
		  PvdAccredStartDate DATETIME NULL,
		  PvdAccredEndDate DATETIME NULL,
		  PvdRehabStartDate DATETIME NULL,
		  PvdRehabEndDate DATETIME NULL,
		  PvdTraumaStartDate DATETIME NULL,
		  PvdTraumaEndDate DATETIME NULL,
		  OPCERT VARCHAR (7) NULL,
		  PvdDentalStartDate DATETIME NULL,
		  PvdDentalEndDate DATETIME NULL,
		  PvdNPINo VARCHAR (10) NULL,
		  PvdCMSId VARCHAR (6) NULL,
		  CreateDate DATETIME NULL,
		  LastChangedOn DATETIME NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.ProviderCluster', 'U') IS NOT NULL
    DROP TABLE stg.ProviderCluster;
BEGIN
    CREATE TABLE stg.ProviderCluster
        (
			PvdIDNo INT  NULL, 
			OrgOdsCustomerId INT  NULL,
			MitchellProviderKey VARCHAR(200) NULL,
			ProviderClusterKey VARCHAR(200) NULL,
			ProviderType VARCHAR(30) NULL,
			DmlOperation CHAR(1) NOT NULL
        )
END
GO

IF OBJECT_ID('stg.ProviderNetworkEventLog', 'U') IS NOT NULL
DROP TABLE stg.ProviderNetworkEventLog
BEGIN
CREATE TABLE stg.ProviderNetworkEventLog(
	IDField int NOT NULL,
	LogDate datetime NULL,
	EventId int NULL,
	ClaimIdNo int NULL,
	BillIdNo int NULL,
	UserId int NULL,
	NetworkId int NULL,
	FileName varchar(255) NULL,
	ExtraText varchar(1000) NULL,
	ProcessInfo smallint NULL,
	TieredTypeID smallint NULL,
	TierNumber smallint NULL,
	DmlOperation char(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.ProviderNumberCriteria', 'U') IS NOT NULL 
	DROP TABLE stg.ProviderNumberCriteria  
BEGIN
	CREATE TABLE stg.ProviderNumberCriteria
		(
		  ProviderNumberCriteriaId SMALLINT NULL,
		  ProviderNumber INT NULL,
		  Priority TINYINT NULL,
		  FeeScheduleTable CHAR (1) NULL,
		  StartDate DATETIME2 (7) NULL,
		  EndDate DATETIME2 (7) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.ProviderNumberCriteriaRevenueCode', 'U') IS NOT NULL 
	DROP TABLE stg.ProviderNumberCriteriaRevenueCode  
BEGIN
	CREATE TABLE stg.ProviderNumberCriteriaRevenueCode
		(
		  ProviderNumberCriteriaId SMALLINT NULL,
		  RevenueCode VARCHAR (4) NULL,
		  MatchingProfileNumber TINYINT NULL,
		  AttributeMatchTypeId TINYINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.ProviderNumberCriteriaTypeOfBill', 'U') IS NOT NULL 
	DROP TABLE stg.ProviderNumberCriteriaTypeOfBill  
BEGIN
	CREATE TABLE stg.ProviderNumberCriteriaTypeOfBill
		(
		  ProviderNumberCriteriaId SMALLINT NULL,
		  TypeOfBill VARCHAR (4) NULL,
		  MatchingProfileNumber TINYINT NULL,
		  AttributeMatchTypeId TINYINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.ProviderSpecialty', 'U') IS NOT NULL
DROP TABLE stg.ProviderSpecialty
BEGIN
	CREATE TABLE stg.ProviderSpecialty (
		ProviderId INT NULL,
        SpecialtyCode VARCHAR(50) NULL,       
		DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.ProviderSpecialtyToProvType', 'U') IS NOT NULL
DROP TABLE stg.ProviderSpecialtyToProvType
BEGIN
CREATE TABLE stg.ProviderSpecialtyToProvType(
	ProviderType VARCHAR(20) NULL,
	ProviderType_Desc VARCHAR(80) NULL,
	Specialty VARCHAR(20) NULL,
	Specialty_Desc VARCHAR(80) NULL,
	CreateDate DATETIME NULL,
	ModifyDate DATETIME NULL,
	LogicalDelete CHAR(1) NULL,
	DmlOperation CHAR(1) NULL
)
END
GO

IF OBJECT_ID('stg.Provider_ClientRef', 'U') IS NOT NULL
DROP TABLE stg.Provider_ClientRef
BEGIN
	CREATE TABLE stg.Provider_ClientRef (
			PvdIdNo INT NULL,
			ClientRefId VARCHAR(50) NULL,
			ClientRefId2 VARCHAR(100) NULL,
			DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.Provider_Rendering', 'U') IS NOT NULL
    DROP TABLE stg.Provider_Rendering;
BEGIN
    CREATE TABLE stg.Provider_Rendering
        (
          PvdIDNo INT NULL ,
          RenderingAddr1 VARCHAR(55) NULL ,
          RenderingAddr2 VARCHAR(55) NULL ,
          RenderingCity VARCHAR(30) NULL ,
          RenderingState VARCHAR(2) NULL ,
          RenderingZip VARCHAR(12) NULL ,
		  DmlOperation CHAR(1) NOT NULL
        );
END
GO

IF OBJECT_ID('stg.ReferenceBillApcLines', 'U') IS NOT NULL
	DROP TABLE stg.ReferenceBillApcLines

BEGIN
	CREATE TABLE stg.ReferenceBillApcLines
	(		
		BillIdNo INT NULL,
		Line_No SMALLINT NULL,
		PaymentAPC VARCHAR(5) NULL,
		ServiceIndicator VARCHAR(2) NULL,
		PaymentIndicator VARCHAR(1) NULL,
		OutlierAmount DECIMAL(19,4) NULL,
		PricerAllowed DECIMAL(19,4) NULL,
		MedicareAmount DECIMAL(19,4) NULL,
		DmlOperation CHAR(1) NOT NULL 
	)
END

GO

IF OBJECT_ID('stg.ReferenceSupplementBillApcLines', 'U') IS NOT NULL
	DROP TABLE stg.ReferenceSupplementBillApcLines

BEGIN
	CREATE TABLE stg.ReferenceSupplementBillApcLines (	
		BillIdNo INT NULL,
		SeqNo SMALLINT NULL,
		Line_No SMALLINT NULL,
		PaymentAPC VARCHAR(5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		ServiceIndicator VARCHAR(2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		PaymentIndicator VARCHAR(1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		OutlierAmount DECIMAL(19,4) NULL,
		PricerAllowed DECIMAL(19,4) NULL,
		MedicareAmount DECIMAL(19,4) NULL,
		DmlOperation CHAR(1) NOT NULL 
		)
END

GO
IF OBJECT_ID('stg.RenderingNpiStates', 'U') IS NOT NULL 
	DROP TABLE stg.RenderingNpiStates  
BEGIN
	CREATE TABLE stg.RenderingNpiStates
		(
		  ApplicationSettingsId INT NULL,
		  State VARCHAR (2) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.RevenueCode', 'U') IS NOT NULL 
	DROP TABLE stg.RevenueCode  
BEGIN
	CREATE TABLE stg.RevenueCode
		(
		  RevenueCode VARCHAR (4) NULL,
		  RevenueCodeSubCategoryId TINYINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.RevenueCodeCategory', 'U') IS NOT NULL
DROP TABLE stg.RevenueCodeCategory
BEGIN
	CREATE TABLE stg.RevenueCodeCategory	(
		RevenueCodeCategoryId TINYINT  NULL,
		Description VARCHAR(100) NULL,
		NarrativeInformation VARCHAR(1000) NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.RevenueCodeSubcategory', 'U') IS NOT NULL
DROP TABLE stg.RevenueCodeSubcategory;
BEGIN
	CREATE TABLE stg.RevenueCodeSubcategory(
		RevenueCodeSubcategoryId TINYINT NULL,
		RevenueCodeCategoryId TINYINT NULL,
		Description VARCHAR(100) NULL,
		NarrativeInformation VARCHAR(1000) NULL,
		DmlOperation CHAR(1) NOT NULL 
		)
END
GO
IF OBJECT_ID('stg.RPT_RsnCategories', 'U') IS NOT NULL
DROP TABLE stg.RPT_RsnCategories
BEGIN
	CREATE TABLE stg.RPT_RsnCategories (
		CategoryIdNo SMALLINT NULL,
		CatDesc VARCHAR(50) NULL,
		Priority SMALLINT NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO


IF OBJECT_ID('stg.rsn_Override', 'U') IS NOT NULL
DROP TABLE stg.rsn_Override
BEGIN
	CREATE TABLE stg.rsn_Override (
		ReasonNumber INT NULL
		,ShortDesc VARCHAR(50) NULL
		,LongDesc VARCHAR(MAX) NULL
		,CategoryIdNo SMALLINT NULL
		,ClientSpec SMALLINT NULL
		,COAIndex SMALLINT NULL
		,NJPenaltyPct DECIMAL(9, 6) NULL
		,NetworkID INT NULL
		,SpecialProcessing BIT NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.rsn_REASONS', 'U') IS NOT NULL
    DROP TABLE stg.rsn_REASONS;
BEGIN
    CREATE TABLE stg.rsn_REASONS
        (
         ReasonNumber INT NULL
        ,CV_Type VARCHAR(2) NULL
        ,ShortDesc VARCHAR(50) NULL
        ,LongDesc VARCHAR(MAX) NULL
        ,CategoryIdNo INT NULL
        ,COAIndex SMALLINT NULL
        ,OverrideEndnote INT NULL
        ,HardEdit SMALLINT NULL
        ,SpecialProcessing BIT NULL
        ,EndnoteActionId TINYINT NULL
        ,RetainForEapg BIT NULL
        ,DmlOperation CHAR(1) NOT NULL
        );
END;
GO
IF OBJECT_ID('stg.Rsn_Reasons_3rdParty', 'U') IS NOT NULL
	DROP TABLE stg.Rsn_Reasons_3rdParty
BEGIN
	CREATE TABLE stg.Rsn_Reasons_3rdParty 
		(
		ReasonNumber INT NULL,
		ShortDesc VARCHAR(50) NULL,
		LongDesc VARCHAR(MAX) NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.RuleType', 'U') IS NOT NULL 
	DROP TABLE stg.RuleType  
BEGIN
	CREATE TABLE stg.RuleType
		(
		  RuleTypeID INT NULL,
		  Name VARCHAR (50) NULL,
		  Description VARCHAR (150) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.ScriptAdvisorBillSource', 'U') IS NOT NULL 
	DROP TABLE stg.ScriptAdvisorBillSource  
BEGIN
	CREATE TABLE stg.ScriptAdvisorBillSource
		(
		  BillSourceId TINYINT NULL,
		  BillSource VARCHAR (15) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.ScriptAdvisorSettings', 'U') IS NOT NULL 
	DROP TABLE stg.ScriptAdvisorSettings  
BEGIN
	CREATE TABLE stg.ScriptAdvisorSettings
		(
		  ScriptAdvisorSettingsId TINYINT NULL,
		  IsPharmacyEligible BIT NULL,
		  EnableSendCardToClaimant BIT NULL,
		  EnableBillSource BIT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.ScriptAdvisorSettingsCoverageType', 'U') IS NOT NULL 
	DROP TABLE stg.ScriptAdvisorSettingsCoverageType  
BEGIN
	CREATE TABLE stg.ScriptAdvisorSettingsCoverageType
		(
		  ScriptAdvisorSettingsId TINYINT NULL,
		  CoverageType VARCHAR (2) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.SEC_RightGroups', 'U') IS NOT NULL 
	DROP TABLE stg.SEC_RightGroups  
BEGIN
	CREATE TABLE stg.SEC_RightGroups
		(
		  RightGroupId INT NULL,
		  RightGroupName VARCHAR (50) NULL,
		  RightGroupDescription VARCHAR (150) NULL,
		  CreatedDate DATETIME NULL,
		  CreatedBy VARCHAR (50) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.SEC_Users', 'U') IS NOT NULL 
	DROP TABLE stg.SEC_Users  
BEGIN
	CREATE TABLE stg.SEC_Users
		(
		  UserId INT NULL,
		  LoginName VARCHAR (15) NULL,
		  Password VARCHAR (30) NULL,
		  CreatedBy VARCHAR (50) NULL,
		  CreatedDate DATETIME NULL,
		  UserStatus INT NULL,
		  FirstName VARCHAR (20) NULL,
		  LastName VARCHAR (20) NULL,
		  AccountLocked SMALLINT NULL,
		  LockedCounter SMALLINT NULL,
		  PasswordCreateDate DATETIME NULL,
		  PasswordCaseFlag SMALLINT NULL,
		  ePassword VARCHAR (30) NULL,
		  CurrentSettings VARCHAR (MAX) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.SEC_User_OfficeGroups', 'U') IS NOT NULL 
	DROP TABLE stg.SEC_User_OfficeGroups  
BEGIN
	CREATE TABLE stg.SEC_User_OfficeGroups
		(
		  SECUserOfficeGroupId INT NULL,
		  UserId INT NULL,
		  OffcGroupId INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.SEC_User_RightGroups', 'U') IS NOT NULL 
	DROP TABLE stg.SEC_User_RightGroups  
BEGIN
	CREATE TABLE stg.SEC_User_RightGroups
		(
		  SECUserRightGroupId INT NULL,
		  UserId INT NULL,
		  RightGroupId INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.SentryRuleTypeCriteria', 'U') IS NOT NULL 
	DROP TABLE stg.SentryRuleTypeCriteria  
BEGIN
	CREATE TABLE stg.SentryRuleTypeCriteria
		(
		  RuleTypeId INT NULL,
		  CriteriaId INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.SENTRY_ACTION', 'U') IS NOT NULL 
	DROP TABLE stg.SENTRY_ACTION  
BEGIN
	CREATE TABLE stg.SENTRY_ACTION
		(
		  ActionID INT NULL,
		  Name VARCHAR (50) NULL,
		  Description VARCHAR (100) NULL,
		  CompatibilityKey VARCHAR (50) NULL,
		  PredefinedValues VARCHAR (MAX) NULL,
		  ValueDataType VARCHAR (50) NULL,
		  ValueFormat VARCHAR (250) NULL,
		  BillLineAction INT NULL,
		  AnalyzeFlag SMALLINT NULL,
		  ActionCategoryIDNo INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.SENTRY_ACTION_CATEGORY', 'U') IS NOT NULL 
	DROP TABLE stg.SENTRY_ACTION_CATEGORY  
BEGIN
	CREATE TABLE stg.SENTRY_ACTION_CATEGORY
		(
		  ActionCategoryIDNo INT NULL,
		  Description VARCHAR (60) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.SENTRY_CRITERIA', 'U') IS NOT NULL 
	DROP TABLE stg.SENTRY_CRITERIA  
BEGIN
	CREATE TABLE stg.SENTRY_CRITERIA
		(
		  CriteriaID INT NULL,
		  ParentName VARCHAR (50) NULL,
		  Name VARCHAR (50) NULL,
		  Description VARCHAR (150) NULL,
		  Operators VARCHAR (50) NULL,
		  PredefinedValues VARCHAR (MAX) NULL,
		  ValueDataType VARCHAR (50) NULL,
		  ValueFormat VARCHAR (250) NULL,
		  NullAllowed SMALLINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.SENTRY_PROFILE_RULE', 'U') IS NOT NULL 
	DROP TABLE stg.SENTRY_PROFILE_RULE  
BEGIN
	CREATE TABLE stg.SENTRY_PROFILE_RULE
		(
		  ProfileID INT NULL,
		  RuleID INT NULL,
		  Priority INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.SENTRY_RULE', 'U') IS NOT NULL 
	DROP TABLE stg.SENTRY_RULE  
BEGIN
	CREATE TABLE stg.SENTRY_RULE
		(
		  RuleID INT NULL,
		  Name VARCHAR (50) NULL,
		  Description VARCHAR (MAX) NULL,
		  CreatedBy VARCHAR (50) NULL,
		  CreationDate DATETIME NULL,
		  PostFixNotation VARCHAR (MAX) NULL,
		  Priority INT NULL,
		  RuleTypeID SMALLINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.SENTRY_RULE_ACTION_DETAIL', 'U') IS NOT NULL 
	DROP TABLE stg.SENTRY_RULE_ACTION_DETAIL  
BEGIN
	CREATE TABLE stg.SENTRY_RULE_ACTION_DETAIL
		(
		  RuleID INT NULL,
		  LineNumber INT NULL,
		  ActionID INT NULL,
		  ActionValue VARCHAR (1000) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.SENTRY_RULE_ACTION_HEADER', 'U') IS NOT NULL 
	DROP TABLE stg.SENTRY_RULE_ACTION_HEADER  
BEGIN
	CREATE TABLE stg.SENTRY_RULE_ACTION_HEADER
		(
		  RuleID INT NULL,
		  EndnoteShort VARCHAR (50) NULL,
		  EndnoteLong VARCHAR (MAX) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.SENTRY_RULE_CONDITION', 'U') IS NOT NULL 
	DROP TABLE stg.SENTRY_RULE_CONDITION  
BEGIN
	CREATE TABLE stg.SENTRY_RULE_CONDITION
		(
		  RuleID INT NULL,
		  LineNumber INT NULL,
		  GroupFlag VARCHAR (50) NULL,
		  CriteriaID INT NULL,
		  Operator VARCHAR (50) NULL,
		  ConditionValue VARCHAR (60) NULL,
		  AndOr VARCHAR (50) NULL,
		  UdfConditionId INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.SPECIALTY', 'U') IS NOT NULL 
	DROP TABLE stg.SPECIALTY  
BEGIN
	CREATE TABLE stg.SPECIALTY
		(
		  SpcIdNo INT NULL,
		  Code VARCHAR (50) NULL,
		  Description VARCHAR (70) NULL,
		  PayeeSubTypeID INT NULL,
		  TieredTypeID SMALLINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.StateSettingMedicare', 'U') IS NOT NULL 
	DROP TABLE stg.StateSettingMedicare  
BEGIN
	CREATE TABLE stg.StateSettingMedicare
		(
		  StateSettingMedicareId INT NULL,
		  PayPercentOfMedicareFee BIT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.StateSettingsFlorida', 'U') IS NOT NULL 
	DROP TABLE stg.StateSettingsFlorida  
BEGIN
	CREATE TABLE stg.StateSettingsFlorida
		(
		  StateSettingsFloridaId INT NULL,
		  ClaimantInitialServiceOption SMALLINT NULL,
		  ClaimantInitialServiceDays SMALLINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.StateSettingsHawaii', 'U') IS NOT NULL 
	DROP TABLE stg.StateSettingsHawaii  
BEGIN
	CREATE TABLE stg.StateSettingsHawaii
		(
		  StateSettingsHawaiiId INT NULL,
		  PhysicalMedicineLimitOption SMALLINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.StateSettingsNewJersey', 'U') IS NOT NULL 
	DROP TABLE stg.StateSettingsNewJersey  
BEGIN
	CREATE TABLE stg.StateSettingsNewJersey
		(
		  StateSettingsNewJerseyId INT NULL,
		  ByPassEmergencyServices BIT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.StateSettingsNewJerseyPolicyPreference', 'U') IS NOT NULL 
	DROP TABLE stg.StateSettingsNewJerseyPolicyPreference  
BEGIN
	CREATE TABLE stg.StateSettingsNewJerseyPolicyPreference
		(
		  PolicyPreferenceId INT NULL,
		  ShareCoPayMaximum BIT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.StateSettingsNewYorkPolicyPreference', 'U') IS NOT NULL 
	DROP TABLE stg.StateSettingsNewYorkPolicyPreference  
BEGIN
	CREATE TABLE stg.StateSettingsNewYorkPolicyPreference
		(
		  PolicyPreferenceId INT NULL,
		  ShareCoPayMaximum BIT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.StateSettingsNY', 'U') IS NOT NULL 
	DROP TABLE stg.StateSettingsNY  
BEGIN
	CREATE TABLE stg.StateSettingsNY
		(
		  StateSettingsNYID INT NULL,
		  NF10PrintDate BIT NULL,
		  NF10CheckBox1 BIT NULL,
		  NF10CheckBox18 BIT NULL,
		  NF10UseUnderwritingCompany BIT NULL,
		  UnderwritingCompanyUdfId INT NULL,
		  NaicUdfId INT NULL,
		  DisplayNYPrintOptionsWhenZosOrSojIsNY BIT NULL,
		  NF10DuplicatePrint BIT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.StateSettingsNyRoomRate', 'U') IS NOT NULL 
	DROP TABLE stg.StateSettingsNyRoomRate  
BEGIN
	CREATE TABLE stg.StateSettingsNyRoomRate
		(
		  StateSettingsNyRoomRateId INT NULL,
		  StartDate DATETIME NULL,
		  EndDate DATETIME NULL,
		  RoomRate MONEY NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO


IF OBJECT_ID('stg.StateSettingsOregon', 'U') IS NOT NULL
DROP TABLE stg.StateSettingsOregon
BEGIN
	CREATE TABLE stg.StateSettingsOregon 
	(
		StateSettingsOregonId TINYINT NULL,
		ApplyOregonFeeSchedule BIT NULL,
		DmlOperation CHAR(1) NOT NULL
	)
END
GO


IF OBJECT_ID('stg.StateSettingsOregonCoverageType', 'U') IS NOT NULL
DROP TABLE stg.StateSettingsOregonCoverageType
BEGIN
	CREATE TABLE stg.StateSettingsOregonCoverageType 
	(
		StateSettingsOregonId TINYINT NULL,
		CoverageType VARCHAR(2) NULL,
		DmlOperation CHAR(1) NOT NULL
	)
END
GO


IF OBJECT_ID('stg.SupplementBillApportionmentEndnote', 'U') IS NOT NULL
DROP TABLE stg.SupplementBillApportionmentEndnote
BEGIN
	CREATE TABLE stg.SupplementBillApportionmentEndnote (
		BillId INT NULL,
		SequenceNumber SMALLINT NULL,
        LineNumber SMALLINT NULL,
        Endnote INT NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO

IF OBJECT_ID('stg.SupplementBillCustomEndnote', 'U') IS NOT NULL
DROP TABLE stg.SupplementBillCustomEndnote
BEGIN
	CREATE TABLE stg.SupplementBillCustomEndnote (
		BillId INT NULL,
		SequenceNumber SMALLINT NULL,
        LineNumber SMALLINT NULL,
		Endnote INT NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO



IF OBJECT_ID('stg.SupplementBill_Pharm_ApportionmentEndnote', 'U') IS NOT NULL
DROP TABLE stg.SupplementBill_Pharm_ApportionmentEndnote
BEGIN
	CREATE TABLE stg.SupplementBill_Pharm_ApportionmentEndnote (
		BillId INT NULL,
		SequenceNumber SMALLINT NULL,
        LineNumber SMALLINT NULL,
        Endnote INT NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.SupplementPreCtgDeniedLinesEligibleToPenalty', 'U') IS NOT NULL 
	DROP TABLE stg.SupplementPreCtgDeniedLinesEligibleToPenalty  
BEGIN
	CREATE TABLE stg.SupplementPreCtgDeniedLinesEligibleToPenalty
		(
		  BillIdNo INT NULL,
		  LineNumber SMALLINT NULL,
		  CtgPenaltyTypeId TINYINT NULL,
		  SeqNo SMALLINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.SurgicalModifierException', 'U') IS NOT NULL 
	DROP TABLE stg.SurgicalModifierException  
BEGIN
	CREATE TABLE stg.SurgicalModifierException
		(
		  Modifier VARCHAR (2) NULL,
		  State VARCHAR (2) NULL,
		  CoverageType VARCHAR (2) NULL,
		  StartDate DATETIME2 (7) NULL,
		  EndDate DATETIME2 (7) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.Tag', 'U') IS NOT NULL
DROP TABLE stg.Tag
BEGIN
	CREATE TABLE stg.Tag (
	   TagId int NULL
      ,NAME varchar(50) NULL
      ,DateCreated datetimeoffset(7) NULL
      ,DateModified datetimeoffset(7) NULL
      ,CreatedBy varchar(15) NULL
      ,ModifiedBy varchar(15) NULL
	  ,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.TreatmentCategory', 'U') IS NOT NULL
DROP TABLE stg.TreatmentCategory
BEGIN
	CREATE TABLE stg.TreatmentCategory (
		TreatmentCategoryId tinyint NULL
	   ,Category varchar(50) NULL
	   ,Metadata nvarchar(max) NULL
	   ,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.TreatmentCategoryRange', 'U') IS NOT NULL
DROP TABLE stg.TreatmentCategoryRange
BEGIN
	CREATE TABLE stg.TreatmentCategoryRange (
		TreatmentCategoryRangeId int NULL
	   ,TreatmentCategoryId tinyint NULL
	   ,StartRange varchar(7) NULL
	   ,EndRange varchar(7) NULL
	   ,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.UB_APC_DICT', 'U') IS NOT NULL
DROP TABLE stg.UB_APC_DICT
BEGIN
	CREATE TABLE stg.UB_APC_DICT (
		StartDate DATETIME NULL
		,EndDate DATETIME NULL
		,APC VARCHAR(5) NULL
		,Description VARCHAR(255) NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO   
IF OBJECT_ID('stg.UB_BillType', 'U') IS NOT NULL
DROP TABLE stg.UB_BillType
BEGIN
	CREATE TABLE stg.UB_BillType (
		TOB VARCHAR(4) NULL
		,Description VARCHAR(max) NULL
		,Flag INT NULL
		,UB_BillTypeID INT NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
   
IF OBJECT_ID('stg.UB_RevenueCodes', 'U') IS NOT NULL
DROP TABLE stg.UB_RevenueCodes
BEGIN
	CREATE TABLE stg.UB_RevenueCodes (
		RevenueCode VARCHAR(4) NULL
	   ,StartDate DATETIME NULL
	   ,EndDate DATETIME NULL
	   ,PRC_DESC VARCHAR(MAX) NULL
	   ,Flags INT NULL
	   ,Vague VARCHAR(1) NULL
	   ,PerVisit SMALLINT NULL
	   ,PerClaimant SMALLINT NULL
	   ,PerProvider SMALLINT NULL
	   ,BodyFlags INT NULL
	   ,DrugFlag SMALLINT NULL
	   ,CurativeFlag SMALLINT NULL
	   ,RevenueCodeSubCategoryId TINYINT NULL
	   ,DmlOperation CHAR(1) NOT NULL
		)
END 
GO


IF OBJECT_ID('stg.UDFBill', 'U') IS NOT NULL
    DROP TABLE stg.UDFBill;
BEGIN
    CREATE TABLE stg.UDFBill
        (
          BillIdNo INT NULL ,
          UDFIdNo INT NULL ,
          UDFValueText VARCHAR(255) NULL ,
          UDFValueDecimal DECIMAL(19,4) NULL ,
          UDFValueDate DATETIME NULL ,
		  DmlOperation CHAR(1) NOT NULL
        );
END
GO

IF OBJECT_ID('stg.UDFClaim', 'U') IS NOT NULL
    DROP TABLE stg.UDFClaim;
BEGIN
    CREATE TABLE stg.UDFClaim
        (
          ClaimIdNo INT NULL ,
          UDFIdNo INT NULL ,
          UDFValueText VARCHAR(255) NULL ,
          UDFValueDecimal DECIMAL(19,4) NULL ,
          UDFValueDate DATETIME NULL ,
		  DmlOperation CHAR(1) NOT NULL
        );
END
GO
IF OBJECT_ID('stg.UDFClaimant', 'U') IS NOT NULL
    DROP TABLE stg.UDFClaimant;
BEGIN
    CREATE TABLE stg.UDFClaimant
        (
          CmtIdNo INT NULL ,
          UDFIdNo INT NULL ,
          UDFValueText VARCHAR(255) NULL ,
          UDFValueDecimal DECIMAL(19,4) NULL ,
          UDFValueDate DATETIME NULL ,
		  DmlOperation CHAR(1) NOT NULL
        );
END
GO
IF OBJECT_ID('stg.UdfDataFormat', 'U') IS NOT NULL 
	DROP TABLE stg.UdfDataFormat  
BEGIN
	CREATE TABLE stg.UdfDataFormat
		(
		  UdfDataFormatId SMALLINT NULL,
		  DataFormatName VARCHAR (30) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO


IF OBJECT_ID('stg.UDFLevelChangeTracking', 'U') IS NOT NULL
DROP TABLE stg.UDFLevelChangeTracking
BEGIN
	CREATE TABLE stg.UDFLevelChangeTracking 
	(
		UDFLevelChangeTrackingId INT NULL,
	    EntityType INT NULL,
		EntityId INT NULL,
		CorrelationId VARCHAR(50) NULL,
		UDFId INT NULL,  
		PreviousValue VARCHAR(MAX) NULL,
		UpdatedValue VARCHAR(MAX) NULL,
        UserId INT NULL,
		ChangeDate DATETIME2 NULL,
		DmlOperation CHAR(1) NOT NULL
	)
END
GO

IF OBJECT_ID('stg.UDFLibrary', 'U') IS NOT NULL
    DROP TABLE stg.UDFLibrary;
BEGIN
    CREATE TABLE stg.UDFLibrary
        (
          UDFIdNo INT NULL ,
          UDFName VARCHAR(50) NULL ,
          ScreenType SMALLINT NULL ,
          UDFDescription VARCHAR(1000) NULL ,
          DataFormat SMALLINT NULL ,
          RequiredField SMALLINT NULL ,
          ReadOnly SMALLINT NULL ,
          Invisible SMALLINT NULL ,
          TextMaxLength SMALLINT NULL ,
          TextMask VARCHAR(50) NULL ,
          TextEnforceLength SMALLINT NULL ,
          RestrictRange SMALLINT NULL ,
          MinValDecimal REAL NULL ,
          MaxValDecimal REAL NULL ,
          MinValDate DATETIME NULL ,
          MaxValDate DATETIME NULL ,
          ListAllowMultiple SMALLINT NULL ,
          DefaultValueText VARCHAR(100) NULL ,
          DefaultValueDecimal REAL NULL ,
          DefaultValueDate DATETIME NULL ,
          UseDefault SMALLINT NULL ,
          ReqOnSubmit SMALLINT NULL ,
          IncludeDateButton BIT NULL ,
		  DmlOperation CHAR(1) NOT NULL
        );
END
GO

IF OBJECT_ID('stg.UDFListValues', 'U') IS NOT NULL
    DROP TABLE stg.UDFListValues;
BEGIN
    CREATE TABLE stg.UDFListValues
        (
          ListValueIdNo INT NULL ,
          UDFIdNo INT NULL ,
          SeqNo SMALLINT NULL ,
          ListValue VARCHAR(50) NULL ,
          DefaultValue SMALLINT NULL ,
		  DmlOperation CHAR(1) NOT NULL
        );
END
GO
IF OBJECT_ID('stg.UDFProvider', 'U') IS NOT NULL
    DROP TABLE stg.UDFProvider;
BEGIN
    CREATE TABLE stg.UDFProvider
        (
          PvdIdNo INT NULL ,
          UDFIdNo INT NULL ,
          UDFValueText VARCHAR(255) NULL ,
          UDFValueDecimal DECIMAL(19,4) NULL ,
          UDFValueDate DATETIME NULL ,
		  DmlOperation CHAR(1) NOT NULL
        );
END
GO
IF OBJECT_ID('stg.UDFViewOrder', 'U') IS NOT NULL
    DROP TABLE stg.UDFViewOrder;
BEGIN
    CREATE TABLE stg.UDFViewOrder
        (
          OfficeId INT NULL ,
          UDFIdNo INT NULL ,
          ViewOrder SMALLINT NULL ,
		  DmlOperation CHAR(1) NOT NULL
        );
END
GO
IF OBJECT_ID('stg.UDF_Sentry_Criteria', 'U') IS NOT NULL
    DROP TABLE stg.UDF_Sentry_Criteria;
BEGIN
    CREATE TABLE stg.UDF_Sentry_Criteria
        (
          UdfIdNo INT NULL ,
          CriteriaID INT NULL ,
          ParentName VARCHAR(50) NULL ,
          Name VARCHAR(50) NULL ,
          Description VARCHAR(1000) NULL ,
          Operators VARCHAR(50) NULL ,
          PredefinedValues VARCHAR(MAX) NULL ,
          ValueDataType VARCHAR(50) NULL ,
          ValueFormat VARCHAR(50) NULL ,
		  DmlOperation CHAR(1) NOT NULL
        );
END
GO
IF OBJECT_ID('stg.Vpn', 'U') IS NOT NULL
DROP TABLE stg.Vpn
BEGIN
	CREATE TABLE stg.Vpn (
		VpnId SMALLINT NULL
		,NetworkName VARCHAR(50) NULL
		,PendAndSend BIT NULL
		,BypassMatching BIT NULL
		,AllowsResends BIT NULL
		,OdsEligible BIT NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.VPNActivityFlag', 'U') IS NOT NULL
DROP TABLE stg.VPNActivityFlag
BEGIN
	CREATE TABLE stg.VPNActivityFlag(
		          Activity_Flag VARCHAR(1)  NULL ,
				  AF_Description VARCHAR(50) NULL ,
				  AF_ShortDesc VARCHAR(50) NULL ,
				  Data_Source VARCHAR(5) NULL ,
				  Default_Billable BIT NULL ,
				  Credit BIT NULL,
		          DmlOperation CHAR(1) NOT NULL 
	)
END
GO




IF OBJECT_ID('stg.VPNBillableFlags', 'U') IS NOT NULL
DROP TABLE stg.VPNBillableFlags
BEGIN
	CREATE TABLE stg.VPNBillableFlags(
		SOJ nchar(2) NULL,
		NetworkID int NULL,
		ActivityFlag nchar(2) NULL,
		Billable nchar(1) NULL,
		CompanyCode varchar(10) NULL,
		CompanyName varchar(100) NULL,
		DmlOperation CHAR(1) NOT NULL 
	)
END
GO

IF OBJECT_ID('stg.VpnBillingCategory', 'U') IS NOT NULL
DROP TABLE stg.VpnBillingCategory
BEGIN
CREATE TABLE stg.VpnBillingCategory (
		VpnBillingCategoryCode char(1) NOT NULL,
		VpnBillingCategoryDescription varchar(30) NULL,
		DmlOperation char(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.VpnLedger', 'U') IS NOT NULL 
	DROP TABLE stg.VpnLedger  
BEGIN
	CREATE TABLE stg.VpnLedger
		(
		  TransactionID BIGINT NULL,
		  TransactionTypeID INT NULL,
		  BillIdNo INT NULL,
		  Line_No SMALLINT NULL,
		  Charged MONEY NULL,
		  DPAllowed MONEY NULL,
		  VPNAllowed MONEY NULL,
		  Savings MONEY NULL,
		  Credits MONEY NULL,
		  HasOverride BIT NULL,
		  EndNotes NVARCHAR (200) NULL,
		  NetworkIdNo INT NULL,
		  ProcessFlag SMALLINT NULL,
		  LineType INT NULL,
		  DateTimeStamp DATETIME NULL,
		  SeqNo INT NULL,
		  VPN_Ref_Line_No SMALLINT NULL,
		  SpecialProcessing BIT NULL,
		  CreateDate DATETIME2 (7) NULL,
		  LastChangedOn DATETIME2 (7) NULL,
		  AdjustedCharged DECIMAL (19,4) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.VpnProcessFlagType', 'U') IS NOT NULL 
	DROP TABLE stg.VpnProcessFlagType  
BEGIN
	CREATE TABLE stg.VpnProcessFlagType
		(
		  VpnProcessFlagTypeId SMALLINT NULL,
		  VpnProcessFlagType VARCHAR (50) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.VpnSavingTransactionType', 'U') IS NOT NULL 
	DROP TABLE stg.VpnSavingTransactionType  
BEGIN
	CREATE TABLE stg.VpnSavingTransactionType
		(
		  VpnSavingTransactionTypeId INT NULL,
		  VpnSavingTransactionType VARCHAR (50) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.Vpn_Billing_History', 'U') IS NOT NULL
DROP TABLE stg.Vpn_Billing_History
BEGIN
CREATE TABLE stg.Vpn_Billing_History(
	Customer varchar(50) NULL,
	TransactionID bigint NOT NULL,
	Period datetime NOT NULL,
	ActivityFlag varchar(1) NULL,
	BillableFlag varchar(1) NULL,
	Void varchar(4) NULL,
	CreditType varchar(10) NULL,
	Network varchar(50) NULL,
	BillIdNo int NULL,
	Line_No smallint NULL,
	TransactionDate datetime NULL,
	RepriceDate datetime NULL,
	ClaimNo varchar(50) NULL,
	ProviderCharges money NULL,
	DPAllowed money NULL,
	VPNAllowed money NULL,
	Savings money NULL,
	Credits money NULL,
	NetSavings money NULL,
	SOJ varchar(2) NULL,
	seqno int NULL,
	CompanyCode varchar(10) NULL,
	VpnId smallint NULL,
	ProcessFlag smallint NULL,
	SK int NULL,
	DATABASE_NAME varchar(100) NULL,
	SubmittedToFinance bit NULL,
	IsInitialLoad bit NULL,
	VpnBillingCategoryCode char(1) NULL,
	DmlOperation char(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.WeekEndsAndHolidays', 'U') IS NOT NULL
DROP TABLE stg.WeekEndsAndHolidays
BEGIN
CREATE TABLE stg.WeekEndsAndHolidays (
		DayOfWeekDate datetime NULL,
		DayName char(3) NULL,
		WeekEndsAndHolidayId int NOT NULL,
		DmlOperation char(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.Zip2County', 'U') IS NOT NULL
DROP TABLE stg.Zip2County
BEGIN
    CREATE TABLE stg.Zip2County(
        Zip VARCHAR(5) NULL
        ,County VARCHAR(50) NULL
        ,State VARCHAR(2) NULL
        ,DmlOperation CHAR(1) NOT NULL
        )
END
GO
IF OBJECT_ID('stg.ZipCode', 'U') IS NOT NULL
    DROP TABLE stg.ZipCode;

BEGIN
    CREATE TABLE stg.ZipCode
        (
         ZipCode VARCHAR(5) NULL
        ,PrimaryRecord BIT NULL
        ,STATE VARCHAR(2) NULL
        ,City VARCHAR(30) NULL
        ,CityAlias VARCHAR(30) NULL
        ,County VARCHAR(30) NULL
        ,Cbsa VARCHAR(5) NULL
        ,CbsaType VARCHAR(5) NULL
        ,ZipCodeRegionId TINYINT NULL
        ,DmlOperation CHAR(1) NOT NULL
        );
END;
GO

-- --------------------------------------------------
-- Creating Table Description in Extended Property
-- --------------------------------------------------

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties
	WHERE   major_id = OBJECT_ID(N'adm.AppVersion')
		AND name = N'MS_Description'
		AND minor_id = 0)
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion' --Table Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'This table stores a record for each version deployed to the database, along with the date and time of deployment',    --Table Description
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion' --Table Name

GO



-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.AppVersion')
		AND ep.name = N'MS_Description'
		AND c.name = N'AppVersionId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'AppVersionId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Primary key; Identity',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'AppVersionId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.AppVersion')
		AND ep.name = N'MS_Description'
		AND c.name = N'AppVersion' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'AppVersion' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'ODS version; the forrmat is x.x.x[.x]',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'AppVersion' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.AppVersion')
		AND ep.name = N'MS_Description'
		AND c.name = N'AppVersionDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'AppVersionDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The date and time this record was inserted into the AppVersion table',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'AppVersionDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Table Description in Extended Property
-- --------------------------------------------------

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties
	WHERE   major_id = OBJECT_ID(N'adm.PostingGroupAudit')
		AND name = N'MS_Description'
		AND minor_id = 0)
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit' --Table Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Audit table that tracks the status of a posting group load',    --Table Description
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit' --Table Name

GO



-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'PostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Primary key.  Identity.',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'OltpPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OltpPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Primary key associated with the posting group on the source OLTP database.',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OltpPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'PostingGroupId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Posting Group',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'CustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'Status' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'Status' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Status of posting group load.  FI means load was completed successfully.',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'Status' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'DataExtractTypeId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DataExtractTypeId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'When true, it means the posting group contains incremental data extracts.',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DataExtractTypeId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsVersion' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsVersion' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Acs Ods version at the time this record was queued.',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsVersion' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'SnapshotCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'SnapshotCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The date and time the snapshot from which the data was extracted was created on the souce server (typically the source secondary server)',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'SnapshotCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'SnapshotDropDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'SnapshotDropDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The date and time the snapshot was dropped.',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'SnapshotDropDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'CreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time the record was added.',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'LastChangeDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LastChangeDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time the record was last inserted or updated.',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LastChangeDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Table Description in Extended Property
-- --------------------------------------------------

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND name = N'MS_Description'
		AND minor_id = 0)
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit' --Table Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Audit table that tracks the status of each table load',    --Table Description
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit' --Table Name

GO



-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'ProcessAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Primary key.  Identity.',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'PostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'ProcessId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Process',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'Status' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'Status' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Status of load.  When FI, load is complete.',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'Status' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'ExtractRowCount' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ExtractRowCount' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Number of records loaded into stg table (staging)',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ExtractRowCount' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'UpdateRowCount' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'UpdateRowCount' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Number of records updated in stg table (staging)',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'UpdateRowCount' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'LoadRowCount' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LoadRowCount' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Number of records loaaded into src table',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LoadRowCount' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'ExtractDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ExtractDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time data was loaded into stg table',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ExtractDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'LastUpdateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LastUpdateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Data and time record was last inserted or updated',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LastUpdateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'LoadDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LoadDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time data was loaded into src table',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LoadDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'CreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time record was created',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'LastChangeDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LastChangeDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Data and time record was last inserted or updated',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LastChangeDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BillExclusionLookUpTable')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillExclusionLookUpTable', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillExclusionLookUpTable', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BillExclusionLookUpTable')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillExclusionLookUpTable', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillExclusionLookUpTable', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BillExclusionLookUpTable')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillExclusionLookUpTable', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillExclusionLookUpTable', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BillExclusionLookUpTable')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillExclusionLookUpTable', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillExclusionLookUpTable', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BillExclusionLookUpTable')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillExclusionLookUpTable', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillExclusionLookUpTable', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BillExclusionLookUpTable')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillExclusionLookUpTable', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillExclusionLookUpTable', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BillExclusionLookUpTable')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillExclusionLookUpTable', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillExclusionLookUpTable', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILLS')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILLS')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILLS')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILLS')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILLS')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILLS')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILLS')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BillsProviderNetwork')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillsProviderNetwork', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillsProviderNetwork', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BillsProviderNetwork')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillsProviderNetwork', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillsProviderNetwork', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BillsProviderNetwork')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillsProviderNetwork', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillsProviderNetwork', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BillsProviderNetwork')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillsProviderNetwork', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillsProviderNetwork', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BillsProviderNetwork')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillsProviderNetwork', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillsProviderNetwork', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BillsProviderNetwork')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillsProviderNetwork', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillsProviderNetwork', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BillsProviderNetwork')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillsProviderNetwork', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillsProviderNetwork', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILLS_CTG_Endnotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS_CTG_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS_CTG_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILLS_CTG_Endnotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS_CTG_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS_CTG_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILLS_CTG_Endnotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS_CTG_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS_CTG_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILLS_CTG_Endnotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS_CTG_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS_CTG_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILLS_CTG_Endnotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS_CTG_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS_CTG_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILLS_CTG_Endnotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS_CTG_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS_CTG_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILLS_CTG_Endnotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS_CTG_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS_CTG_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILLS_Endnotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILLS_Endnotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILLS_Endnotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILLS_Endnotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILLS_Endnotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILLS_Endnotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILLS_Endnotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILLS_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_OverrideEndNotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_OverrideEndNotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_OverrideEndNotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_OverrideEndNotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_OverrideEndNotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_OverrideEndNotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_OverrideEndNotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_OverrideEndNotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_OverrideEndNotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_OverrideEndNotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_OverrideEndNotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_OverrideEndNotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_OverrideEndNotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_OverrideEndNotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_OverrideEndNotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_OverrideEndNotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_OverrideEndNotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_OverrideEndNotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_OverrideEndNotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_OverrideEndNotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_OverrideEndNotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_Pharm')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_Pharm')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_Pharm')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_Pharm')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_Pharm')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_Pharm')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_Pharm')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_Pharm_CTG_Endnotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_CTG_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_CTG_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_Pharm_CTG_Endnotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_CTG_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_CTG_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_Pharm_CTG_Endnotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_CTG_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_CTG_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_Pharm_CTG_Endnotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_CTG_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_CTG_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_Pharm_CTG_Endnotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_CTG_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_CTG_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_Pharm_CTG_Endnotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_CTG_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_CTG_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_Pharm_CTG_Endnotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_CTG_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_CTG_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_Pharm_Endnotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_Pharm_Endnotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_Pharm_Endnotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_Pharm_Endnotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_Pharm_Endnotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_Pharm_Endnotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_Pharm_Endnotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_Endnotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_Pharm_OverrideEndNotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_OverrideEndNotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_OverrideEndNotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_Pharm_OverrideEndNotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_OverrideEndNotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_OverrideEndNotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_Pharm_OverrideEndNotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_OverrideEndNotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_OverrideEndNotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_Pharm_OverrideEndNotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_OverrideEndNotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_OverrideEndNotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_Pharm_OverrideEndNotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_OverrideEndNotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_OverrideEndNotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_Pharm_OverrideEndNotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_OverrideEndNotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_OverrideEndNotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bills_Pharm_OverrideEndNotes')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_OverrideEndNotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bills_Pharm_OverrideEndNotes', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILL_HDR')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILL_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILL_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILL_HDR')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILL_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILL_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILL_HDR')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILL_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILL_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILL_HDR')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILL_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILL_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILL_HDR')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILL_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILL_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILL_HDR')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILL_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILL_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILL_HDR')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILL_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILL_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bill_History')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bill_History', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bill_History', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bill_History')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bill_History', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bill_History', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bill_History')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bill_History', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bill_History', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bill_History')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bill_History', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bill_History', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bill_History')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bill_History', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bill_History', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bill_History')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bill_History', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bill_History', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bill_History')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bill_History', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bill_History', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bitmasks')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bitmasks', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bitmasks', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bitmasks')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bitmasks', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bitmasks', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bitmasks')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bitmasks', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bitmasks', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bitmasks')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bitmasks', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bitmasks', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bitmasks')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bitmasks', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bitmasks', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bitmasks')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bitmasks', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bitmasks', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Bitmasks')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bitmasks', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Bitmasks', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CLAIMANT')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CLAIMANT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CLAIMANT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CLAIMANT')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CLAIMANT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CLAIMANT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CLAIMANT')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CLAIMANT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CLAIMANT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CLAIMANT')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CLAIMANT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CLAIMANT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CLAIMANT')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CLAIMANT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CLAIMANT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CLAIMANT')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CLAIMANT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CLAIMANT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CLAIMANT')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CLAIMANT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CLAIMANT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CLAIMS')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CLAIMS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CLAIMS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CLAIMS')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CLAIMS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CLAIMS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CLAIMS')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CLAIMS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CLAIMS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CLAIMS')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CLAIMS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CLAIMS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CLAIMS')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CLAIMS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CLAIMS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CLAIMS')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CLAIMS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CLAIMS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CLAIMS')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CLAIMS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CLAIMS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CMT_DX')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_DX', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_DX', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CMT_DX')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_DX', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_DX', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CMT_DX')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_DX', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_DX', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CMT_DX')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_DX', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_DX', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CMT_DX')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_DX', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_DX', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CMT_DX')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_DX', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_DX', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CMT_DX')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_DX', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_DX', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CMT_HDR')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CMT_HDR')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CMT_HDR')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CMT_HDR')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CMT_HDR')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CMT_HDR')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CMT_HDR')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CMT_ICD9')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_ICD9', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_ICD9', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CMT_ICD9')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_ICD9', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_ICD9', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CMT_ICD9')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_ICD9', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_ICD9', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CMT_ICD9')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_ICD9', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_ICD9', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CMT_ICD9')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_ICD9', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_ICD9', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CMT_ICD9')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_ICD9', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_ICD9', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CMT_ICD9')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_ICD9', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CMT_ICD9', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.cpt_DX_DICT')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'cpt_DX_DICT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'cpt_DX_DICT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.cpt_DX_DICT')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'cpt_DX_DICT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'cpt_DX_DICT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.cpt_DX_DICT')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'cpt_DX_DICT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'cpt_DX_DICT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.cpt_DX_DICT')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'cpt_DX_DICT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'cpt_DX_DICT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.cpt_DX_DICT')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'cpt_DX_DICT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'cpt_DX_DICT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.cpt_DX_DICT')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'cpt_DX_DICT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'cpt_DX_DICT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.cpt_DX_DICT')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'cpt_DX_DICT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'cpt_DX_DICT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.cpt_PRC_DICT')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'cpt_PRC_DICT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'cpt_PRC_DICT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.cpt_PRC_DICT')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'cpt_PRC_DICT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'cpt_PRC_DICT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.cpt_PRC_DICT')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'cpt_PRC_DICT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'cpt_PRC_DICT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.cpt_PRC_DICT')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'cpt_PRC_DICT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'cpt_PRC_DICT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.cpt_PRC_DICT')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'cpt_PRC_DICT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'cpt_PRC_DICT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.cpt_PRC_DICT')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'cpt_PRC_DICT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'cpt_PRC_DICT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.cpt_PRC_DICT')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'cpt_PRC_DICT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'cpt_PRC_DICT', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CreditReason')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CreditReason', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CreditReason', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CreditReason')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CreditReason', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CreditReason', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CreditReason')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CreditReason', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CreditReason', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CreditReason')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CreditReason', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CreditReason', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CreditReason')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CreditReason', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CreditReason', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CreditReason')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CreditReason', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CreditReason', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CreditReason')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CreditReason', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CreditReason', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CreditReasonOverrideENMap')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CreditReasonOverrideENMap', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CreditReasonOverrideENMap', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CreditReasonOverrideENMap')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CreditReasonOverrideENMap', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CreditReasonOverrideENMap', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CreditReasonOverrideENMap')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CreditReasonOverrideENMap', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CreditReasonOverrideENMap', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CreditReasonOverrideENMap')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CreditReasonOverrideENMap', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CreditReasonOverrideENMap', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CreditReasonOverrideENMap')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CreditReasonOverrideENMap', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CreditReasonOverrideENMap', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CreditReasonOverrideENMap')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CreditReasonOverrideENMap', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CreditReasonOverrideENMap', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CreditReasonOverrideENMap')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CreditReasonOverrideENMap', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CreditReasonOverrideENMap', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CustomerBillExclusion')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CustomerBillExclusion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CustomerBillExclusion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CustomerBillExclusion')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CustomerBillExclusion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CustomerBillExclusion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CustomerBillExclusion')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CustomerBillExclusion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CustomerBillExclusion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CustomerBillExclusion')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CustomerBillExclusion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CustomerBillExclusion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CustomerBillExclusion')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CustomerBillExclusion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CustomerBillExclusion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CustomerBillExclusion')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CustomerBillExclusion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CustomerBillExclusion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CustomerBillExclusion')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CustomerBillExclusion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CustomerBillExclusion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.DiagnosisCodeGroup')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DiagnosisCodeGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DiagnosisCodeGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.DiagnosisCodeGroup')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DiagnosisCodeGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DiagnosisCodeGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.DiagnosisCodeGroup')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DiagnosisCodeGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DiagnosisCodeGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.DiagnosisCodeGroup')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DiagnosisCodeGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DiagnosisCodeGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.DiagnosisCodeGroup')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DiagnosisCodeGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DiagnosisCodeGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.DiagnosisCodeGroup')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DiagnosisCodeGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DiagnosisCodeGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.DiagnosisCodeGroup')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DiagnosisCodeGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DiagnosisCodeGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Icd10DiagnosisVersion')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Icd10DiagnosisVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Icd10DiagnosisVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Icd10DiagnosisVersion')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Icd10DiagnosisVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Icd10DiagnosisVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Icd10DiagnosisVersion')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Icd10DiagnosisVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Icd10DiagnosisVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Icd10DiagnosisVersion')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Icd10DiagnosisVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Icd10DiagnosisVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Icd10DiagnosisVersion')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Icd10DiagnosisVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Icd10DiagnosisVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Icd10DiagnosisVersion')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Icd10DiagnosisVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Icd10DiagnosisVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Icd10DiagnosisVersion')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Icd10DiagnosisVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Icd10DiagnosisVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ICD10ProcedureCode')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ICD10ProcedureCode', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ICD10ProcedureCode', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ICD10ProcedureCode')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ICD10ProcedureCode', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ICD10ProcedureCode', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ICD10ProcedureCode')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ICD10ProcedureCode', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ICD10ProcedureCode', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ICD10ProcedureCode')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ICD10ProcedureCode', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ICD10ProcedureCode', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ICD10ProcedureCode')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ICD10ProcedureCode', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ICD10ProcedureCode', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ICD10ProcedureCode')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ICD10ProcedureCode', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ICD10ProcedureCode', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ICD10ProcedureCode')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ICD10ProcedureCode', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ICD10ProcedureCode', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CoverageType')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CoverageType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CoverageType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CoverageType')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CoverageType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CoverageType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CoverageType')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CoverageType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CoverageType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CoverageType')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CoverageType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CoverageType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CoverageType')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CoverageType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CoverageType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CoverageType')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CoverageType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CoverageType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.CoverageType')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CoverageType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'CoverageType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.lkp_SPC')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'lkp_SPC', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'lkp_SPC', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.lkp_SPC')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'lkp_SPC', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'lkp_SPC', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.lkp_SPC')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'lkp_SPC', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'lkp_SPC', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.lkp_SPC')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'lkp_SPC', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'lkp_SPC', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.lkp_SPC')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'lkp_SPC', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'lkp_SPC', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.lkp_SPC')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'lkp_SPC', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'lkp_SPC', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.lkp_SPC')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'lkp_SPC', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'lkp_SPC', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ny_Pharmacy')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ny_Pharmacy', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ny_Pharmacy', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ny_Pharmacy')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ny_Pharmacy', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ny_Pharmacy', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ny_Pharmacy')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ny_Pharmacy', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ny_Pharmacy', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ny_Pharmacy')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ny_Pharmacy', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ny_Pharmacy', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ny_Pharmacy')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ny_Pharmacy', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ny_Pharmacy', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ny_Pharmacy')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ny_Pharmacy', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ny_Pharmacy', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ny_Pharmacy')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ny_Pharmacy', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ny_Pharmacy', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ny_specialty')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ny_specialty', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ny_specialty', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ny_specialty')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ny_specialty', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ny_specialty', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ny_specialty')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ny_specialty', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ny_specialty', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ny_specialty')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ny_specialty', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ny_specialty', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ny_specialty')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ny_specialty', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ny_specialty', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ny_specialty')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ny_specialty', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ny_specialty', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ny_specialty')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ny_specialty', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ny_specialty', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.PrePpoBillInfo')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PrePpoBillInfo', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PrePpoBillInfo', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.PrePpoBillInfo')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PrePpoBillInfo', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PrePpoBillInfo', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.PrePpoBillInfo')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PrePpoBillInfo', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PrePpoBillInfo', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.PrePpoBillInfo')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PrePpoBillInfo', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PrePpoBillInfo', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.PrePpoBillInfo')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PrePpoBillInfo', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PrePpoBillInfo', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.PrePpoBillInfo')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PrePpoBillInfo', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PrePpoBillInfo', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.PrePpoBillInfo')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PrePpoBillInfo', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PrePpoBillInfo', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.prf_COMPANY')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'prf_COMPANY', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'prf_COMPANY', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.prf_COMPANY')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'prf_COMPANY', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'prf_COMPANY', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.prf_COMPANY')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'prf_COMPANY', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'prf_COMPANY', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.prf_COMPANY')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'prf_COMPANY', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'prf_COMPANY', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.prf_COMPANY')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'prf_COMPANY', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'prf_COMPANY', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.prf_COMPANY')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'prf_COMPANY', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'prf_COMPANY', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.prf_COMPANY')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'prf_COMPANY', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'prf_COMPANY', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.prf_Office')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'prf_Office', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'prf_Office', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.prf_Office')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'prf_Office', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'prf_Office', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.prf_Office')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'prf_Office', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'prf_Office', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.prf_Office')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'prf_Office', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'prf_Office', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.prf_Office')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'prf_Office', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'prf_Office', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.prf_Office')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'prf_Office', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'prf_Office', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.prf_Office')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'prf_Office', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'prf_Office', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ProcedureCodeGroup')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcedureCodeGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcedureCodeGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ProcedureCodeGroup')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcedureCodeGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcedureCodeGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ProcedureCodeGroup')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcedureCodeGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcedureCodeGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ProcedureCodeGroup')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcedureCodeGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcedureCodeGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ProcedureCodeGroup')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcedureCodeGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcedureCodeGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ProcedureCodeGroup')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcedureCodeGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcedureCodeGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ProcedureCodeGroup')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcedureCodeGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcedureCodeGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.PROVIDER')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PROVIDER', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PROVIDER', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.PROVIDER')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PROVIDER', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PROVIDER', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.PROVIDER')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PROVIDER', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PROVIDER', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.PROVIDER')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PROVIDER', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PROVIDER', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.PROVIDER')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PROVIDER', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PROVIDER', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.PROVIDER')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PROVIDER', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PROVIDER', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.PROVIDER')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PROVIDER', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PROVIDER', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ProviderNetworkEventLog')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProviderNetworkEventLog', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProviderNetworkEventLog', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ProviderNetworkEventLog')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProviderNetworkEventLog', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProviderNetworkEventLog', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ProviderNetworkEventLog')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProviderNetworkEventLog', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProviderNetworkEventLog', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ProviderNetworkEventLog')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProviderNetworkEventLog', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProviderNetworkEventLog', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ProviderNetworkEventLog')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProviderNetworkEventLog', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProviderNetworkEventLog', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ProviderNetworkEventLog')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProviderNetworkEventLog', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProviderNetworkEventLog', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ProviderNetworkEventLog')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProviderNetworkEventLog', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProviderNetworkEventLog', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.rsn_Override')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'rsn_Override', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'rsn_Override', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.rsn_Override')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'rsn_Override', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'rsn_Override', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.rsn_Override')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'rsn_Override', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'rsn_Override', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.rsn_Override')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'rsn_Override', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'rsn_Override', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.rsn_Override')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'rsn_Override', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'rsn_Override', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.rsn_Override')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'rsn_Override', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'rsn_Override', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.rsn_Override')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'rsn_Override', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'rsn_Override', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.rsn_REASONS')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'rsn_REASONS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'rsn_REASONS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.rsn_REASONS')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'rsn_REASONS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'rsn_REASONS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.rsn_REASONS')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'rsn_REASONS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'rsn_REASONS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.rsn_REASONS')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'rsn_REASONS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'rsn_REASONS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.rsn_REASONS')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'rsn_REASONS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'rsn_REASONS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.rsn_REASONS')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'rsn_REASONS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'rsn_REASONS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.rsn_REASONS')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'rsn_REASONS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'rsn_REASONS', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Ub_Apc_Dict')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Ub_Apc_Dict', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Ub_Apc_Dict', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Ub_Apc_Dict')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Ub_Apc_Dict', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Ub_Apc_Dict', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Ub_Apc_Dict')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Ub_Apc_Dict', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Ub_Apc_Dict', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Ub_Apc_Dict')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Ub_Apc_Dict', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Ub_Apc_Dict', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Ub_Apc_Dict')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Ub_Apc_Dict', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Ub_Apc_Dict', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Ub_Apc_Dict')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Ub_Apc_Dict', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Ub_Apc_Dict', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Ub_Apc_Dict')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Ub_Apc_Dict', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Ub_Apc_Dict', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.UB_BillType')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'UB_BillType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'UB_BillType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.UB_BillType')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'UB_BillType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'UB_BillType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.UB_BillType')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'UB_BillType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'UB_BillType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.UB_BillType')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'UB_BillType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'UB_BillType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.UB_BillType')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'UB_BillType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'UB_BillType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.UB_BillType')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'UB_BillType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'UB_BillType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.UB_BillType')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'UB_BillType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'UB_BillType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Vpn')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Vpn', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Vpn', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Vpn')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Vpn', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Vpn', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Vpn')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Vpn', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Vpn', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Vpn')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Vpn', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Vpn', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Vpn')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Vpn', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Vpn', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Vpn')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Vpn', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Vpn', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Vpn')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Vpn', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Vpn', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.VpnBillingCategory')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'VpnBillingCategory', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'VpnBillingCategory', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.VpnBillingCategory')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'VpnBillingCategory', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'VpnBillingCategory', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.VpnBillingCategory')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'VpnBillingCategory', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'VpnBillingCategory', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.VpnBillingCategory')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'VpnBillingCategory', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'VpnBillingCategory', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.VpnBillingCategory')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'VpnBillingCategory', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'VpnBillingCategory', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.VpnBillingCategory')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'VpnBillingCategory', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'VpnBillingCategory', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.VpnBillingCategory')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'VpnBillingCategory', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'VpnBillingCategory', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.VpnLedger')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'VpnLedger', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'VpnLedger', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.VpnLedger')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'VpnLedger', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'VpnLedger', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.VpnLedger')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'VpnLedger', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'VpnLedger', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.VpnLedger')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'VpnLedger', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'VpnLedger', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.VpnLedger')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'VpnLedger', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'VpnLedger', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.VpnLedger')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'VpnLedger', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'VpnLedger', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.VpnLedger')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'VpnLedger', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'VpnLedger', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Vpn_Billing_History')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Vpn_Billing_History', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Vpn_Billing_History', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Vpn_Billing_History')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Vpn_Billing_History', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Vpn_Billing_History', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Vpn_Billing_History')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Vpn_Billing_History', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Vpn_Billing_History', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Vpn_Billing_History')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Vpn_Billing_History', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Vpn_Billing_History', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Vpn_Billing_History')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Vpn_Billing_History', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Vpn_Billing_History', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Vpn_Billing_History')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Vpn_Billing_History', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Vpn_Billing_History', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Vpn_Billing_History')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Vpn_Billing_History', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Vpn_Billing_History', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.WeekEndsAndHolidays')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'WeekEndsAndHolidays', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'WeekEndsAndHolidays', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.WeekEndsAndHolidays')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'WeekEndsAndHolidays', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'WeekEndsAndHolidays', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.WeekEndsAndHolidays')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'WeekEndsAndHolidays', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'WeekEndsAndHolidays', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.WeekEndsAndHolidays')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'WeekEndsAndHolidays', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'WeekEndsAndHolidays', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.WeekEndsAndHolidays')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'WeekEndsAndHolidays', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'WeekEndsAndHolidays', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.WeekEndsAndHolidays')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'WeekEndsAndHolidays', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'WeekEndsAndHolidays', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.WeekEndsAndHolidays')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'WeekEndsAndHolidays', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'WeekEndsAndHolidays', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Zip2County')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Zip2County', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Zip2County', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Zip2County')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Zip2County', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Zip2County', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Zip2County')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Zip2County', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Zip2County', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Zip2County')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Zip2County', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Zip2County', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Zip2County')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Zip2County', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Zip2County', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Zip2County')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Zip2County', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Zip2County', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.Zip2County')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Zip2County', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Zip2County', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ZipCode')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ZipCode', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ZipCode', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ZipCode')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ZipCode', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ZipCode', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ZipCode')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ZipCode', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ZipCode', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ZipCode')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ZipCode', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ZipCode', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ZipCode')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ZipCode', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ZipCode', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ZipCode')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ZipCode', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ZipCode', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.ZipCode')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ZipCode', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ZipCode', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO

