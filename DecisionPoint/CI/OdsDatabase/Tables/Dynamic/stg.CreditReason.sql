IF OBJECT_ID('stg.CreditReason', 'U') IS NOT NULL
DROP TABLE stg.CreditReason
BEGIN
	CREATE TABLE stg.CreditReason (
		CreditReasonId INT NULL
		,CreditReasonDesc VARCHAR(100) NULL
		,IsVisible BIT NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
