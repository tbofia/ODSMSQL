IF OBJECT_ID('stg.WFTaskLink', 'U') IS NOT NULL 
	DROP TABLE stg.WFTaskLink  
BEGIN
	CREATE TABLE stg.WFTaskLink
		(
		  FromTaskSeq INT NULL,
		  LinkWhen SMALLINT NULL,
		  ToTaskSeq INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

