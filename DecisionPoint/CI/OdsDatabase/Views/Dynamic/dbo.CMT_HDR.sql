IF OBJECT_ID('dbo.CMT_HDR', 'V') IS NOT NULL
    DROP VIEW dbo.CMT_HDR;
GO

CREATE VIEW dbo.CMT_HDR
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CMT_HDR_IDNo
	,CmtIDNo
	,PvdIDNo
	,LastChangedOn
FROM src.CMT_HDR
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


