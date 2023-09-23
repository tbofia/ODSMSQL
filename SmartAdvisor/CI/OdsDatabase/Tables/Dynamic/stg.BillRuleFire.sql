IF OBJECT_ID('stg.BillRuleFire', 'U') IS NOT NULL 
	DROP TABLE stg.BillRuleFire  
BEGIN
	CREATE TABLE stg.BillRuleFire
		(
		  ClientCode CHAR (4) NULL,
		  BillSeq INT NULL,
		  LineSeq SMALLINT NULL,
		  RuleID CHAR (5) NULL,
		  RuleType CHAR (1) NULL,
		  DateRuleFired DATETIME NULL,
		  Validated CHAR (1) NULL,
		  ValidatedUserID CHAR (2) NULL,
		  DateValidated DATETIME NULL,
		  PendToID VARCHAR (13) NULL,
		  RuleSeverity CHAR (1) NULL,
		  WFTaskSeq INT NULL,
		  ChildTargetSubset VARCHAR (4) NULL,
		  ChildTargetSeq INT NULL,
		  CapstoneRuleID INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

