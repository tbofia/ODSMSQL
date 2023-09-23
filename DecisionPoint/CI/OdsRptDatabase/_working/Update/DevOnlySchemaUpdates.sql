
DECLARE @EmailLookup TABLE 
(
	Id INT IDENTITY(1,1) NOT NULL,
	SqlLogin VARCHAR(14) NOT NULL,
	EmailAddress VARCHAR(255) NOT NULL 
);

INSERT @EmailLookup
(
	SqlLogin,
	EmailAddress
)
SELECT 'CORP\KP107541','karthiga.Palanisamy@mitchell.com' UNION
SELECT 'CORP\FK108073','Fetiya.Kefene@mitchell.com' UNION
SELECT 'CORP\HL108950','Henry.Li@mitchell.com' UNION
SELECT 'CORP\TB101541','Theodore.Bofia@mitchell.com';

DECLARE @EmailAddress VARCHAR(255) = '', @ErrMsg nvarchar(4000) = N'',@ErrSeverity INT;

SELECT TOP(1) @EmailAddress = ISNULL(EmailAddress,'')
FROM @EmailLookup
WHERE SqlLogin = SYSTEM_USER
ORDER BY Id;

BEGIN TRAN
BEGIN TRY
	UPDATE [adm].[ReportJob]
	SET EmailTo = @EmailAddress
	WHERE 1=1;

	COMMIT TRAN;
END TRY
BEGIN CATCH
	
	SELECT @ErrMsg = ERROR_MESSAGE(),
		   @ErrSeverity = ERROR_SEVERITY()
	ROLLBACK TRAN;
	RAISERROR(@ErrMsg, @ErrSeverity, 1);
END CATCH 
