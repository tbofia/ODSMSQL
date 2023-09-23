IF OBJECT_ID('stg.SupplementPreCtgDeniedLinesEligibleToPenalty', 'U') IS NOT NULL 
	DROP TABLE stg.SupplementPreCtgDeniedLinesEligibleToPenalty  
BEGIN
	CREATE TABLE stg.SupplementPreCtgDeniedLinesEligibleToPenalty
		(
		  BillIdNo INT NULL,
		  LineNumber SMALLINT NULL,
		  CtgPenaltyTypeId TINYINT NULL,
		  SeqNo SMALLINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

