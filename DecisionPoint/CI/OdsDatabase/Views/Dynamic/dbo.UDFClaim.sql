IF OBJECT_ID('dbo.UDFClaim', 'V') IS NOT NULL
    DROP VIEW dbo.UDFClaim;
GO

CREATE VIEW dbo.UDFClaim
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClaimIdNo
	,UDFIdNo
	,UDFValueText
	,UDFValueDecimal
	,UDFValueDate
FROM src.UDFClaim
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


