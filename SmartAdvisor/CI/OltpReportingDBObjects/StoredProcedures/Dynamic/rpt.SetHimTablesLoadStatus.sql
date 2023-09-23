IF OBJECT_ID('rpt.SetHimTablesLoadStatus') IS NOT NULL
    DROP PROCEDURE rpt.SetHimTablesLoadStatus
GO

CREATE PROCEDURE rpt.SetHimTablesLoadStatus  (
@DatabaseName VARCHAR(100) = NULL,
@DataExtractTypeId INT = 0)
AS
BEGIN
--DECLARE @DatabaseName VARCHAR(100) = 'ODS_dB_1_Child',@DataExtractTypeId INT = 0
    DECLARE @DBSnapshotServer VARCHAR(100),
		@SiteInfoHistorySeqAudit BIGINT, 
		@SiteInfoHistorySeq BIGINT,
		@HimTablesDatabase VARCHAR(100),
		@HimTablesLoadStatus CHAR(2),
		@CoreDatabaseName VARCHAR(100),
		@SiteCode VARCHAR(3),
        @Sql NVARCHAR(MAX) ,
        @SpExecuteSql NVARCHAR(MAX);

-- Audit the Load of Him tables so other customers using the same core know they have alreay been loaded
	SET @SpExecuteSql = @DatabaseName + '.sys.sp_executesql' -- This allows me to make calls on our snapshot without changing the db context
	EXEC @SpExecuteSql N'SELECT TOP 1	@CoreDatabaseName = SiteInfo.ShareFSDb, @SiteCode = SiteInfo.SiteCode	FROM dbo.SiteInfo',  N'@CoreDatabaseName VARCHAR(100) OUTPUT,@SiteCode VARCHAR(3) OUTPUT', @CoreDatabaseName = @CoreDatabaseName OUTPUT,@SiteCode = @SiteCode OUTPUT;;

	SET @HimTablesDatabase = (SELECT CASE WHEN EXISTS (SELECT  1 FROM    sys.databases  WHERE   name = @CoreDatabaseName) THEN @CoreDatabaseName ELSE @DatabaseName  END)

	SET @SpExecuteSql = @HimTablesDatabase + '.sys.sp_executesql' -- This allows me to make calls on our snapshot without changing the db context

	SET @Sql = '
	SELECT TOP 1 @SiteInfoHistorySeq = SiteInfoHistorySeq 
	FROM '+@HimTablesDatabase+'.dbo.SiteInfoHistory ORDER BY SiteInfoHistory.SiteInfoHistorySeq DESC

	SELECT TOP 1 @SiteInfoHistorySeqAudit = SiteInfoHistorySeq,@HimTablesLoadStatus = Status
	FROM '+@HimTablesDatabase+'.rpt.SnapshotLoadAudit ORDER BY SnapshotLoadAuditId DESC'

	EXEC @SpExecuteSql @Sql,N'@SiteInfoHistorySeqAudit BIGINT OUT,	@SiteInfoHistorySeq BIGINT OUT,@HimTablesLoadStatus CHAR(2) OUT',@SiteInfoHistorySeqAudit out, @SiteInfoHistorySeq out,@HimTablesLoadStatus out;
	-- Only Create new entry if last was loaded successfully
	IF (ISNULL(@SiteInfoHistorySeqAudit,0) <> @SiteInfoHistorySeq AND ISNULL(@HimTablesLoadStatus,'FI') = 'FI' AND (SELECT IsFullExtract FROM rpt.DataExtractType WHERE DataExtractTypeId = @DataExtractTypeId) <> 1)
	BEGIN
		SET @Sql = 'INSERT INTO '+@HimTablesDatabase+'.rpt.SnapshotLoadAudit VALUES ('''+@SiteCode+''','+CAST(@SiteInfoHistorySeq AS VARCHAR(MAX))+',(SELECT MAX(AppVersion) FROM rpt.AppVersion),''01'',GETDATE())'
		EXEC(@Sql)
	END
END
GO


