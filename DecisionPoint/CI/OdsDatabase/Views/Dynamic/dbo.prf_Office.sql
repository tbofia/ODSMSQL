IF OBJECT_ID('dbo.prf_Office', 'V') IS NOT NULL
    DROP VIEW dbo.prf_Office;
GO

CREATE VIEW dbo.prf_Office
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CompanyId
	,OfficeId
	,OfcNo
	,OfcName
	,OfcAddr1
	,OfcAddr2
	,OfcCity
	,OfcState
	,OfcZip
	,OfcPhone
	,OfcDefault
	,OfcClaimMask
	,OfcTinMask
	,Version
	,OfcEdits
	,OfcCOAEnabled
	,CTGEnabled
	,LastChangedOn
	,AllowMultiCoverage
FROM src.prf_Office
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


