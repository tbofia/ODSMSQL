IF OBJECT_ID('dbo.ProviderSpecialtyToProvType', 'V') IS NOT NULL
    DROP VIEW dbo.ProviderSpecialtyToProvType;
GO

CREATE VIEW dbo.ProviderSpecialtyToProvType
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ProviderType
	,ProviderType_Desc
	,Specialty
	,Specialty_Desc
	,CreateDate
	,ModifyDate
	,LogicalDelete
FROM src.ProviderSpecialtyToProvType
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


