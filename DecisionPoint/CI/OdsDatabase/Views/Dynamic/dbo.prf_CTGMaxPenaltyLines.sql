IF OBJECT_ID('dbo.prf_CTGMaxPenaltyLines', 'V') IS NOT NULL
    DROP VIEW dbo.prf_CTGMaxPenaltyLines;
GO

CREATE VIEW dbo.prf_CTGMaxPenaltyLines
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CTGMaxPenLineID
	,ProfileId
	,DatesBasedOn
	,MaxPenaltyPercent
	,StartDate
	,EndDate
FROM src.prf_CTGMaxPenaltyLines
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


