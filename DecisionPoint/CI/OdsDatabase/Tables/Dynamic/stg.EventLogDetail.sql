IF OBJECT_ID('stg.EventLogDetail', 'U') IS NOT NULL
DROP TABLE stg.EventLogDetail
BEGIN
	CREATE TABLE stg.EventLogDetail (
	   EventLogDetailId int NULL
	  ,EventLogId int NULL
	  ,PropertyName varchar(50) NULL
	  ,OldValue varchar(max) NULL
	  ,NewValue varchar(max) NULL
	  ,DmlOperation CHAR(1) NOT NULL
		)
END
GO
