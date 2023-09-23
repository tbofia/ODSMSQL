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
