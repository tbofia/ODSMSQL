IF OBJECT_ID('adm.Rpt_RecreateTableIndexes', 'P') IS NOT NULL
    DROP PROCEDURE adm.Rpt_RecreateTableIndexes
GO

CREATE PROCEDURE adm.Rpt_RecreateTableIndexes (
@ProcessId INT)
AS
BEGIN

DECLARE @IndexScript NVARCHAR(MAX)

SELECT @IndexScript = IndexScript FROM adm.Process WHERE ProcessId = @ProcessId
IF @IndexScript IS NOT NULL OR @IndexScript <> ''
BEGIN
	EXEC(@IndexScript);

	UPDATE adm.Process
	SET IndexScript = NULL
	WHERE  ProcessId = @ProcessId
END
END 

GO


