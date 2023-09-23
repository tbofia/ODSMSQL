IF OBJECT_ID('dbo.StateSettingsNyRoomRate', 'V') IS NOT NULL
    DROP VIEW dbo.StateSettingsNyRoomRate;
GO

CREATE VIEW dbo.StateSettingsNyRoomRate
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,StateSettingsNyRoomRateId
	,StartDate
	,EndDate
	,RoomRate
FROM src.StateSettingsNyRoomRate
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


