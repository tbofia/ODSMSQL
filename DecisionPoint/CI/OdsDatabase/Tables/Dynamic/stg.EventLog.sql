IF OBJECT_ID('stg.EventLog', 'U') IS NOT NULL
DROP TABLE stg.EventLog
BEGIN
	CREATE TABLE stg.EventLog (
	   EventLogId int NULL
      ,ObjectName varchar(50) NULL
      ,ObjectId int NULL
      ,UserName varchar(15) NULL
      ,LogDate datetimeoffset(7) NULL
      ,ActionName varchar(20) NULL
      ,OrganizationId nvarchar(100) NULL
	  ,DmlOperation CHAR(1) NOT NULL
		)
END
GO
