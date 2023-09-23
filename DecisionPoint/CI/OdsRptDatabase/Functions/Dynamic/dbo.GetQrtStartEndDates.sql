IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.GetQrtStartEndDates') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GetQrtStartEndDates
GO

CREATE FUNCTION dbo.GetQrtStartEndDates (@RunDate DATETIME = '1900-01-01',@Interval INT = 0)
RETURNS @QuarterInterval TABLE(
		QuarterStart DATETIME,
		QuarterEnd DATETIME)
AS
-- SELECT * FROM dbo.GetQrtStartEndDates('',-5)
BEGIN
/* DECLARE @RunDate DATETIME = GETDATE();
   DECLARE @Interval INT = -1;
   DECLARE @QuarterInterval TABLE(
		   QuarterStart DATETIME,
		   QuarterEnd DATETIME);
--*/
DECLARE @QuarterStart DATETIME,@QuarterEnd DATETIME;
DECLARE @Year INT,@Quarter INT,@Month INT, @Day VARCHAR(2);

SET @Year = YEAR(DATEADD(Q,@Interval,@RunDate))
SET @Quarter = DATEPART(Q,DATEADD(Q,@Interval,@RunDate))
SET @Month = @Quarter*3-2
SET @Day = '01'
--SELECT @Year,@Quarter,@Month,@Day;

SET @QuarterStart = CAST(@Year AS VARCHAR(4)) +'-'+ CAST(@Month AS VARCHAR(2)) +'-'+ @Day
--SELECT @QuarterStart

SET @QuarterEnd = DATEADD(DAY,-1,DATEADD(MONTH,3,@QuarterStart))
--SELECT @QuarterEnd

INSERT @QuarterInterval 
SELECT @QuarterStart,@QuarterEnd;

RETURN
END

GO
