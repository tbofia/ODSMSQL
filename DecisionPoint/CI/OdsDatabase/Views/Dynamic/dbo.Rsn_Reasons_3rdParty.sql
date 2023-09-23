IF OBJECT_ID('dbo.Rsn_Reasons_3rdParty', 'V') IS NOT NULL
    DROP VIEW dbo.Rsn_Reasons_3rdParty;
GO

CREATE VIEW dbo.Rsn_Reasons_3rdParty
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ReasonNumber
	,ShortDesc
	,LongDesc
FROM src.Rsn_Reasons_3rdParty
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


