IF OBJECT_ID('dbo.UDFClaimant', 'V') IS NOT NULL
    DROP VIEW dbo.UDFClaimant;
GO

CREATE VIEW dbo.UDFClaimant
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CmtIdNo
	,UDFIdNo
	,UDFValueText
	,UDFValueDecimal
	,UDFValueDate
FROM src.UDFClaimant
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


