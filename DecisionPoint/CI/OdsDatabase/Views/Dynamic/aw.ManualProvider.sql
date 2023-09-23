IF OBJECT_ID('aw.ManualProvider', 'V') IS NOT NULL
    DROP VIEW aw.ManualProvider;
GO

CREATE VIEW aw.ManualProvider
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
	,TIN
	,LastName
	,FirstName
	,GroupName
	,Address1
	,Address2
	,City
	,State
	,Zip
FROM src.ManualProvider
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


