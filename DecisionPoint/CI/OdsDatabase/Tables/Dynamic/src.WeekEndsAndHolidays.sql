IF OBJECT_ID('src.WeekEndsAndHolidays', 'U') IS NULL
BEGIN
	CREATE TABLE src.WeekEndsAndHolidays (
		OdsPostingGroupAuditId INT NOT NULL,
		OdsCustomerId INT NOT NULL,
		OdsCreateDate DATETIME2(7) NOT NULL,
		OdsSnapshotDate DATETIME2(7) NOT NULL,
		OdsRowIsCurrent BIT NOT NULL,
		OdsHashbytesValue VARBINARY(8000) NULL,
		DmlOperation CHAR(1) NOT NULL,
		DayOfWeekDate datetime NULL,
		DayName char(3) NULL,
		WeekEndsAndHolidayId int NOT NULL
		) ON DP_Ods_PartitionScheme (OdsCustomerId)
		WITH (DATA_COMPRESSION = PAGE);

	ALTER TABLE src.WeekEndsAndHolidays 
	ADD CONSTRAINT PK_WeekEndsAndHolidays
	PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId,OdsCustomerId,WeekEndsAndHolidayId)
		WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_WeekEndsAndHolidays ON src.WeekEndsAndHolidays REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_WeekEndsAndHolidays'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_WeekEndsAndHolidays ON src.WeekEndsAndHolidays REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
