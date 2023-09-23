IF OBJECT_ID('aw.ManualProviderSpecialty', 'V') IS NOT NULL
    DROP VIEW aw.ManualProviderSpecialty;
GO

CREATE VIEW aw.ManualProviderSpecialty
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ManualProviderId
	,Specialty
FROM src.ManualProviderSpecialty
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


