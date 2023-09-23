IF OBJECT_ID('stg.ClaimDiag', 'U') IS NOT NULL 
	DROP TABLE stg.ClaimDiag  
BEGIN
	CREATE TABLE stg.ClaimDiag
		(
		  ClaimSysSubSet CHAR (4) NULL,
		  ClaimSeq INT NULL,
		  ClaimDiagSeq SMALLINT NULL,
		  DiagCode VARCHAR (8) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

