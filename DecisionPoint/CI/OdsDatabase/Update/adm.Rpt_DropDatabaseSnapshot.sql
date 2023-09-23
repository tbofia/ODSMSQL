IF OBJECT_ID('adm.Rpt_DropDatabaseSnapshot') IS NOT NULL
    DROP PROCEDURE adm.Rpt_DropDatabaseSnapshot
GO

CREATE PROCEDURE adm.Rpt_DropDatabaseSnapshot    (
@DBSnapshotName VARCHAR(100)  )
AS
BEGIN
-- DECLARE  @DBSnapshotName VARCHAR(100) = ''
    SET NOCOUNT ON

	IF EXISTS(SELECT  1
                    FROM    sys.databases
                    WHERE   name = @DBSnapshotName)
    EXEC ('DROP DATABASE ' + @DBSnapshotName + ';');

END
GO
