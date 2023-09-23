IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.GetDistinctList') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GetDistinctList
GO

CREATE FUNCTION dbo.GetDistinctList(
@List VARCHAR(MAX),
@Delim CHAR
)
RETURNS VARCHAR(MAX)
AS
BEGIN
DECLARE @DList VARCHAR(MAX);

SELECT @DList = STUFF((SELECT DISTINCT ', ' + CAST(StringText AS VARCHAR(50))
           FROM dbo.GetTableFromDelimitedString(@List,@Delim) 
           FOR XML PATH('')), 1, 2, '')
FROM dbo.GetTableFromDelimitedString(@List,@Delim)

RETURN @Dlist;
END
GO 

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.GetMaxRunFromOdsPostingGroupAuditId') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GetMaxRunFromOdsPostingGroupAuditId
GO

CREATE FUNCTION dbo.GetMaxRunFromOdsPostingGroupAuditId(
@ProcessName VARCHAR(100),
@AuditFor VARCHAR(100),
@ReportId INT
)  
RETURNS INT  
AS  
BEGIN  
DECLARE @DataAsOfOdsPostingGroupAuditId INT  
  
SELECT  
 @DataAsOfOdsPostingGroupAuditId=MAX(DataAsOfOdsPostingGroupAuditId)  
 FROM dbo.ProviderDataExplorerEtlAudit 
WHERE AuditFor = @AuditFor  
AND AuditProcess = @ProcessName  
AND EndDatetime IS NOT NULL  
AND ReportId = @ReportId  
  
RETURN @DataAsOfOdsPostingGroupAuditId  
  
END 
GO


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
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.GetTableFromDelimitedString') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GetTableFromDelimitedString
GO

CREATE FUNCTION dbo.GetTableFromDelimitedString (
@StringVal VARCHAR(MAX), 
@Delimiter VARCHAR(5)
)
RETURNS @TextTable TABLE ([StringText] VARCHAR(128) NULL)
AS
BEGIN
DECLARE @Pos INT
DECLARE @ListItem VARCHAR(128)
-- Loop while the list string still holds one or more characters
WHILE LEN(@StringVal) > 0
BEGIN
	-- Get the position of the first delimiter (returns 0 if non left in string)
	SET @Pos = CHARINDEX(@Delimiter, @StringVal)
	-- Extract the list item string
	IF @Pos = 0
	SET @ListItem = @StringVal
	ELSE
	SET @ListItem = SUBSTRING(@StringVal, 1, @Pos - 1)

	INSERT INTO @TextTable VALUES (RTRIM(LTRIM(@ListItem)))

	-- remove the list item (and trailing delimiter if present) from the list string
	IF @Pos = 0
	SET @StringVal = ''
	ELSE -- start substring at the character after the first comma
	SET @StringVal = SUBSTRING(@StringVal, @Pos + LEN(@Delimiter), LEN(@StringVal) - @Pos - LEN(@Delimiter) + 1)
END
        
RETURN 
END
GO
