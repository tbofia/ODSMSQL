-- If we've enabled change tracking on any of our dev or QA 
-- environments for dbo.WeekEndsAndHolidays, let's disable it.
SET XACT_ABORT ON;
BEGIN TRANSACTION
IF EXISTS ( SELECT  object_id
            FROM    sys.change_tracking_tables
            WHERE   object_id = OBJECT_ID('dbo.WeekEndsAndHolidays') )
    BEGIN
        ALTER TABLE dbo.WeekEndsAndHolidays
        DISABLE CHANGE_TRACKING;

-- Reset Checkpoint
        IF OBJECT_ID('rpt.ProcessCheckpoint', 'U') IS NOT NULL
            BEGIN
                UPDATE  pc
                SET     PreviousCheckpoint = 0 ,
                        LastChangeDate = GETDATE()
                FROM    rpt.ProcessCheckpoint pc
                WHERE   pc.ProcessId = 108; -- WeekEndsAndHolidays
            END
    END
COMMIT TRANSACTION
GO

-- If we've enabled change tracking on any of our dev or QA 
-- environments for dbo.VpnBillingCategory, let's disable it.
SET XACT_ABORT ON;
BEGIN TRANSACTION
IF EXISTS ( SELECT  object_id
            FROM    sys.change_tracking_tables
            WHERE   object_id = OBJECT_ID('dbo.VpnBillingCategory') )
    BEGIN
        ALTER TABLE dbo.VpnBillingCategory
        DISABLE CHANGE_TRACKING;

-- Reset Checkpoint
        IF OBJECT_ID('rpt.ProcessCheckpoint', 'U') IS NOT NULL
            BEGIN
                UPDATE  pc
                SET     PreviousCheckpoint = 0 ,
                        LastChangeDate = GETDATE()
                FROM    rpt.ProcessCheckpoint pc
                WHERE   pc.ProcessId = 107; -- VpnBillingCategory
            END
    END
COMMIT TRANSACTION
GO

-- If we've enabled change tracking on any of our dev or QA 
-- environments for dbo.GeneralInterestRuleBaseType, let's disable it.
SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF EXISTS
(
    SELECT object_id
    FROM sys.change_tracking_tables
    WHERE object_id = OBJECT_ID('dbo.GeneralInterestRuleBaseType')
)
BEGIN
    ALTER TABLE dbo.GeneralInterestRuleBaseType DISABLE CHANGE_TRACKING;

    -- Reset Checkpoint
    IF OBJECT_ID('rpt.ProcessCheckpoint', 'U') IS NOT NULL
    BEGIN
        UPDATE pc
        SET PreviousCheckpoint = 0,
            LastChangeDate = GETDATE()
        FROM rpt.ProcessCheckpoint pc
        WHERE pc.ProcessId = 173; -- GeneralInterestRuleBaseType
    END;
END;
COMMIT TRANSACTION;
GO
