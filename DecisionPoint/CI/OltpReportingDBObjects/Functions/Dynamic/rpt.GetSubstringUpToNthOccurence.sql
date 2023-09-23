-- Drop the function if it is already found in the database
IF OBJECT_ID('rpt.GetSubstringUpToNthOccurence', 'FN') IS NOT NULL
DROP FUNCTION rpt.GetSubstringUpToNthOccurence
GO

--create a new function to find the Nth word,
--with the option to choose things other than a space as the separator (for example a hyphen)
CREATE FUNCTION rpt.GetSubstringUpToNthOccurence(
@str VARCHAR(8000), 
@substr VARCHAR(255) = ' ', 
@occurrence INT)
RETURNS varchar(255)
AS
BEGIN
--DECLARE @str VARCHAR(8000) = '1.0.0.0', @substr VARCHAR(255) = '.', @occurrence INT = 1
-- Declare variables and place-holders
DECLARE @found INT = @occurrence,
		@parsedstr VARCHAR(8000) = '',
		@word VARCHAR(8000),
		@text VARCHAR(100),
		@end int;

-- Start an infinite loop that will only end when the Nth word is found
WHILE 1=1
BEGIN
IF @found = 1
BEGIN
SET @end = CHARINDEX(@substr, @str)
IF @end IS NULL or @end = 0
BEGIN
SET @end = LEN(@str)
END
SET @text = @parsedstr + LEFT(@str,@end-1)
BREAK
END;
-- If the selected word is beyond the number of words, NULL is returned
IF CHARINDEX(@substr, @str) IS NULL or CHARINDEX(@substr, @str) = 0
BEGIN
SET @text = NULL;
BREAK;
END

SET @parsedstr = @parsedstr + LEFT(@str, CHARINDEX(@substr, @str));
-- Each iteration of the loop will remove the first word from the left
SET @str = RIGHT(@str, LEN(@str)-CHARINDEX(@substr, @str));

SET @found = @found - 1
END

RETURN @text;
END
GO