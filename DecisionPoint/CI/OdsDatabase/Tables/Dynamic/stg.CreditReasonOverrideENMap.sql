IF OBJECT_ID('stg.CreditReasonOverrideENMap', 'U') IS NOT NULL
DROP TABLE stg.CreditReasonOverrideENMap
BEGIN
	CREATE TABLE stg.CreditReasonOverrideENMap (
		CreditReasonOverrideENMapId INT NULL
		,CreditReasonId INT NULL
		,OverrideEndnoteId SMALLINT NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
