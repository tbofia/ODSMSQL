IF OBJECT_ID('stg.WeekEndsAndHolidays', 'U') IS NOT NULL
DROP TABLE stg.WeekEndsAndHolidays
BEGIN
CREATE TABLE stg.WeekEndsAndHolidays (
		DayOfWeekDate datetime NULL,
		DayName char(3) NULL,
		WeekEndsAndHolidayId int NOT NULL,
		DmlOperation char(1) NOT NULL
		)
END
GO
