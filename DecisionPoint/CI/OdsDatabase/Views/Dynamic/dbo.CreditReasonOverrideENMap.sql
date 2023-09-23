IF OBJECT_ID('dbo.CreditReasonOverrideENMap', 'V') IS NOT NULL
    DROP VIEW dbo.CreditReasonOverrideENMap;
GO

CREATE VIEW dbo.CreditReasonOverrideENMap
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CreditReasonOverrideENMapId
	,CreditReasonId
	,OverrideEndnoteId
FROM src.CreditReasonOverrideENMap
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


