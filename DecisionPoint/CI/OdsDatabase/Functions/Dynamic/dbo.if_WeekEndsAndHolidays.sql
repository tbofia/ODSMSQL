IF OBJECT_ID('dbo.if_WeekEndsAndHolidays', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_WeekEndsAndHolidays;
GO

CREATE FUNCTION dbo.if_WeekEndsAndHolidays(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.DayOfWeekDate,
	t.DayName,
	t.WeekEndsAndHolidayId
FROM src.WeekEndsAndHolidays t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		WeekEndsAndHolidayId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.WeekEndsAndHolidays
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		WeekEndsAndHolidayId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.WeekEndsAndHolidayId = s.WeekEndsAndHolidayId
WHERE t.DmlOperation <> 'D';

GO


