IF OBJECT_ID('dbo.UDFProvider', 'V') IS NOT NULL
    DROP VIEW dbo.UDFProvider;
GO

CREATE VIEW dbo.UDFProvider
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,PvdIdNo
	,UDFIdNo
	,UDFValueText
	,UDFValueDecimal
	,UDFValueDate
FROM src.UDFProvider
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


