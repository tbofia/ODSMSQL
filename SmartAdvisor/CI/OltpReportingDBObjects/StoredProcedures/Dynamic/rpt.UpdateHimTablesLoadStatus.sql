IF OBJECT_ID('rpt.UpdateHimTablesLoadStatus') IS NOT NULL
    DROP PROCEDURE rpt.UpdateHimTablesLoadStatus
GO

CREATE PROCEDURE rpt.UpdateHimTablesLoadStatus  (
@HimTablesDatabase VARCHAR(100),
@SiteCode VARCHAR(3)
    )
AS
BEGIN
--DECLARE @HimTablesDatabase VARCHAR(100)='ODS_dB_1_Core',@SiteCode VARCHAR(3)='QA1'
    SET NOCOUNT ON
	
    EXEC ('UPDATE '+@HimTablesDatabase+'.rpt.SnapshotLoadAudit SET Status = ''FI'' WHERE SiteCode = '''+@SiteCode+''';');

END
GO



