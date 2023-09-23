IF OBJECT_ID('dbo.prf_CTGPenaltyLines', 'V') IS NOT NULL
    DROP VIEW dbo.prf_CTGPenaltyLines;
GO

CREATE VIEW dbo.prf_CTGPenaltyLines
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CTGPenLineID
	,ProfileId
	,PenaltyType
	,FeeSchedulePercent
	,StartDate
	,EndDate
	,TurnAroundTime
FROM src.prf_CTGPenaltyLines
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


