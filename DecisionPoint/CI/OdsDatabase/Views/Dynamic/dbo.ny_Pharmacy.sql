IF OBJECT_ID('dbo.ny_pharmacy', 'V') IS NOT NULL
    DROP VIEW dbo.ny_pharmacy;
GO

CREATE VIEW dbo.ny_pharmacy
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,NDCCode
	,StartDate
	,EndDate
	,Description
	,Fee
	,TypeOfDrug
FROM src.ny_pharmacy
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


