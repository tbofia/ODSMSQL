IF OBJECT_ID('dbo.SPECIALTY', 'V') IS NOT NULL
    DROP VIEW dbo.SPECIALTY;
GO

CREATE VIEW dbo.SPECIALTY
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,SpcIdNo
	,Code
	,Description
	,PayeeSubTypeID
	,TieredTypeID
FROM src.SPECIALTY
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


