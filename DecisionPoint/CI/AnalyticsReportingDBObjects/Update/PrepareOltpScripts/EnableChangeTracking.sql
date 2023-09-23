
/*Enable Change Tracking*/
SET XACT_ABORT ON;

DECLARE @Sql VARCHAR(MAX);

SET @Sql = 'IF NOT EXISTS (
    SELECT database_id
    FROM sys.change_tracking_databases 
    WHERE database_id = DB_ID()
    )
    ALTER DATABASE [' + DB_NAME() + ']
    SET CHANGE_TRACKING = ON 
    (CHANGE_RETENTION = 10 DAYS, AUTO_CLEANUP = ON);'

EXEC (@Sql);

BEGIN TRANSACTION

IF NOT EXISTS ( SELECT  object_id
                FROM    sys.change_tracking_tables
                WHERE   object_id = OBJECT_ID('dbo.BillExclusionLookUpTable') )
    ALTER TABLE dbo.BillExclusionLookUpTable
    ENABLE CHANGE_TRACKING
    WITH (TRACK_COLUMNS_UPDATED = OFF);

IF NOT EXISTS ( SELECT  object_id
                FROM    sys.change_tracking_tables
                WHERE   object_id = OBJECT_ID('dbo.CustomerBillExclusion') )
    ALTER TABLE dbo.CustomerBillExclusion
    ENABLE CHANGE_TRACKING
    WITH (TRACK_COLUMNS_UPDATED = OFF);

IF NOT EXISTS ( SELECT  object_id
                FROM    sys.change_tracking_tables
                WHERE   object_id = OBJECT_ID('dbo.ProviderSpecialtyToProvType') )
    ALTER TABLE dbo.ProviderSpecialtyToProvType
    ENABLE CHANGE_TRACKING
    WITH (TRACK_COLUMNS_UPDATED = OFF);
    
IF NOT EXISTS ( SELECT  object_id
                FROM    sys.change_tracking_tables
                WHERE   object_id = OBJECT_ID('dbo.VPNActivityFlag') )
    ALTER TABLE dbo.VPNActivityFlag
    ENABLE CHANGE_TRACKING
    WITH (TRACK_COLUMNS_UPDATED = OFF);
    
IF NOT EXISTS ( SELECT  object_id
                FROM    sys.change_tracking_tables
                WHERE   object_id = OBJECT_ID('dbo.MedicalCodeCutOffs') )
    ALTER TABLE dbo.MedicalCodeCutOffs
    ENABLE CHANGE_TRACKING
    WITH (TRACK_COLUMNS_UPDATED = OFF);
    
COMMIT TRANSACTION;
GO
