IF OBJECT_ID('rpt.DropDatabaseSnapshot') IS NOT NULL
    DROP PROCEDURE rpt.DropDatabaseSnapshot
GO

CREATE PROCEDURE rpt.DropDatabaseSnapshot    (
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
