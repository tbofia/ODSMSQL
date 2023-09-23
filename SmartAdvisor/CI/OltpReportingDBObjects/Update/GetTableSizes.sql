
SET NOCOUNT ON;

BEGIN TRANSACTION
BEGIN TRY

DECLARE @TableList VARCHAR(MAX)

DECLARE TableName CURSOR FOR
	SELECT name  
	FROM sysobjects
	WHERE name IN ('tblAddress','tblAdjustments','tblBenefits' ,'tblChange' ,'tblCompleteMaster', 'tblConcurrentEmployer','tblContact',
				   'tblCredits' , 'tblDependents' ,'tblImpairments' ,'tblJurReleases' ,'tblManagedCareOrganization',
				   'tblOtherBenefits' , 'tblPartOfBody','tblPayments' ,'tblRecoveries' ,'tblRedistributions','tblReducedEarnings',
				   'tblWitness'	)

OPEN TableName
FETCH NEXT FROM TableName
	INTO @TableList
WHILE @@FETCH_STATUS = 0
	BEGIN

	DECLARE @RowCountsAndSizes TABLE 
			(TableName NVARCHAR(128),rows CHAR(11),      
			reserved VARCHAR(18),data VARCHAR(18),index_size VARCHAR(18), 
			unused VARCHAR(18)) 

	INSERT INTO @RowCountsAndSizes EXEC sp_spaceused @TableList

FETCH NEXT FROM TableName
	INTO @TableList

END
	CLOSE TableName
	DEALLOCATE TableName


SELECT     DB_NAME() AS DataBaseName, TableName,CONVERT(bigint,rows) AS NumberOfRows,
           CONVERT(bigint,left(reserved,len(reserved)-3)) AS SizeInKB
FROM       @RowCountsAndSizes 
ORDER BY   NumberOfRows DESC,SizeinKB DESC,TableName

	
COMMIT TRANSACTION
END TRY
BEGIN CATCH
	PRINT 'Errors. Unable to find table sizes '
	ROLLBACK TRANSACTION
END CATCH
