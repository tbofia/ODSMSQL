SET XACT_ABORT ON

BEGIN TRANSACTION
-- In v1.0 of the ODS, I didn't account for different static database names.  Let's clean that
-- up now.
DECLARE  @DpduFullTableName VARCHAR(100)
		,@DpduStaticDatabase VARCHAR(100)
		,@OdsFullTableName VARCHAR(100)
		,@OdsStaticDatabase VARCHAR(100)
		,@SchemaName VARCHAR(5)
		,@ProductKey VARCHAR(20)
		,@SQLQuery NVARCHAR(MAX)
		,@ViewColumnList VARCHAR(MAX)
		,@BaseFileName VARCHAR(50);

-- Get DP static database name
SELECT  @DpduFullTableName = SUBSTRING(definition, PATINDEX('%from%', definition) + 4, 
	CASE WHEN PATINDEX('%.dbo.CMS_Fee%', definition) > 0 THEN PATINDEX('%.dbo.CMS_Fee%', definition) 
	ELSE PATINDEX('%..CMS_Fee%', definition) END)
FROM    sys.sql_modules sm
WHERE   sm.object_id = OBJECT_ID('dbo.CMS_Fee', 'V');

SELECT  @DpduStaticDatabase = RTRIM(LTRIM(LEFT(@DpduFullTableName, CHARINDEX('.', @DpduFullTableName) - 1)));

-- Now, get the database the ODS thinks is static
SELECT  @OdsFullTableName = SUBSTRING(definition, PATINDEX('%from%', definition) + 4, PATINDEX('%.dbo.AppVersion%', definition))
FROM    sys.sql_modules sm
WHERE   sm.object_id = OBJECT_ID('dbo.MMedStaticDataAppVersion', 'V');

SELECT  @OdsStaticDatabase = RTRIM(LTRIM(LEFT(@OdsFullTableName, CHARINDEX('.', @OdsFullTableName) - 1)));

-- If these two don't match, let's reset the static data checkpoint.  The next incremental will
-- perform a dump of the HIM static data, then subsequent checkpoints will be correct.
IF @OdsStaticDatabase IS NOT NULL
    AND @OdsStaticDatabase <> @DpduStaticDatabase
    BEGIN
        UPDATE  pc
        SET     PreviousCheckpoint = 0 ,
                LastChangeDate = GETDATE()
        FROM    rpt.ProcessCheckpoint pc
                INNER JOIN rpt.Process p ON pc.ProcessId = p.ProcessId
        WHERE   p.IsHimStatic = 1;
    END

--I'm creating a view on MMedStaticData.dbo.AppVersion so I know 
--when the HIM data has been updated.
IF OBJECT_ID('dbo.MMedStaticDataAppVersion', 'V') IS NOT NULL
    DROP VIEW dbo.MMedStaticDataAppVersion;

SET @SQLQuery = 'CREATE VIEW dbo.MMedStaticDataAppVersion
AS
SELECT  AppVersionId ,
        AppVersion ,
        AppVersionDate ,
        DataUpdateVersion ,
        DataUpdateDate
FROM    ' + @DpduStaticDatabase + '.dbo.AppVersion
';

EXEC (@SQLQuery);

GRANT SELECT ON dbo.MMedStaticDataAppVersion TO MedicalUserRole; 

-- THE VIEWS BELOW ARE CREATED FOR BACKWARD COMPATIBILITY 
-- We need them to report back to 8.3, but they aren't guaranteed to 
-- exist because they weren't around at the time of the original release.

-- *** IMPORTANT NOTE! ****
-- Unlike all other views, we'll only push if the view doesn't exist.
-- This is so we don't wipe out a newer version of the view created
-- via a DPDU and DP release.

BEGIN TRY
	DECLARE cr_viewname CURSOR FOR 
	SELECT BaseFileName,ProductKey 
	FROM rpt.Process
	WHERE IsSnapshot = 1 AND IsHimStatic = 1

	OPEN cr_viewname 

	FETCH NEXT FROM cr_viewname 
	INTO @BaseFileName,@ProductKey
		
	WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @ViewColumnList = NULL
		SET @SchemaName = (SELECT CASE WHEN @ProductKey = 'DecisionPoint' THEN 'dbo' WHEN @ProductKey = 'DemandManager' AND EXISTS(SELECT 1 FROM sys.schemas WHERE name = 'aw') THEN 'aw' ELSE 'dm' END )
		
		-- Get Column List for each view
		SET @SQLQuery = 
		'SELECT @ViewColumnList =  COALESCE(@ViewColumnList+CHAR(13)+CHAR(10)+CHAR(9)+'','','''')+COLUMN_NAME 
		 FROM '+@DpduStaticDatabase+'.INFORMATION_SCHEMA.COLUMNS
		 WHERE TABLE_NAME = '''+@BaseFileName+''''

		EXEC sp_executesql @SQLQuery,N'@ViewColumnList VARCHAR(MAX) OUT',@ViewColumnList OUT;

		IF (@ViewColumnList IS NOT NULL)
		BEGIN
			-- Build View Create Statement always drop the view because we want to always have the latest version
			-- Drop View If Exists
			SET @SQLQuery = 
			'IF OBJECT_ID('''+@SchemaName+'.'+@BaseFileName+''',''V'') IS NOT NULL'+CHAR(13)+CHAR(10)+
			'DROP VIEW '+@SchemaName+'.'+@BaseFileName+';'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
			EXEC(@SQLQuery)

			-- Recreate or Create View
			SET @SQLQuery = 
			'CREATE VIEW '+@SchemaName+'.'+@BaseFileName+''+CHAR(13)+CHAR(10)+
			'AS'+CHAR(13)+CHAR(10)+
			'SELECT '+@ViewColumnList+''+CHAR(13)+CHAR(10)+
			'FROM '+@DpduStaticDatabase+'.'+@SchemaName+'.'+@BaseFileName+';'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
			EXEC(@SQLQuery)

			-- Grant Permission to select on view
			SET @SQLQuery = 
			'GRANT SELECT ON '+@SchemaName+'.'+@BaseFileName+' TO MedicalUserRole;'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
			EXEC(@SQLQuery)
		END

	FETCH NEXT FROM cr_viewname 
	INTO @BaseFileName,@ProductKey
	
	END

	CLOSE cr_viewname 
	DEALLOCATE cr_viewname 

END TRY
BEGIN CATCH
	PRINT 'Errors. Could Not Create Static Data Views... '
END CATCH

COMMIT TRANSACTION
GO
