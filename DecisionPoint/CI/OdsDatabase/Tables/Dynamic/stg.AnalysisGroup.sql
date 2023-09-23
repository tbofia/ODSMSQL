IF OBJECT_ID('stg.AnalysisGroup', 'U') IS NOT NULL
DROP TABLE stg.AnalysisGroup
BEGIN
	CREATE TABLE stg.AnalysisGroup (
		AnalysisGroupId int NULL
	   ,GroupName varchar(200) NULL
	   ,DmlOperation CHAR(1) NOT NULL
		)
END
GO
