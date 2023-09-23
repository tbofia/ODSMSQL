IF OBJECT_ID('dbo.UDFLevelChangeTracking', 'V') IS NOT NULL
    DROP VIEW dbo.UDFLevelChangeTracking;
GO

CREATE VIEW dbo.UDFLevelChangeTracking
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,UDFLevelChangeTrackingId
	,EntityType
	,EntityId
	,CorrelationId
	,UDFId
	,PreviousValue
	,UpdatedValue
	,UserId
	,ChangeDate
FROM src.UDFLevelChangeTracking
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


