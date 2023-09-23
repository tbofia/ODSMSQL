BEGIN 
BEGIN TRANSACTION 
BEGIN TRY 


 DELETE rpt.AppVersion
 WHERE AppVersion = '2.2.0.0'

COMMIT TRANSACTION 
END TRY
BEGIN CATCH 
PRINT ' Something went wrong deleteing the AppVersion (2.2.0.0) in the rpt schema '
ROLLBACK TRANSACTION 
END CATCH
END