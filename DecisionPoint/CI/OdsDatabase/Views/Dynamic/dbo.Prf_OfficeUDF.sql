IF OBJECT_ID('dbo.Prf_OfficeUDF', 'V') IS NOT NULL
    DROP VIEW dbo.Prf_OfficeUDF;
GO

CREATE VIEW dbo.Prf_OfficeUDF
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,OfficeId
	,UDFIdNo
FROM src.Prf_OfficeUDF
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


