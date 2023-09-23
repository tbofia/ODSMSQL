IF OBJECT_ID('dbo.RenderingNpiStates', 'V') IS NOT NULL
    DROP VIEW dbo.RenderingNpiStates;
GO

CREATE VIEW dbo.RenderingNpiStates
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ApplicationSettingsId
	,State
FROM src.RenderingNpiStates
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


