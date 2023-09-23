IF OBJECT_ID('dbo.ClientInsurer', 'V') IS NOT NULL
    DROP VIEW dbo.ClientInsurer;
GO

CREATE VIEW dbo.ClientInsurer
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClientCode
	,InsurerType
	,EffectiveDate
	,InsurerSeq
	,TerminationDate
FROM src.ClientInsurer
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


