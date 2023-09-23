IF OBJECT_ID('dbo.ny_specialty', 'V') IS NOT NULL
    DROP VIEW dbo.ny_specialty;
GO

CREATE VIEW dbo.ny_specialty
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,RatingCode
	,Desc_
	,CbreSpecialtyCode
FROM src.ny_specialty
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


