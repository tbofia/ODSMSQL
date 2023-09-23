
IF OBJECT_ID('stg.MedicareStatusIndicatorRule', 'U') IS NOT NULL
DROP TABLE stg.MedicareStatusIndicatorRule
BEGIN
	CREATE TABLE stg.MedicareStatusIndicatorRule (
		MedicareStatusIndicatorRuleId INT NULL ,
        MedicareStatusIndicatorRuleName VARCHAR(50) NULL ,
        StatusIndicator VARCHAR(500) NULL ,
	    StartDate DATETIME2(7) NULL,
	    EndDate DATETIME2(7) NULL,
	    Endnote INT NULL,
	    EditActionId TINYINT NULL,
	    Comments VARCHAR(1000) NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO


