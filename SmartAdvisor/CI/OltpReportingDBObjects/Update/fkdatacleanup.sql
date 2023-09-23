IF OBJECT_ID('tempdb..#CascadingDeleteFKList') IS NOT NULL
DROP TABLE #CascadingDeleteFKList
GO

SET NOCOUNT ON
GO

DECLARE @sql nvarchar(max),
	@name varchar(128),
	@child varchar(128),
	@parent varchar(128),
	@referencingfield varchar(128),
	@referencedfield varchar(128),
	@timestamp varchar(20)

CREATE TABLE #CascadingDeleteFKList (
	Name varchar(128) NOT NULL PRIMARY KEY,
	Child varchar(128) NOT NULL,
	Parent varchar(128) NOT NULL,
	ReferencingField varchar(128) NOT NULL,
	ReferencedField varchar(128) NOT NULL,
	Sequence INT NOT NULL
)

-- Sequence matters; if tables act as both Child and Parent, must purge data when it plays
-- the role of child before it plays the role of parent.
--INSERT INTO #CascadingDeleteFKList (Name, Child, Parent, ReferencingField, ReferencedField,Sequence)
--SELECT 'FK_Claimant_CLAIMS','Claimant','CLAIMS','ClaimIDNo','ClaimIDNo',1 -- child and parent


DECLARE cr_fkdatacleanup CURSOR FOR 
SELECT Name, Child, Parent, ReferencingField, ReferencedField
FROM #CascadingDeleteFKList
ORDER BY Sequence, Name
	
OPEN cr_fkdatacleanup

FETCH NEXT FROM cr_fkdatacleanup
INTO @name, @child, @parent, @referencingfield, @referencedfield

PRINT ''
PRINT '****** STARTING FK DATA CLEANUP ******'

WHILE @@FETCH_STATUS = 0
BEGIN

SET @timestamp=CONVERT(varchar(10),GETDATE(),112)+
RIGHT('0'+CAST(DATEPART(hh,GETDATE()) AS varchar(2)),2)+
RIGHT('0'+CAST(DATEPART(mi,GETDATE()) AS varchar(2)),2)+
RIGHT('0'+CAST(DATEPART(ss,GETDATE()) AS varchar(2)),2)

SET @sql=
'
DECLARE @msg varchar(256)
DECLARE @fkviolations bit
DECLARE @sql nvarchar(max)

SET @fkviolations=0

