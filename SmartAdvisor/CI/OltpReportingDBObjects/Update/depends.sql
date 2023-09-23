DECLARE @ErrMsg nvarchar(4000) = N'',@ErrSeverity INT;

BEGIN TRAN 
BEGIN TRY 
	IF NOT EXISTS (SELECT 1 
				FROM rpt.PostingGroupAudit 
				WHERE DataExtractTypeId = 1 AND Status = 'FI')
	BEGIN
		UPDATE rpt.DataExtractType  
		SET FullLoadVersion = '1.0', IsFullLoadDifferential = 1  
		WHERE DataExtractTypeId = 1;
	END
	COMMIT TRAN 
END TRY
BEGIN CATCH
	SELECT @ErrMsg = ERROR_MESSAGE(),
		   @ErrSeverity = ERROR_SEVERITY()
	ROLLBACK TRAN;
	RAISERROR(@ErrMsg, @ErrSeverity, 1); 
END CATCH 