IF OBJECT_ID('dbo.CreditReason', 'V') IS NOT NULL
    DROP VIEW dbo.CreditReason;
GO

CREATE VIEW dbo.CreditReason
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CreditReasonId
	,CreditReasonDesc
	,IsVisible
FROM src.CreditReason
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


