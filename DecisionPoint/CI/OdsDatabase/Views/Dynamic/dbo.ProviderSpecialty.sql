IF OBJECT_ID('dbo.ProviderSpecialty', 'V') IS NOT NULL
    DROP VIEW dbo.ProviderSpecialty;
GO

CREATE VIEW dbo.ProviderSpecialty
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ProviderId
	,SpecialtyCode
FROM src.ProviderSpecialty
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


