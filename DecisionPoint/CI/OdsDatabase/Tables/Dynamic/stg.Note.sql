IF OBJECT_ID('stg.Note', 'U') IS NOT NULL
DROP TABLE stg.Note
BEGIN
	CREATE TABLE stg.Note (
	   NoteId int NULL
      ,DateCreated datetimeoffset(7) NULL
      ,DateModified datetimeoffset(7) NULL
      ,CreatedBy varchar(15) NULL
      ,ModifiedBy varchar(15) NULL
      ,Flag tinyint NULL
      ,Content varchar(250) NULL
      ,NoteContext smallint NULL
      ,DemandClaimantId int NULL
	  ,DmlOperation CHAR(1) NOT NULL
		)
END
GO
