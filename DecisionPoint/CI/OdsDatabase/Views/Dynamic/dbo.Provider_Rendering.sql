IF OBJECT_ID('dbo.Provider_Rendering', 'V') IS NOT NULL
    DROP VIEW dbo.Provider_Rendering;
GO

CREATE VIEW dbo.Provider_Rendering
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,PvdIDNo
	,RenderingAddr1
	,RenderingAddr2
	,RenderingCity
	,RenderingState
	,RenderingZip
FROM src.Provider_Rendering
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


