IF OBJECT_ID('stg.Tag', 'U') IS NOT NULL
DROP TABLE stg.Tag
BEGIN
	CREATE TABLE stg.Tag (
	   TagId int NULL
      ,NAME varchar(50) NULL
      ,DateCreated datetimeoffset(7) NULL
      ,DateModified datetimeoffset(7) NULL
      ,CreatedBy varchar(15) NULL
      ,ModifiedBy varchar(15) NULL
	  ,DmlOperation CHAR(1) NOT NULL
		)
END
GO
