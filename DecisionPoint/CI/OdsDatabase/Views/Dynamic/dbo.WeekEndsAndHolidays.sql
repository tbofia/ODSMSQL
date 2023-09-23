IF OBJECT_ID('dbo.WeekEndsAndHolidays', 'V') IS NOT NULL
    DROP VIEW dbo.WeekEndsAndHolidays;
GO

CREATE VIEW dbo.WeekEndsAndHolidays
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,DayOfWeekDate
	,DayName
	,WeekEndsAndHolidayId
FROM src.WeekEndsAndHolidays
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