-- Check to see if the parent exists  (remember, we may be upgrading from 6.8.2)
IF EXISTS (SELECT * FROM sys.objects WHERE object_id=object_id(''dbo.'+@parent+''') and type=''U'')
BEGIN
	-- Check to see if the child exists  (remember, we may be upgrading from 6.8.2)
	IF EXISTS (SELECT * FROM sys.objects WHERE object_id=object_id(''dbo.'+@child+''') and type=''U'')
	BEGIN
		-- Does the FK exist?
		IF NOT EXISTS (SELECT * FROM sys.objects WHERE parent_object_id=object_id(''dbo.'+@child+''') 
			AND object_id=object_id('''+@name+''') AND type=''F'')
		BEGIN
		
		BEGIN TRY
		
			-- Any potential FK violations that can be fixed?
			-- if the value is 0 and the column is NULLABLE, let''s assume they wanted NULL
			IF EXISTS (
				SELECT TOP 1 a.* 
				FROM dbo.'+@child+' a 
				WHERE NOT EXISTS (SELECT * FROM dbo.'+@parent+' b WHERE a.'+@referencingfield+'=b.'+@referencedfield+') 
				AND a.'+@referencingfield+'=''0''
				)
			AND EXISTS (
				SELECT * FROM sys.columns WHERE object_id=object_id(''dbo.'+@child+''') AND name='''+@referencingfield+''' AND is_nullable=1
				)
			BEGIN 
			
				SET @fkviolations=1
				
				SET @msg='''+@name+': FK violations where 0 can be set to NULL exist.''
				PRINT @msg

				-- Disable UPDATE triggers
				SELECT a.name AS TriggerName INTO dbo.#UpdateTrigger
				FROM sys.triggers a
				WHERE a.parent_id=OBJECT_ID(''dbo.'+@child+''')
				AND a.is_disabled=0
				AND OBJECTPROPERTY(a.object_id,''ExecIsUpdateTrigger'')=1
				ORDER BY a.name

				SET @sql=NULL

				SELECT @sql=ISNULL(@sql,'''')+''DISABLE TRIGGER ''+TriggerName+'' ON dbo.'+@child+'''+'';''+CHAR(13)+CHAR(10)
				FROM dbo.#UpdateTrigger
				ORDER BY TriggerName

				IF @sql<>''''
				BEGIN
					PRINT @sql
					EXEC sp_executesql @sql
				END

				BEGIN TRANSACTION
				-- save records that will be updated to NULL
				SELECT a.* INTO __'+@name+'_U_'+@timestamp+' FROM dbo.'+@child+' a 
				WHERE NOT EXISTS (SELECT * FROM dbo.'+@parent+' b WHERE a.'+@referencingfield+'=b.'+@referencedfield+') 
				AND a.'+@referencingfield+'=''0''
			
				-- update them
				UPDATE a
				SET '+@referencingfield+'=NULL
				FROM dbo.'+@child+' a
				WHERE NOT EXISTS (SELECT * FROM dbo.'+@parent+' b WHERE a.'+@referencingfield+'=b.'+@referencedfield+')
				AND a.'+@referencingfield+'=''0''
			
				COMMIT TRANSACTION

				-- Enable the UPDATE triggers we just disabled
				SET @sql=NULL

				SELECT @sql=ISNULL(@sql,'''')+''ENABLE TRIGGER ''+TriggerName+'' ON dbo.'+@child+'''+'';''+CHAR(13)+CHAR(10)
				FROM dbo.#UpdateTrigger
				ORDER BY TriggerName

				IF @sql<>''''
				BEGIN
					PRINT @sql
					EXEC sp_executesql @sql
				END
				
				SET @msg='''+@name+': Updated zeros to NULLs!''
				PRINT @msg	
				
			END
			
			-- Any potential FK violations that can''t be fixed?
			IF EXISTS (
				SELECT TOP 1 a.*
				FROM dbo.'+@child+' a
				WHERE NOT EXISTS (SELECT * FROM dbo.'+@parent+' b WHERE a.'+@referencingfield+'=b.'+@referencedfield+')
				AND a.'+@referencingfield+' IS NOT NULL
				)
			BEGIN 

				SET @fkviolations=1
				
				SET @msg='''+@name+': FK violations that must be deleted exist.''
				PRINT @msg

				-- Disable DELETE triggers
				SELECT a.name AS TriggerName INTO #DeleteTrigger
				FROM sys.triggers a
				WHERE a.parent_id=OBJECT_ID(''dbo.'+@child+''')
				AND a.is_disabled=0
				AND OBJECTPROPERTY(a.object_id,''ExecIsDeleteTrigger'')=1
				ORDER BY a.name

				SET @sql=NULL

				SELECT @sql=ISNULL(@sql,'''')+''DISABLE TRIGGER ''+TriggerName+'' ON dbo.'+@child+'''+'';''+CHAR(13)+CHAR(10)
				FROM #DeleteTrigger
				ORDER BY TriggerName

				IF @sql<>''''
				BEGIN
					PRINT @sql
					EXEC sp_executesql @sql
				END
				
				BEGIN TRANSACTION
				-- save records that violate FK
				SELECT a.* INTO __'+@name+'_D_'+@timestamp+' FROM dbo.'+@child+' a 
				WHERE NOT EXISTS (SELECT * FROM dbo.'+@parent+' b WHERE a.'+@referencingfield+'=b.'+@referencedfield+') 
				AND a.'+@referencingfield+' IS NOT NULL
				
				-- purge them
				DELETE FROM a
				FROM dbo.'+@child+' a
				WHERE NOT EXISTS (SELECT * FROM dbo.'+@parent+' b WHERE a.'+@referencingfield+'=b.'+@referencedfield+')
				AND a.'+@referencingfield+' IS NOT NULL
				
				COMMIT TRANSACTION

				-- Enable the DELETE triggers we just disabled
				SET @sql=NULL

				SELECT @sql=ISNULL(@sql,'''')+''ENABLE TRIGGER ''+TriggerName+'' ON dbo.'+@child+'''+'';''+CHAR(13)+CHAR(10)
				FROM #DeleteTrigger
				ORDER BY TriggerName

				IF @sql<>''''
				BEGIN
					PRINT @sql
					EXEC sp_executesql @sql
				END
				
				SET @msg='''+@name+': Completed data cleanup!''
				PRINT @msg			
				
			END	
			
		END TRY
		BEGIN CATCH
		IF XACT_STATE() <> 0
		ROLLBACK TRANSACTION

		DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
		SELECT @ErrMsg = ERROR_MESSAGE(),
			@ErrSeverity = ERROR_SEVERITY()

		-- Enable any UPDATE triggers we may have disabled above
		IF OBJECT_ID(''tempdb..#UpdateTrigger'') IS NOT NULL
		BEGIN
			SET @sql=NULL

			SELECT @sql=ISNULL(@sql,'''')+''ENABLE TRIGGER ''+TriggerName+'' ON dbo.'+@child+'''+'';''+CHAR(13)+CHAR(10)
			FROM #UpdateTrigger
			ORDER BY TriggerName

			IF @sql<>''''
			BEGIN
				PRINT @sql
				EXEC sp_executesql @sql
			END
		END

		-- Enable the DELETE triggers we may have disabled above
		IF OBJECT_ID(''tempdb..#DeleteTrigger'') IS NOT NULL
		BEGIN
			SET @sql=NULL

			SELECT @sql=ISNULL(@sql,'''')+''ENABLE TRIGGER ''+TriggerName+'' ON dbo.'+@child+'''+'';''+CHAR(13)+CHAR(10)
			FROM #DeleteTrigger
			ORDER BY TriggerName

			IF @sql<>''''
			BEGIN
				PRINT @sql
				EXEC sp_executesql @sql
			END
		END

		RAISERROR(@ErrMsg, @ErrSeverity, 1)
		RETURN
		      
		END CATCH
				
		END
	END
END
'

EXEC sp_executesql @sql

FETCH NEXT FROM cr_fkdatacleanup
INTO @name, @child, @parent, @referencingfield, @referencedfield
	
END

PRINT '****** COMPLETED FK DATA CLEANUP ******'
PRINT ''

CLOSE cr_fkdatacleanup
DEALLOCATE cr_fkdatacleanup

GO
SET NOCOUNT OFF
GO
